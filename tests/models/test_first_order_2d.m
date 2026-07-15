function tests = test_first_order_2d
tests = functiontests(localfunctions);
end

function testModelInterface(testCase)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
info = teleopdelay.simulink.validate_models(paths);
verifyEqual(testCase, info.input_dimension, 2);
verifyEqual(testCase, info.output_dimension, 2);
verifyEqual(testCase, info.data_type, "double");
verifyEqual(testCase, info.unit, "m");
verifyEqual(testCase, get_param_model_argument(paths), "time_constant_s");
end

function testConstantInputAnalyticSolution(testCase)
config = short_config(0.2, 0.01, 1.0);
command = [1.0, -0.5];
simulation = run_constant_case(config, command);
expected = command .* (1 - exp(-simulation.time_s / config.plant.time_constant));
error_max = max(abs(simulation.position_xy_m - expected), [], 'all');
verifyLessThan(testCase, error_max, 1e-5);
end

function testZeroInputAndBothAxes(testCase)
config = short_config(0.2, 0.01, 0.5);
simulation = run_constant_case(config, [0, 0]);
verifyLessThanOrEqual(testCase, max(abs(simulation.position_xy_m), [], 'all'), 1e-12);
config.plant.time_constant = 0.1;
simulation = run_constant_case(config, [0.75, -0.25]);
verifySize(testCase, simulation.position_xy_m, [numel(simulation.time_s), 2]);
verifyTrue(testCase, all(isfinite(simulation.position_xy_m), 'all'));
end

function testRuntimeTimeConstantChangesResponse(testCase)
config = short_config(0.2, 0.01, 1.0);
slow = run_constant_case(config, [1, 1]);
config.plant.time_constant = 0.4;
fast = run_constant_case(config, [1, 1]);
verifyGreaterThan(testCase, max(abs(slow.position_xy_m-fast.position_xy_m), [], 'all'), 1e-4);
end

function testReferencedPlantStandalone(testCase)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
config = short_config(0.2, 0.01, 0.5);
time_s = teleopdelay.timegrid.create(config.simulation.duration, config.simulation.dt);
command = repmat([1, -0.5], numel(time_s), 1);
load_system(paths.plant);
cleanup = onCleanup(@() close_if_loaded(paths.plantModelName));
simulationInput = Simulink.SimulationInput(paths.plantModelName);
simulationInput = simulationInput.setExternalInput(timeseries(command, time_s, 'Name', 'command_xy_m'));
simulationInput = simulationInput.setVariable('time_constant_s', ...
    Simulink.Parameter(config.plant.time_constant), Workspace=paths.plantModelName);
simulationInput = simulationInput.setModelParameter( ...
    'StopTime', string(config.simulation.duration), ...
    'FixedStep', string(config.simulation.fixed_step), ...
    'SaveOutput', 'on', 'OutputSaveName', 'yout', 'SaveFormat', 'Dataset');
simulationOutput = sim(simulationInput);
values = simulationOutput.yout.getElement(1).Values;
expected = command .* (1 - exp(-time_s / config.plant.time_constant));
verifyLessThan(testCase, max(abs(values.Data - expected), [], 'all'), 1e-5);
clear cleanup;
close_if_loaded(paths.plantModelName);
end

function testSolverStepHalving(testCase)
config = short_config(0.2, 0.01, 1.0);
coarse = run_constant_case(config, [1, 0.5]);
coarse_error = max(abs(coarse.position_xy_m - ...
    [1, 0.5] .* (1 - exp(-coarse.time_s / config.plant.time_constant))), [], 'all');
config.simulation.dt = 0.005;
config.simulation.fixed_step = 0.005;
fine = run_constant_case(config, [1, 0.5]);
fine_error = max(abs(fine.position_xy_m - ...
    [1, 0.5] .* (1 - exp(-fine.time_s / config.plant.time_constant))), [], 'all');
verifyLessThan(testCase, coarse_error, 1e-5);
verifyLessThan(testCase, fine_error, coarse_error);
end

function simulation = run_constant_case(config, command)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
time_s = teleopdelay.timegrid.create(config.simulation.duration, config.simulation.dt);
trajectory = struct('time_s', time_s, 'position_m', repmat(command, numel(time_s), 1));
simulationInput = teleopdelay.simulink.create_simulation_input(paths, config, trajectory);
simulation = teleopdelay.simulink.run_case(simulationInput, paths, config);
end

function config = short_config(time_constant_s, dt_s, duration_s)
config = teleopdelay.config.default_config();
config.plant.time_constant = time_constant_s;
config.simulation.dt = dt_s;
config.simulation.fixed_step = dt_s;
config.simulation.duration = duration_s;
teleopdelay.config.validate_config(config);
end

function name = get_param_model_argument(paths)
load_system(paths.plant);
cleanup = onCleanup(@() close_if_loaded(paths.plantModelName));
name = string(get_param(paths.plantModelName, 'ParameterArgumentNames'));
clear cleanup;
close_if_loaded(paths.plantModelName);
end

function root = project_root()
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

function close_if_loaded(modelName)
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
end
