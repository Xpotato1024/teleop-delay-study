function tests = test_experiment_runner
tests = functiontests(localfunctions);
end

function testRepresentativeCaseIsDeterministicAndClean(testCase)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
close_models(paths);
beforeHashes = [teleopdelay.experiment.sha256_file(paths.plant), ...
    teleopdelay.experiment.sha256_file(paths.communication), ...
    teleopdelay.experiment.sha256_file(paths.system)];
pathBefore = path;
directoryBefore = pwd;
baseNames = ["time_constant_s", "sample_period_s", "delay_s"];
baseBefore = zeros(size(baseNames));
for index = 1:numel(baseNames)
    baseBefore(index) = evalin("base", "exist('" + baseNames(index) + "', 'var')");
end
manifest = teleopdelay.experiment.standard_manifest( ...
    "TrajectoryTypes", "circle", "Delays", 0.20, "Omegas", 4.0);
first = teleopdelay.experiment.run_manifest(manifest, root, ...
    "SaveResults", false);
second = teleopdelay.experiment.run_manifest(manifest, root, ...
    "SaveResults", false);
verifyEqual(testCase, first.aggregate.status, "success");
verifyEqual(testCase, second.aggregate.status, "success");
verifyTrue(testCase, all(isfinite(first.aggregate.rmse_zoh_m)));
verifyTrue(testCase, all(isfinite(first.aggregate.rmse_cv_m)));
metricNames = ["rmse_zoh_m", "rmse_cv_m", "nrmse_zoh", "nrmse_cv", ...
    "max_error_zoh_m", "max_error_cv_m", "performance_ratio", ...
    "improvement_percent", "mean_packet_age_s", "omega_delay", ...
    "omega_mean_packet_age", "omega_time_constant", "omega_sample_period"];
maximumDifference = 0;
for name = metricNames
    difference = abs(first.aggregate.(char(name)) - second.aggregate.(char(name)));
    maximumDifference = max(maximumDifference, max(difference));
    verifyLessThanOrEqual(testCase, max(difference), ...
        1e-12 * max(1, abs(first.aggregate.(char(name)))));
end
verifyLessThanOrEqual(testCase, maximumDifference, 1e-12);
verifyEqual(testCase, path, pathBefore);
verifyEqual(testCase, pwd, directoryBefore);
close_models(paths);
verifyFalse(testCase, bdIsLoaded(paths.plantModelName));
verifyFalse(testCase, bdIsLoaded(paths.communicationModelName));
verifyFalse(testCase, bdIsLoaded(paths.systemModelName));
verifyEqual(testCase, [teleopdelay.experiment.sha256_file(paths.plant), ...
    teleopdelay.experiment.sha256_file(paths.communication), ...
    teleopdelay.experiment.sha256_file(paths.system)], beforeHashes);
for index = 1:numel(baseNames)
    verifyEqual(testCase, evalin("base", "exist('" + baseNames(index) + "', 'var')"), ...
        baseBefore(index));
end
end

function close_models(paths)
names = {paths.systemModelName, paths.communicationModelName, paths.plantModelName};
for index = 1:numel(names)
    if bdIsLoaded(names{index})
        close_system(names{index}, 0);
    end
end
end

function root = project_root()
root = fileparts(fileparts(fileparts(mfilename("fullpath"))));
end
