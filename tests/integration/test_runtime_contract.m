function tests = test_runtime_contract
tests = functiontests(localfunctions);
end

function testRunProjectFormsAndModelHash(testCase)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
close_models(paths);
beforePlant = sha256_file(paths.plant);
beforeCommunication = sha256_file(paths.communication);
beforeSystem = sha256_file(paths.system);
pathBefore = path;
addpath(root);
cleanupPath = onCleanup(@() path(pathBefore));
run_project();
clear cleanupPath;
verifyEqual(testCase, path, pathBefore);
verifyFalse(testCase, bdIsLoaded(paths.plantModelName));
verifyFalse(testCase, bdIsLoaded(paths.communicationModelName));
verifyFalse(testCase, bdIsLoaded(paths.systemModelName));
verifyEqual(testCase, sha256_file(paths.plant), beforePlant);
verifyEqual(testCase, sha256_file(paths.communication), beforeCommunication);
verifyEqual(testCase, sha256_file(paths.system), beforeSystem);
verifyEqual(testCase, evalin('base', 'exist(''time_constant_s'', ''var'')'), 0);
verifyEqual(testCase, evalin('base', 'exist(''sample_period_s'', ''var'')'), 0);
verifyEqual(testCase, evalin('base', 'exist(''delay_s'', ''var'')'), 0);
pathBefore = path;
addpath(root);
cleanupPath = onCleanup(@() path(pathBefore));
statusOnly = run_project();
[statusWithOutput, output] = run_project();
statusWithOutputAgain = run_project();
verifyEqual(testCase, statusOnly, 0);
verifyEqual(testCase, statusWithOutput, 0);
verifyEqual(testCase, statusWithOutputAgain, 0);
verifyTrue(testCase, isfield(output, 'simulation'));
verifyTrue(testCase, isfield(output, 'evaluation'));
verify_evaluation_schema(testCase, output);
clear cleanupPath;
verifyEqual(testCase, path, pathBefore);
verifyEqual(testCase, sha256_file(paths.plant), beforePlant);
verifyEqual(testCase, sha256_file(paths.communication), beforeCommunication);
verifyEqual(testCase, sha256_file(paths.system), beforeSystem);
verifyEqual(testCase, evalin('base', 'exist(''time_constant_s'', ''var'')'), 0);
verifyEqual(testCase, evalin('base', 'exist(''sample_period_s'', ''var'')'), 0);
verifyEqual(testCase, evalin('base', 'exist(''delay_s'', ''var'')'), 0);
end

function verify_evaluation_schema(testCase, output)
evaluation = output.evaluation;
required = ["period_s", "total_cycles", "warmup_cycles", ...
    "nominal_start_s", "nominal_end_s", "sample_start_s", ...
    "sample_end_s", "sample_count", "mask", "rmse_zoh_m", ...
    "rmse_cv_m", "nrmse_zoh", "nrmse_cv", "max_error_zoh_m", ...
    "max_error_cv_m", "performance_ratio", "improvement_percent", ...
    "mean_packet_age_s", "omega_delay", "omega_mean_packet_age", ...
    "omega_time_constant", "omega_sample_period"];
verifyTrue(testCase, all(isfield(evaluation, required)));
verifyClass(testCase, evaluation.mask, 'logical');
verifySize(testCase, evaluation.mask, [numel(output.simulation.time_s), 1]);
verifyEqual(testCase, evaluation.sample_count, double(nnz(evaluation.mask)));
verifyEqual(testCase, evaluation.sample_start_s, ...
    output.simulation.time_s(find(evaluation.mask, 1)), AbsTol=0);
verifyEqual(testCase, evaluation.sample_end_s, ...
    output.simulation.time_s(find(evaluation.mask, 1, 'last')), AbsTol=0);
for name = required
    value = evaluation.(char(name));
    if ~strcmp(name, "mask")
        verifyTrue(testCase, isscalar(value) && isreal(value) && isfinite(value));
    end
end
end

function testNamedLoggingContract(testCase)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
config = teleopdelay.config.default_config();
time_s = teleopdelay.timegrid.create(0.2, 0.01);
trajectory = teleopdelay.trajectory.generate(time_s, config.trajectory);
simulationInput = teleopdelay.simulink.create_simulation_input(paths, config, trajectory);
load_system(paths.plant);
load_system(paths.communication);
load_system(paths.system);
cleanup = onCleanup(@() close_models(paths));
simulationOutput = sim(simulationInput);
names = cellstr(simulationOutput.yout.getElementNames());
names = names(:).';
verifyEqual(testCase, sort(names), sort({'zoh_command_xy_m', 'cv_command_xy_m', 'zoh_position_xy_m', ...
    'cv_position_xy_m', 'reference_position_xy_m', 'packet_timestamp_s', ...
    'packet_age_s', 'packet_valid'}));
verifyError(testCase, @() teleopdelay.simulink.validate_logging_names({'zoh_command_xy_m'}), ...
    'teleopDelay:InvalidLoggingContract');
verifyError(testCase, @() teleopdelay.simulink.validate_logging_names( ...
    {'zoh_command_xy_m', 'zoh_command_xy_m'}), 'teleopDelay:InvalidLoggingContract');
clear cleanup;
close_models(paths);
end

function testMissingModelIsExplicitError(testCase)
paths = teleopdelay.simulink.model_paths(project_root());
paths.plant = fullfile(paths.plantDirectory, 'missing_model.slx');
verifyError(testCase, @() teleopdelay.simulink.validate_models(paths), ...
    'teleopDelay:MissingModel');
end

function testReadOnlyModelsRemainRunnable(testCase)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
plantFile = java.io.File(paths.plant);
communicationFile = java.io.File(paths.communication);
systemFile = java.io.File(paths.system);
plantWasReadOnly = plantFile.canWrite() == false;
communicationWasReadOnly = communicationFile.canWrite() == false;
systemWasReadOnly = systemFile.canWrite() == false;
plantFile.setWritable(false);
communicationFile.setWritable(false);
systemFile.setWritable(false);
cleanup = onCleanup(@() restore_writable(plantFile, communicationFile, systemFile, ...
    plantWasReadOnly, communicationWasReadOnly, systemWasReadOnly));
pathBefore = path;
addpath(root);
cleanupPath = onCleanup(@() path(pathBefore));
status = run_project();
verifyEqual(testCase, status, 0);
clear cleanupPath;
clear cleanup;
restore_writable(plantFile, communicationFile, systemFile, ...
    plantWasReadOnly, communicationWasReadOnly, systemWasReadOnly);
end

function hash = sha256_file(filePath)
fileId = fopen(filePath, 'r');
cleanup = onCleanup(@() fclose(fileId));
bytes = fread(fileId, Inf, '*uint8');
digest = java.security.MessageDigest.getInstance('SHA-256');
digest.update(bytes);
hashBytes = typecast(digest.digest(), 'uint8');
hash = lower(reshape(dec2hex(hashBytes, 2).', 1, []));
clear cleanup;
end

function restore_writable(plantFile, communicationFile, systemFile, ...
        plantWasReadOnly, communicationWasReadOnly, systemWasReadOnly)
plantFile.setWritable(~plantWasReadOnly);
communicationFile.setWritable(~communicationWasReadOnly);
systemFile.setWritable(~systemWasReadOnly);
end

function root = project_root()
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

function close_models(paths)
if bdIsLoaded(paths.systemModelName)
    close_system(paths.systemModelName, 0);
end
if bdIsLoaded(paths.plantModelName)
    close_system(paths.plantModelName, 0);
end
if bdIsLoaded(paths.communicationModelName)
    close_system(paths.communicationModelName, 0);
end
end
