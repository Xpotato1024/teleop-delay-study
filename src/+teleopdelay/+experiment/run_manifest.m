function result = run_manifest(manifest, projectRoot, varargin)
% run_manifest  Run a manifest sequentially and enforce the failure contract.

if nargin < 2 || strlength(string(projectRoot)) == 0
    projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename("fullpath")))));
end
projectRoot = char(string(projectRoot));
parser = inputParser;
addParameter(parser, "OutputRoot", fullfile(projectRoot, "results", "generated"));
addParameter(parser, "SaveResults", true, @(value) islogical(value) && isscalar(value));
addParameter(parser, "CaseExecutor", @teleopdelay.experiment.execute_case, ...
    @(value) isa(value, "function_handle"));
parse(parser, varargin{:});
outputRoot = resolve_output_root(parser.Results.OutputRoot, projectRoot);
saveResults = parser.Results.SaveResults;
caseExecutor = parser.Results.CaseExecutor;

teleopdelay.experiment.validate_manifest(manifest);
startedAtUtc = utc_text(datetime("now", "TimeZone", "UTC"));
git = teleopdelay.experiment.git_context(projectRoot);
runId = allocate_run_id(outputRoot, manifest.experiment_id, git.short_sha);
caseResults = cell(manifest.case_count, 1);
pathBefore = path;
directoryBefore = pwd;
cleanupPath = onCleanup(@() path(pathBefore));
cleanupDirectory = onCleanup(@() cd(directoryBefore));

for index = 1:manifest.case_count
    definition = manifest.cases(index);
    casePath = path;
    caseDirectory = pwd;
    cleanupCasePath = onCleanup(@() path(casePath));
    cleanupCaseDirectory = onCleanup(@() cd(caseDirectory));
    try
        output = caseExecutor(definition, projectRoot);
        validate_success_output(output, definition);
        caseResults{index} = struct( ...
            "case_id", string(definition.case_id), ...
            "status", "success", ...
            "error_identifier", "", ...
            "error_message", "", ...
            "config", output.config, ...
            "trajectory", output.trajectory, ...
            "simulation", output.simulation, ...
            "evaluation", output.evaluation);
    catch exception
        identifier = string(exception.identifier);
        if strlength(identifier) == 0
            identifier = "MATLAB:UnknownError";
        end
        caseResults{index} = struct( ...
            "case_id", string(definition.case_id), ...
            "status", "failed", ...
            "error_identifier", identifier, ...
            "error_message", string(exception.message), ...
            "config", teleopdelay.experiment.case_config(definition), ...
            "trajectory", struct(), ...
            "simulation", struct(), ...
            "evaluation", struct());
    end
    close_case_models(projectRoot);
    clear cleanupCaseDirectory cleanupCasePath;
end

aggregate = teleopdelay.experiment.aggregate_table(manifest, caseResults);
successCount = sum(aggregate.status == "success");
failedCount = manifest.case_count - successCount;
if failedCount == 0
    runStatus = "complete";
else
    runStatus = "failed";
end
finishedAtUtc = utc_text(datetime("now", "TimeZone", "UTC"));
metadata = teleopdelay.experiment.execution_metadata(manifest, runId, ...
    projectRoot, startedAtUtc, finishedAtUtc, caseResults, runStatus);
bundle = struct( ...
    "manifest", manifest, ...
    "aggregate", aggregate, ...
    "metadata", metadata, ...
    "cases", {caseResults}, ...
    "run_status", runStatus, ...
    "experiment_id", string(manifest.experiment_id), ...
    "run_id", string(runId));

if saveResults
    if failedCount == 0
        artifact = teleopdelay.experiment.persist_results(bundle, outputRoot, false);
    else
        try
            artifact = teleopdelay.experiment.persist_results(bundle, outputRoot, true);
        catch persistenceException
            error("teleopDelay:ExperimentIncomplete", ...
                "Experiment incomplete: %d failed case(s); diagnostic persistence failed [%s]: %s", ...
                failedCount, persistenceException.identifier, persistenceException.message);
        end
    end
