function tests = test_experiment_aggregation_persistence
tests = functiontests(localfunctions);
end

function testAggregationSchemaAndUnits(testCase)
manifest = small_manifest();
caseResults = cell(manifest.case_count, 1);
for index = 1:manifest.case_count
    output = fixture_output(manifest.cases(index));
    caseResults{index} = successful_result(manifest.cases(index), output);
end
aggregate = teleopdelay.experiment.aggregate_table(manifest, caseResults);
expectedNames = { ...
    "case_id", "trajectory", "omega_rad_s", "delay_s", ...
    "sample_period_s", "time_constant_s", "fixed_step_s", "duration_s", ...
    "warmup_cycles", "evaluation_start_s", "evaluation_end_s", ...
    "omega_delay", "mean_packet_age_s", "omega_mean_packet_age", ...
    "omega_time_constant", "omega_sample_period", "rmse_zoh_m", ...
    "rmse_cv_m", "nrmse_zoh", "nrmse_cv", "max_error_zoh_m", ...
    "max_error_cv_m", "performance_ratio", "improvement_percent", ...
    "status", "error_identifier", "error_message"};
verifyEqual(testCase, string(aggregate.Properties.VariableNames), string(expectedNames));
verifySize(testCase, aggregate, [4, numel(expectedNames)]);
verifyClass(testCase, aggregate.case_id, "string");
verifyClass(testCase, aggregate.status, "string");
verifyEqual(testCase, aggregate.status, repmat("success", 4, 1));
verifyEqual(testCase, aggregate.evaluation_start_s, ...
    repmat(0.0, 4, 1), AbsTol=0);
verifyEqual(testCase, aggregate.omega_delay, ...
    aggregate.omega_rad_s .* aggregate.delay_s, AbsTol=0);
verifyTrue(testCase, all(isfinite(aggregate.rmse_zoh_m)));
end

function testSmallFixtureRoundTripAndNoImplicitOverwrite(testCase)
manifest = small_manifest();
outputRoot = tempname;
mkdir(outputRoot);
cleanup = onCleanup(@() rmdir(outputRoot, "s"));
root = project_root();
first = teleopdelay.experiment.run_manifest(manifest, root, ...
    "OutputRoot", outputRoot, "SaveResults", true, ...
    "CaseExecutor", @fixture_executor);
verifyTrue(testCase, first.artifact.saved);
verifyTrue(testCase, first.artifact.round_trip_validated);
verifyTrue(testCase, isfile(first.artifact.aggregate_csv));
verifyTrue(testCase, isfile(first.artifact.results_mat));
verifyTrue(testCase, contains(first.artifact.aggregate_csv, manifest.experiment_id));
verifyGreaterThan(testCase, strlength(first.artifact.csv_sha256), 32);
verifyGreaterThan(testCase, strlength(first.artifact.mat_sha256), 32);
csv = readtable(first.artifact.aggregate_csv, "TextType", "string");
loaded = load(first.artifact.results_mat, "manifest", "aggregate", ...
    "metadata", "cases", "run_status");
verifyEqual(testCase, height(csv), 4);
verifyEqual(testCase, height(loaded.aggregate), 4);
verifyEqual(testCase, loaded.manifest.case_count, 4);
verifyEqual(testCase, numel(loaded.cases), 4);
verifyEqual(testCase, loaded.run_status, "complete");
verifyEqual(testCase, loaded.metadata.success_case_count, 4);
verifyEqual(testCase, loaded.metadata.failed_case_count, 0);

second = teleopdelay.experiment.run_manifest(manifest, root, ...
    "OutputRoot", outputRoot, "SaveResults", true, ...
    "CaseExecutor", @fixture_executor);
verifyNotEqual(testCase, first.artifact.run_directory, second.artifact.run_directory);
verifyTrue(testCase, isfile(first.artifact.results_mat));
verifyTrue(testCase, isfile(second.artifact.results_mat));
end

function testFailureContractPersistsOnlyDiagnosticArtifact(testCase)
manifest = small_manifest();
outputRoot = tempname;
mkdir(outputRoot);
cleanup = onCleanup(@() rmdir(outputRoot, "s"));
root = project_root();
caught = false;
try
    teleopdelay.experiment.run_manifest(manifest, root, ...
        "OutputRoot", outputRoot, "SaveResults", true, ...
        "CaseExecutor", @failing_fixture_executor);
catch exception
    caught = true;
    verifyEqual(testCase, string(exception.identifier), "teleopDelay:ExperimentIncomplete");
    verifyTrue(testCase, contains(string(exception.message), "1 failed case"));
