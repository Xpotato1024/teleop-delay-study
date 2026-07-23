function result = run_issue9_analysis(varargin)
% run_issue9_analysis  Analyze an explicit Issue #8 result MAT artifact.

projectRoot = fileparts(mfilename("fullpath"));
sourceDirectory = fullfile(projectRoot, "src");
pathBefore = path;
directoryBefore = pwd;
cleanupPath = onCleanup(@() path(pathBefore));
cleanupDirectory = onCleanup(@() cd(directoryBefore));
addpath(sourceDirectory);

parser = inputParser;
addParameter(parser, "InputMat", "", @(value) ischar(value) || isstring(value));
addParameter(parser, "OutputRoot", fullfile(projectRoot, "results", "generated"), ...
    @(value) ischar(value) || isstring(value));
addParameter(parser, "Mode", "render-only", @(value) ischar(value) || isstring(value));
addParameter(parser, "SaveResults", true, @(value) islogical(value) && isscalar(value));
addParameter(parser, "ConvergenceMat", "", @(value) ischar(value) || isstring(value));
parse(parser, varargin{:});

inputMat = string(parser.Results.InputMat);
if strlength(inputMat) == 0
    error("teleopDelay:AnalysisInputMissing", ...
        "InputMat is required; automatic latest-artifact discovery is disabled.");
end
mode = lower(string(parser.Results.Mode));
if ~ismember(mode, ["full", "render-only"])
    error("teleopDelay:AnalysisInvalidMode", ...
        "Mode must be ""full"" or ""render-only"".");
end
inputMat = resolve_path(inputMat, projectRoot);
outputRoot = resolve_path(string(parser.Results.OutputRoot), projectRoot);
startedAtUtc = utc_text(datetime("now", "TimeZone", "UTC"));

input = teleopdelay.analysis.load_input(inputMat);
config = teleopdelay.analysis.default_config();
machineTolerance = teleopdelay.analysis.machine_tolerance(input.aggregate.performance_ratio);
preliminaryClassification = teleopdelay.analysis.classify(input.aggregate, machineTolerance);
preliminaryRepresentatives = teleopdelay.analysis.select_representatives( ...
    input, preliminaryClassification, config);

if mode == "full"
    convergence = teleopdelay.analysis.run_convergence(input, ...
        preliminaryRepresentatives, projectRoot, config);
    convergenceSource = "executed-in-full-mode";
else
    convergence = teleopdelay.analysis.load_convergence(input, ...
        parser.Results.ConvergenceMat, outputRoot, config);
    convergenceSource = convergence.source;
end

[boundaryTolerance, toleranceContract] = teleopdelay.analysis.boundary_tolerance( ...
    input.aggregate.performance_ratio, convergence, config);
classification = teleopdelay.analysis.classify(input.aggregate, boundaryTolerance);
representatives = teleopdelay.analysis.select_representatives(input, classification, config);
theory = teleopdelay.analysis.theory();
boundaryBrackets = teleopdelay.analysis.detect_boundaries( ...
    classification, theory, config);
dimensionless = teleopdelay.analysis.dimensionless(input.aggregate, classification, theory);
identifiability = teleopdelay.analysis.identifiability(input.aggregate);
tables = teleopdelay.analysis.build_tables(input, classification, representatives, ...
    boundaryBrackets, dimensionless, identifiability, convergence, theory, config);

analysisId = teleopdelay.analysis.analysis_id(input, config, toleranceContract, convergence);
finishedAtUtc = utc_text(datetime("now", "TimeZone", "UTC"));
analysis = struct( ...
    "analysis_schema_version", config.analysis_schema_version, ...
    "analysis_id", analysisId, ...
    "mode", mode, ...
    "input", input, ...
    "config", config, ...
    "tolerance_contract", toleranceContract, ...
    "convergence_source", convergenceSource, ...
    "theory", theory, ...
    "tables", tables, ...
    "representatives", representatives, ...
    "started_at_utc", startedAtUtc, ...
    "finished_at_utc", finishedAtUtc);

if parser.Results.SaveResults
    artifact = teleopdelay.analysis.persist(analysis, outputRoot, projectRoot);
else
    artifact = struct("saved", false, "run_directory", "", ...
        "analysis_id", analysisId, "files", table(string.empty(0, 1), string.empty(0, 1)));
end
result = struct("analysis", analysis, "artifact", artifact);
clear cleanupDirectory cleanupPath;
end

function value = resolve_path(value, projectRoot)
value = char(string(value));
if isempty(value)
    return;
end
if isempty(regexp(value, '^(?:[A-Za-z]:[\\/]|\\\\|/)', 'once'))
    value = fullfile(projectRoot, value);
end
value = char(java.io.File(value).getCanonicalPath());
end

function text = utc_text(value)
value.Format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
text = string(value);
end
