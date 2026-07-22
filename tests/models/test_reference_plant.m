function tests = test_reference_plant
tests = functiontests(localfunctions);
end

function testReferencePlantModelAndDirectConnection(testCase)
paths = teleopdelay.simulink.model_paths(project_root());
info = teleopdelay.simulink.validate_models(paths);
verifyEqual(testCase, info.plant_instance_count, 3);
load_system(paths.plant);
load_system(paths.communication);
load_system(paths.system);
cleanup = onCleanup(@() close_models(paths));
referenceBlock = [char(paths.systemModelName) '/reference_first_order_2d'];
verifyEqual(testCase, string(get_param(referenceBlock, 'ModelName')), ...
    string(paths.plantModelName));
parameters = get_param(referenceBlock, 'InstanceParameters');
index = find(strcmp(string({parameters.Name}), 'time_constant_s'), 1);
verifyNotEmpty(testCase, index);
verifyEqual(testCase, string(parameters(index).Value), "time_constant_s");
referenceOutput = [char(paths.systemModelName) '/reference_position_xy_m'];
verifyEqual(testCase, string(get_param(referenceOutput, 'PortDimensions')), "2");
verifyEqual(testCase, string(get_param(referenceOutput, 'OutDataTypeStr')), "double");
verifyEqual(testCase, string(get_param(referenceOutput, 'Unit')), "m");
verifyEqual(testCase, string(get_param(referenceOutput, 'SampleTime')), "-1");
connections = get_param(referenceBlock, 'PortConnectivity');
verifyEqual(testCase, string(getfullname(connections(1).SrcBlock)), ...
    string([char(paths.systemModelName) '/position_xy_m']));
clear cleanup;
close_models(paths);
end

function testZeroDelayAnalyticReferenceFixture(testCase)
config = teleopdelay.config.default_config();
config.simulation.dt = 0.01;
config.simulation.fixed_step = 0.01;
config.simulation.duration = 0.20;
config.communication.sample_period = 0.01;
config.communication.delay = 0;
config.trajectory.type = "circle";
teleopdelay.config.validate_config(config);
time_s = teleopdelay.timegrid.create(config.simulation.duration, config.simulation.dt);
trajectory = teleopdelay.trajectory.generate(time_s, config.trajectory);
paths = teleopdelay.simulink.model_paths(project_root());
simulationInput = teleopdelay.simulink.create_simulation_input(paths, config, trajectory);
simulation = teleopdelay.simulink.run_case(simulationInput, paths, config);

commandErrorZoh = max(abs(simulation.zoh_command_xy_m - trajectory.position_m), [], 'all');
commandErrorCv = max(abs(simulation.cv_command_xy_m - trajectory.position_m), [], 'all');
plantErrorZoh = max(abs(simulation.zoh_position_xy_m - ...
    simulation.reference_position_xy_m), [], 'all');
plantErrorCv = max(abs(simulation.cv_position_xy_m - ...
    simulation.reference_position_xy_m), [], 'all');
omega = config.trajectory.omega;
timeConstant = config.plant.time_constant;
alpha = omega * timeConstant;
referenceAnalytic = zeros(size(trajectory.position_m));
referenceAnalytic(:, 1) = config.trajectory.amplitude / (1 + alpha^2) * ...
    (cos(omega * time_s) + alpha * sin(omega * time_s) - exp(-time_s / timeConstant));
referenceAnalytic(:, 2) = config.trajectory.amplitude / (1 + alpha^2) * ...
    (sin(omega * time_s) - alpha * cos(omega * time_s) + ...
    alpha * exp(-time_s / timeConstant));
referenceAnalyticError = max(abs(simulation.reference_position_xy_m - ...
    referenceAnalytic), [], 'all');
verifyLessThan(testCase, commandErrorZoh, 1e-9);
verifyLessThan(testCase, commandErrorCv, 1e-9);
% The reference uses continuous external-input interpolation; the ZOH/CV
% branches use solver-stage packet reconstruction. These are distinct from
% the analytic plant error and therefore have separate measured tolerances.
verifyLessThan(testCase, referenceAnalyticError, 1e-5);
verifyLessThan(testCase, plantErrorZoh, 3e-3);
verifyLessThan(testCase, plantErrorCv, 2e-5);
verifyGreaterThan(testCase, plantErrorZoh, plantErrorCv);
verifyTrue(testCase, all(simulation.packet_valid));
end

function root = project_root()
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

function close_models(paths)
if bdIsLoaded(paths.systemModelName), close_system(paths.systemModelName, 0); end
if bdIsLoaded(paths.communicationModelName), close_system(paths.communicationModelName, 0); end
if bdIsLoaded(paths.plantModelName), close_system(paths.plantModelName, 0); end
end
