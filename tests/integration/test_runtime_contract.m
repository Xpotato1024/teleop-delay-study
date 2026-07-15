function tests = test_runtime_contract
tests = functiontests(localfunctions);
end

function testRunProjectFormsAndModelHash(testCase)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
beforePlant = sha256_file(paths.plant);
beforeSystem = sha256_file(paths.system);
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
clear cleanupPath;
verifyEqual(testCase, path, pathBefore);
verifyEqual(testCase, sha256_file(paths.plant), beforePlant);
verifyEqual(testCase, sha256_file(paths.system), beforeSystem);
verifyEqual(testCase, evalin('base', 'exist(''time_constant_s'', ''var'')'), 0);
end

function testNamedLoggingContract(testCase)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
config = teleopdelay.config.default_config();
time_s = teleopdelay.timegrid.create(0.2, 0.01);
trajectory = teleopdelay.trajectory.generate(time_s, config.trajectory);
simulationInput = teleopdelay.simulink.create_simulation_input(paths, config, trajectory);
load_system(paths.plant);
load_system(paths.system);
cleanup = onCleanup(@() close_models(paths));
simulationOutput = sim(simulationInput);
names = cellstr(simulationOutput.yout.getElementNames());
names = names(:).';
verifyEqual(testCase, sort(names), sort({'command_xy_m', 'position_xy_m'}));
verifyError(testCase, @() teleopdelay.simulink.validate_logging_names({'command_xy_m'}), ...
    'teleopDelay:InvalidLoggingContract');
verifyError(testCase, @() teleopdelay.simulink.validate_logging_names( ...
    {'command_xy_m', 'command_xy_m'}), 'teleopDelay:InvalidLoggingContract');
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
systemFile = java.io.File(paths.system);
plantWasReadOnly = plantFile.canWrite() == false;
systemWasReadOnly = systemFile.canWrite() == false;
plantFile.setWritable(false);
systemFile.setWritable(false);
cleanup = onCleanup(@() restore_writable(plantFile, systemFile, plantWasReadOnly, systemWasReadOnly));
pathBefore = path;
addpath(root);
cleanupPath = onCleanup(@() path(pathBefore));
status = run_project();
verifyEqual(testCase, status, 0);
clear cleanupPath;
clear cleanup;
restore_writable(plantFile, systemFile, plantWasReadOnly, systemWasReadOnly);
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

function restore_writable(plantFile, systemFile, plantWasReadOnly, systemWasReadOnly)
plantFile.setWritable(~plantWasReadOnly);
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
end