end
verifyTrue(testCase, caught);
experimentRoot = fullfile(outputRoot, manifest.experiment_id);
verifyTrue(testCase, isfolder(fullfile(experimentRoot, "failed")));
completeEntries = dir(experimentRoot);
completeEntries = completeEntries([completeEntries.isdir]);
completeEntries = completeEntries(~ismember(string({completeEntries.name}), [".", ".."]));
completeNames = string({completeEntries.name});
verifyEqual(testCase, completeNames, "failed");
failedEntries = dir(fullfile(experimentRoot, "failed"));
failedEntries = failedEntries([failedEntries.isdir]);
failedEntries = failedEntries(~ismember(string({failedEntries.name}), [".", ".."]));
failedNames = string({failedEntries.name});
verifyEqual(testCase, numel(failedNames), 1);
diagnosticDirectory = fullfile(experimentRoot, "failed", failedNames(1));
diagnosticCsv = fullfile(diagnosticDirectory, manifest.experiment_id + "__diagnostic.csv");
diagnosticMat = fullfile(diagnosticDirectory, manifest.experiment_id + "__diagnostic.mat");
verifyTrue(testCase, isfile(diagnosticCsv));
verifyTrue(testCase, isfile(diagnosticMat));
diagnostic = readtable(diagnosticCsv, "TextType", "string");
failedRows = diagnostic.status == "failed";
verifyEqual(testCase, nnz(failedRows), 1);
verifyEqual(testCase, diagnostic.error_identifier(failedRows), "test:IntentionalCaseFailure");
verifyTrue(testCase, strlength(diagnostic.error_message(failedRows)) > 0);
loaded = load(diagnosticMat, "metadata", "run_status");
verifyEqual(testCase, loaded.run_status, "failed");
verifyEqual(testCase, loaded.metadata.success_case_count, 3);
verifyEqual(testCase, loaded.metadata.failed_case_count, 1);
end

function testFailureContractPersistsDiagnosticWhenSaveResultsIsFalse(testCase)
manifest = small_manifest();
outputRoot = tempname;
mkdir(outputRoot);
cleanup = onCleanup(@() rmdir(outputRoot, "s"));
root = project_root();
caught = false;
exceptionMessage = "";
try
    teleopdelay.experiment.run_manifest(manifest, root, ...
        "OutputRoot", outputRoot, "SaveResults", false, ...
        "CaseExecutor", @failing_fixture_executor);
catch exception
    caught = true;
    verifyEqual(testCase, string(exception.identifier), "teleopDelay:ExperimentIncomplete");
    exceptionMessage = string(exception.message);
end
verifyTrue(testCase, caught);
experimentRoot = fullfile(outputRoot, manifest.experiment_id);
failedRoot = fullfile(experimentRoot, "failed");
verifyTrue(testCase, isfolder(failedRoot));
failedEntries = dir(failedRoot);
failedEntries = failedEntries([failedEntries.isdir]);
failedEntries = failedEntries(~ismember(string({failedEntries.name}), [".", ".."]));
verifyEqual(testCase, numel(failedEntries), 1);
diagnosticDirectory = fullfile(failedRoot, failedEntries(1).name);
verifyTrue(testCase, isfolder(diagnosticDirectory));
verifyTrue(testCase, contains(exceptionMessage, string(diagnosticDirectory)));
diagnosticCsv = fullfile(diagnosticDirectory, manifest.experiment_id + "__diagnostic.csv");
diagnosticMat = fullfile(diagnosticDirectory, manifest.experiment_id + "__diagnostic.mat");
verifyTrue(testCase, isfile(diagnosticCsv));
verifyTrue(testCase, isfile(diagnosticMat));
completeEntries = dir(experimentRoot);
completeEntries = completeEntries([completeEntries.isdir]);
completeEntries = completeEntries(~ismember(string({completeEntries.name}), [".", "..", "failed"]));
verifyEmpty(testCase, completeEntries);
diagnostic = readtable(diagnosticCsv, "TextType", "string");
failedRows = diagnostic.status == "failed";
verifyEqual(testCase, nnz(failedRows), 1);
verifyEqual(testCase, diagnostic.error_identifier(failedRows), "test:IntentionalCaseFailure");
end

function testManifestOutputBindingRejectsNegativeFixtures(testCase)
manifest = small_manifest();
modes = ["delay", "omega", "fixed_step", "solver", "omega_delay"];
for mode = modes
    outputRoot = tempname;
    mkdir(outputRoot);
    cleanup = onCleanup(@() rmdir(outputRoot, "s"));
    root = project_root();
    caught = false;
    try
        teleopdelay.experiment.run_manifest(manifest, root, ...
            "OutputRoot", outputRoot, "SaveResults", true, ...
            "CaseExecutor", @(definition, projectRoot) ...
            mismatched_fixture_executor(definition, projectRoot, mode));
    catch exception
        caught = true;
        verifyEqual(testCase, string(exception.identifier), ...
            "teleopDelay:ExperimentIncomplete");
    end
    verifyTrue(testCase, caught);
    diagnosticDirectory = find_diagnostic_directory(outputRoot, manifest.experiment_id);
    diagnosticCsv = fullfile(diagnosticDirectory, manifest.experiment_id + "__diagnostic.csv");
    verifyTrue(testCase, isfile(diagnosticCsv));
    diagnostic = readtable(diagnosticCsv, "TextType", "string");
    failedRows = diagnostic.status == "failed";
    verifyEqual(testCase, nnz(failedRows), 1);
    verifyEqual(testCase, diagnostic.error_identifier(failedRows), ...
        "teleopDelay:ExperimentCaseOutputMismatch");
    clear cleanup;