else
    artifact = empty_artifact();
end

if failedCount > 0
    error("teleopDelay:ExperimentIncomplete", ...
        "Experiment incomplete: %d failed case(s); diagnostic saved to %s.", ...
        failedCount, artifact.run_directory);
end

result = bundle;
result.artifact = artifact;
clear cleanupDirectory cleanupPath;
end

function validate_success_output(output, definition)
required = ["config", "trajectory", "simulation", "evaluation"];
if ~isstruct(output) || ~all(isfield(output, required))
    error("teleopDelay:ExperimentCaseOutputInvalid", ...
        "A successful case executor must return config, trajectory, simulation, and evaluation.");
end
if string(output.config.trajectory.type) ~= string(definition.trajectory)
    error("teleopDelay:ExperimentCaseOutputInvalid", ...
        "The case executor returned a different trajectory type.");
end
simulation = output.simulation;
if ~isfield(simulation, "time_s") || ~(iscolumn(simulation.time_s) && ...
        isa(simulation.time_s, "double") && all(isfinite(simulation.time_s)))
    error("teleopDelay:ExperimentCaseOutputInvalid", ...
        "simulation.time_s must be a finite double column.");
end
if abs(simulation.time_s(end) - definition.duration_s) > ...
        128 * eps(max([1, abs(simulation.time_s(end)), abs(definition.duration_s)]))
    error("teleopDelay:ExperimentCaseOutputInvalid", ...
        "The simulation endpoint is not the manifest duration.");
end
evaluationFields = ["sample_start_s", "sample_end_s", "mean_packet_age_s", ...
    "omega_mean_packet_age", "rmse_zoh_m", "rmse_cv_m", "nrmse_zoh", ...
    "nrmse_cv", "max_error_zoh_m", "max_error_cv_m", ...
    "performance_ratio", "improvement_percent", "omega_delay", ...
    "omega_time_constant", "omega_sample_period"];
if ~all(isfield(output.evaluation, evaluationFields))
    error("teleopDelay:ExperimentCaseOutputInvalid", ...
        "A successful evaluation is missing one or more metric fields.");
end
for name = evaluationFields
    value = output.evaluation.(char(name));
    if ~(isa(value, "double") && isscalar(value) && isreal(value) && isfinite(value))
        error("teleopDelay:ExperimentCaseOutputInvalid", ...
            "Evaluation field %s must be a finite scalar.", name);
    end
end
end

function close_case_models(projectRoot)
paths = teleopdelay.simulink.model_paths(projectRoot);
modelNames = [string(paths.systemModelName), string(paths.communicationModelName), ...
    string(paths.plantModelName)];
for name = modelNames
    if bdIsLoaded(char(name))
        close_system(char(name), 0);
    end
end
end

function runId = allocate_run_id(outputRoot, experimentId, shortSha)
timeNow = datetime("now", "TimeZone", "UTC");
timeNow.Format = "yyyyMMdd'T'HHmmssSSS'Z'";
runId = string(timeNow) + "__" + string(shortSha);
parent = fullfile(outputRoot, experimentId);
suffix = 0;
while isfolder(fullfile(parent, runId)) || isfolder(fullfile(parent, "failed", runId))
    suffix = suffix + 1;
    runId = string(timeNow) + "__" + string(shortSha) + "__r" + string(suffix);
end
end

function outputRoot = resolve_output_root(value, projectRoot)
outputRoot = char(string(value));
if isempty(regexp(outputRoot, '^(?:[A-Za-z]:[\\/]|\\\\|/)', 'once'))
    outputRoot = fullfile(projectRoot, outputRoot);
end
end

function text = utc_text(value)
value.Format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
text = string(value);
end

function artifact = empty_artifact()
artifact = struct("saved", false, "run_directory", "", ...
    "aggregate_csv", "", "results_mat", "", "diagnostic_csv", "", ...
    "diagnostic_mat", "", "csv_sha256", "unknown", "mat_sha256", "unknown", ...
    "csv_size_bytes", 0, "mat_size_bytes", 0, ...
    "round_trip_validated", false);
end
