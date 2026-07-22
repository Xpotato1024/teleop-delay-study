function artifact = persist_results(bundle, outputRoot, isDiagnostic)
% persist_results  Atomically save and round-trip validate a result bundle.

if nargin < 3
    isDiagnostic = false;
end
experimentId = char(string(bundle.experiment_id));
runId = char(string(bundle.run_id));
if isDiagnostic
    targetParent = fullfile(outputRoot, experimentId, "failed");
    csvName = experimentId + "__diagnostic.csv";
    matName = experimentId + "__diagnostic.mat";
else
    targetParent = fullfile(outputRoot, experimentId);
    csvName = experimentId + "__aggregate.csv";
    matName = experimentId + "__results.mat";
end
if ~isfolder(targetParent)
    mkdir(targetParent);
end
targetDirectory = fullfile(targetParent, runId);
if isfolder(targetDirectory) || isfile(targetDirectory)
    error("teleopDelay:ExperimentResultExists", ...
        "The result directory already exists: %s", targetDirectory);
end
temporaryDirectory = tempname(targetParent);
mkdir(temporaryDirectory);
cleanupTemporary = onCleanup(@() remove_temporary(temporaryDirectory));
temporaryCsv = fullfile(temporaryDirectory, csvName);
temporaryMat = fullfile(temporaryDirectory, matName);

manifest = bundle.manifest;
aggregate = bundle.aggregate;
metadata = bundle.metadata;
cases = bundle.cases;
run_status = bundle.run_status;
experiment_id = bundle.experiment_id;
run_id = bundle.run_id;
writetable(aggregate, temporaryCsv, "WriteVariableNames", true);
save(temporaryMat, "manifest", "aggregate", "metadata", "cases", ...
    "run_status", "experiment_id", "run_id", "-v7.3");
validate_round_trip(temporaryCsv, temporaryMat, bundle);

if ~isfolder(targetParent)
    mkdir(targetParent);
end
[moved, message] = movefile(temporaryDirectory, targetDirectory);
if ~moved
    error("teleopDelay:ExperimentAtomicSaveFailed", ...
        "Could not atomically move result directory: %s", message);
end
clear cleanupTemporary;
csvPath = fullfile(targetDirectory, csvName);
matPath = fullfile(targetDirectory, matName);
csvInfo = dir(csvPath);
matInfo = dir(matPath);
artifact = struct( ...
    "saved", true, ...
    "run_directory", string(targetDirectory), ...
    "aggregate_csv", "", ...
    "results_mat", "", ...
    "diagnostic_csv", "", ...
    "diagnostic_mat", "", ...
    "csv_sha256", file_sha256(csvPath), ...
    "mat_sha256", file_sha256(matPath), ...
    "csv_size_bytes", double(csvInfo.bytes), ...
    "mat_size_bytes", double(matInfo.bytes), ...
    "round_trip_validated", true);
if isDiagnostic
    artifact.diagnostic_csv = string(csvPath);
    artifact.diagnostic_mat = string(matPath);
else
    artifact.aggregate_csv = string(csvPath);
    artifact.results_mat = string(matPath);
end
end

function validate_round_trip(csvPath, matPath, bundle)
expected = bundle.aggregate;
imported = readtable(csvPath, "TextType", "string");
if height(imported) ~= height(expected) || ...
        ~isequal(imported.Properties.VariableNames, expected.Properties.VariableNames)
    error("teleopDelay:ExperimentRoundTripMismatch", ...
        "CSV row count or column names do not match the aggregate table.");
end
compare_tables(imported, expected, "CSV");
matData = load(matPath, "manifest", "aggregate", "metadata", "cases", ...
    "run_status", "experiment_id", "run_id");
if matData.manifest.case_count ~= bundle.manifest.case_count || ...
        height(matData.aggregate) ~= height(expected) || ...
        ~isequal(matData.aggregate.Properties.VariableNames, expected.Properties.VariableNames)
    error("teleopDelay:ExperimentRoundTripMismatch", ...
        "MAT manifest or aggregate schema does not match the source bundle.");
end
compare_tables(matData.aggregate, expected, "MAT");
if string(matData.metadata.experiment_id) ~= string(bundle.metadata.experiment_id) || ...
        string(matData.metadata.run_status) ~= string(bundle.metadata.run_status) || ...
        string(matData.run_status) ~= string(bundle.run_status)
    error("teleopDelay:ExperimentRoundTripMismatch", ...
        "MAT metadata does not match the source bundle.");