end
end

function manifest = small_manifest()
manifest = teleopdelay.experiment.standard_manifest( ...
    "TrajectoryTypes", ["circle", "lissajous_1_2"], ...
    "Delays", [0, 0.1], "Omegas", 0.5);
end

function output = fixture_executor(definition, ~)
output = fixture_output(definition);
end

function output = failing_fixture_executor(definition, ~)
if definition.delay_s == 0.1 && definition.omega_rad_s == 0.5 && ...
        definition.trajectory == "lissajous_1_2"
    error("test:IntentionalCaseFailure", "Intentional fixture failure.");
end
output = fixture_output(definition);
end

function output = mismatched_fixture_executor(definition, ~, mode)
output = fixture_output(definition);
if definition.trajectory ~= "lissajous_1_2" || definition.delay_s ~= 0.1
    return;
end
switch string(mode)
    case "delay"
        output.config.communication.delay = definition.delay_s + 0.01;
    case "omega"
        output.config.trajectory.omega = definition.omega_rad_s + 0.5;
    case "fixed_step"
        output.config.simulation.fixed_step = definition.fixed_step_s + 0.001;
        output.simulation.fixed_step_s = output.config.simulation.fixed_step;
    case "solver"
        output.config.simulation.solver = "ode45";
        output.simulation.solver = "ode45";
    case "omega_delay"
        output.evaluation.omega_delay = output.evaluation.omega_delay + 1.0;
end
end

function directory = find_diagnostic_directory(outputRoot, experimentId)
failedRoot = fullfile(outputRoot, experimentId, "failed");
entries = dir(failedRoot);
entries = entries([entries.isdir]);
entries = entries(~ismember(string({entries.name}), [".", ".."]));
assert(numel(entries) == 1);
directory = fullfile(failedRoot, entries(1).name);
end

function output = fixture_output(definition)
config = teleopdelay.experiment.case_config(definition);
time_s = [0; definition.duration_s / 2; definition.duration_s];
N = numel(time_s);
zeroXY = zeros(N, 2);
trajectory = struct("type", definition.trajectory, "time_s", time_s, ...
    "position_m", zeroXY, "velocity_mps", zeroXY, "acceleration_mps2", zeroXY);
simulation = struct( ...
    "time_s", time_s, ...
    "zoh_command_xy_m", zeroXY, ...
    "cv_command_xy_m", zeroXY, ...
    "zoh_position_xy_m", zeroXY, ...
    "cv_position_xy_m", zeroXY, ...
    "reference_position_xy_m", zeroXY, ...
    "packet_timestamp_s", time_s, ...
    "packet_age_s", zeros(N, 1), ...
    "packet_valid", true(N, 1), ...
    "solver", config.simulation.solver, ...
    "fixed_step_s", config.simulation.fixed_step);
evaluation = struct( ...
    "period_s", 2 * pi / definition.omega_rad_s, ...
    "total_cycles", definition.total_cycles, ...
    "warmup_cycles", definition.warmup_cycles, ...
    "nominal_start_s", 0, ...
    "nominal_end_s", definition.duration_s, ...
    "sample_start_s", 0, ...
    "sample_end_s", definition.duration_s, ...
    "sample_count", double(N), ...
    "mask", true(N, 1), ...
    "rmse_zoh_m", 0.1, ...
    "rmse_cv_m", 0.05, ...
    "nrmse_zoh", 0.1, ...
    "nrmse_cv", 0.05, ...
    "max_error_zoh_m", 0.2, ...
    "max_error_cv_m", 0.1, ...
    "performance_ratio", 0.5, ...
    "improvement_percent", 50.0, ...
    "mean_packet_age_s", 0.0, ...
    "omega_delay", definition.omega_rad_s * definition.delay_s, ...
    "omega_mean_packet_age", 0.0, ...
    "omega_time_constant", definition.omega_rad_s * definition.time_constant_s, ...
    "omega_sample_period", definition.omega_rad_s * definition.sample_period_s);
output = struct("config", config, "trajectory", trajectory, ...
    "simulation", simulation, "evaluation", evaluation);
end

function result = successful_result(definition, output)
result = struct("case_id", definition.case_id, "status", "success", ...
    "error_identifier", "", "error_message", "", ...
    "config", output.config, "trajectory", output.trajectory, ...
    "simulation", output.simulation, "evaluation", output.evaluation);
end

function root = project_root()
root = fileparts(fileparts(fileparts(mfilename("fullpath"))));
end
