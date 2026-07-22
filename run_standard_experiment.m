function result = run_standard_experiment(varargin)
% run_standard_experiment  Execute and persist all 40 standard Issue #8 cases.

projectRoot = fileparts(mfilename("fullpath"));
sourceDirectory = fullfile(projectRoot, "src");
pathBefore = path;
directoryBefore = pwd;
cleanupPath = onCleanup(@() path(pathBefore));
cleanupDirectory = onCleanup(@() cd(directoryBefore));
addpath(sourceDirectory);

parser = inputParser;
addParameter(parser, "OutputRoot", fullfile(projectRoot, "results", "generated"));
addParameter(parser, "SaveResults", true, @(value) islogical(value) && isscalar(value));
parse(parser, varargin{:});

manifest = teleopdelay.experiment.standard_manifest();
result = teleopdelay.experiment.run_manifest(manifest, projectRoot, ...
    "OutputRoot", parser.Results.OutputRoot, ...
    "SaveResults", parser.Results.SaveResults);
clear cleanupDirectory cleanupPath;
end