end
if ~iscell(matData.cases) || numel(matData.cases) ~= bundle.manifest.case_count
    error("teleopDelay:ExperimentRoundTripMismatch", ...
        "MAT does not contain one output bundle per manifest case.");
end
for index = 1:numel(matData.cases)
    sourceCase = bundle.cases{index};
    loadedCase = matData.cases{index};
    if string(loadedCase.case_id) ~= string(sourceCase.case_id) || ...
            string(loadedCase.status) ~= string(sourceCase.status)
        error("teleopDelay:ExperimentRoundTripMismatch", ...
            "MAT case_id or status does not match the aggregate order.");
    end
    if string(sourceCase.status) == "success"
        validate_case_schema(loadedCase);
        compare_metric(loadedCase.evaluation.rmse_zoh_m, ...
            expected.rmse_zoh_m(index), "MAT rmse_zoh_m");
        compare_metric(loadedCase.evaluation.rmse_cv_m, ...
            expected.rmse_cv_m(index), "MAT rmse_cv_m");
        compare_metric(loadedCase.evaluation.performance_ratio, ...
            expected.performance_ratio(index), "MAT performance_ratio");
    end
end
end

function compare_tables(actual, expected, sourceName)
for index = 1:numel(expected.Properties.VariableNames)
    name = expected.Properties.VariableNames{index};
    expectedValue = expected.(name);
    actualValue = actual.(name);
    if isstring(expectedValue) || iscellstr(expectedValue)
        actualText = string(actualValue);
        expectedText = string(expectedValue);
        actualText(ismissing(actualText) & expectedText == "") = "";
        if ~isequal(actualText, expectedText)
            error("teleopDelay:ExperimentRoundTripMismatch", ...
                "%s text column %s does not round-trip exactly.", sourceName, name);
        end
    else
        actualValue = double(actualValue);
        expectedValue = double(expectedValue);
        bothNaN = isnan(actualValue) & isnan(expectedValue);
        tolerance = 1e-12 * max(1, abs(expectedValue));
        mismatch = ~bothNaN & (isnan(actualValue) | ...
            abs(actualValue - expectedValue) > tolerance);
        if any(mismatch)
            error("teleopDelay:ExperimentRoundTripMismatch", ...
                "%s numeric column %s does not match within tolerance.", sourceName, name);
        end
    end
end
successRows = expected.status == "success";
numericNames = expected.Properties.VariableNames;
for nameCell = numericNames
    name = nameCell{1};
    value = expected.(name);
    if isnumeric(value) && any(successRows) && ...
            any(~isfinite(double(actual.(name)(successRows))))
        error("teleopDelay:ExperimentRoundTripMismatch", ...
            "%s contains nonfinite values in a successful row.", sourceName);
    end
end
end

function validate_case_schema(caseResult)
simulationFields = ["time_s", "zoh_command_xy_m", "cv_command_xy_m", ...
    "zoh_position_xy_m", "cv_position_xy_m", "reference_position_xy_m", ...
    "packet_timestamp_s", "packet_age_s", "packet_valid", "solver", ...
    "fixed_step_s"];
evaluationFields = ["sample_start_s", "sample_end_s", "mask", ...
    "rmse_zoh_m", "rmse_cv_m", "performance_ratio"];
if ~all(isfield(caseResult.simulation, simulationFields)) || ...
        ~all(isfield(caseResult.evaluation, evaluationFields))
    error("teleopDelay:ExperimentRoundTripMismatch", ...
        "MAT case is missing simulation or evaluation schema fields.");
end
end

function compare_metric(actual, expected, name)
tolerance = 1e-14 * max(1, abs(expected));
if ~(isfinite(actual) && isfinite(expected) && abs(actual - expected) <= tolerance)
    error("teleopDelay:ExperimentRoundTripMismatch", ...
        "%s does not match after MAT round-trip.", name);
end
end

function remove_temporary(directory)
if isfolder(directory)
    rmdir(directory, "s");
end
end

function digest = file_sha256(filePath)
command = "(Get-FileHash -LiteralPath '" + ...
    strrep(string(filePath), "'", "''") + "' -Algorithm SHA256).Hash";
powershellCommand = ['powershell -NoProfile -NonInteractive -Command "' ...
    char(command) '"'];
[status, output] = system(powershellCommand);
if status == 0 && strlength(strtrim(string(output))) > 0
    digest = string(strtrim(output));
else
    digest = "unknown";
end
end
