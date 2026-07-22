function tests = test_sampled_communication
tests = functiontests(localfunctions);
end

function testCommunicationFixtures(testCase)
root = project_root();
paths = teleopdelay.simulink.model_paths(root);
config = teleopdelay.config.default_config();
config.simulation.dt = 0.01;
config.simulation.fixed_step = 0.01;
config.simulation.duration = 0.30;
config.communication.sample_period = 0.05;
config.communication.delay = 0.10;
velocity = [1.5, -0.5];
trajectory = constant_velocity_trajectory(config, velocity);

simulation = run_case(config, trajectory, paths);
verifyFalse(testCase, any(simulation.packet_valid(simulation.time_s < 0.10)));
boundary = find(abs(simulation.time_s - 0.10) < 1e-12, 1);
verifyTrue(testCase, simulation.packet_valid(boundary));
verifyEqual(testCase, simulation.packet_timestamp_s(boundary), 0, AbsTol=1e-12);
verifyEqual(testCase, simulation.packet_age_s(boundary), 0.10, AbsTol=1e-12);
verifyEqual(testCase, simulation.zoh_command_xy_m(boundary,:), trajectory.position_m(1,:), AbsTol=1e-12);
verifyEqual(testCase, simulation.cv_command_xy_m(boundary,:), trajectory.position_m(boundary,:), AbsTol=1e-10);
valid = simulation.packet_valid;
expectedTimestamp = zeros(size(simulation.time_s));
expectedValid = false(size(simulation.time_s));
for index = 1:numel(simulation.time_s)
    availableTime = simulation.time_s(index) - config.communication.delay;
    if availableTime >= -1e-12
        expectedTimestamp(index) = max(0, floor((availableTime + 1e-12) / ...
            config.communication.sample_period) * config.communication.sample_period);
        expectedValid(index) = true;
    end
end
verifyEqual(testCase, simulation.packet_valid, expectedValid);
verifyEqual(testCase, simulation.packet_timestamp_s, expectedTimestamp, AbsTol=1e-12);
expectedAge = zeros(size(simulation.time_s));
expectedAge(valid) = simulation.time_s(valid) - expectedTimestamp(valid);
verifyEqual(testCase, simulation.packet_age_s, expectedAge, AbsTol=1e-12);
packetPosition = trajectory.position_m(1,:) + expectedTimestamp * velocity;
verifyEqual(testCase, simulation.zoh_command_xy_m(valid,:), packetPosition(valid,:), AbsTol=1e-12);
expectedCv = packetPosition + simulation.packet_age_s * velocity;
verifyEqual(testCase, simulation.cv_command_xy_m(valid,:), expectedCv(valid,:), AbsTol=1e-10);

holdIndex = find(simulation.time_s >= 0.10 & simulation.time_s < 0.15);
verifyEqual(testCase, simulation.zoh_command_xy_m(holdIndex,:), ...
    repmat(trajectory.position_m(1,:), numel(holdIndex), 1), AbsTol=1e-12);

config.communication.delay = 0.075;
simulation = run_case(config, trajectory, paths);
beforeBoundary = find(abs(simulation.time_s - 0.07) < 1e-12, 1);
nonIntegerBoundary = find(abs(simulation.time_s - 0.08) < 1e-12, 1);
verifyFalse(testCase, simulation.packet_valid(beforeBoundary));
verifyTrue(testCase, simulation.packet_valid(nonIntegerBoundary));
verifyEqual(testCase, simulation.packet_timestamp_s(nonIntegerBoundary), 0, AbsTol=1e-12);

config.communication.delay = 0;
simulation = run_case(config, trajectory, paths);
verifyTrue(testCase, simulation.packet_valid(1));
verifyEqual(testCase, simulation.packet_timestamp_s(1), 0, AbsTol=1e-12);
verifyEqual(testCase, simulation.packet_age_s(1), 0, AbsTol=1e-12);
verifyEqual(testCase, simulation.cv_command_xy_m, trajectory.position_m, AbsTol=1e-10);
end

function testInvalidCommunicationInputs(testCase)
config = teleopdelay.config.default_config();
config.communication.sample_period = 0;
verifyRejected(testCase, @() teleopdelay.config.validate_config(config));
config = teleopdelay.config.default_config();
config.communication.sample_period = 0.055;
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:InvalidSampleAlignment');
config = teleopdelay.config.default_config();
config.communication.sample_period = 0.005;
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:InvalidSampleAlignment');
config = teleopdelay.config.default_config();
config.simulation.fixed_step = 0.005;
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:InvalidFixedStep');
config = teleopdelay.config.default_config();
config.communication.delay = -1;
verifyRejected(testCase, @() teleopdelay.config.validate_config(config));
paths = teleopdelay.simulink.model_paths(project_root());
time_s = (0:0.01:0.10).';
trajectory = struct('time_s', time_s, 'position_m', zeros(numel(time_s), 2), ...
    'velocity_mps', zeros(numel(time_s), 2));
bad = trajectory;
bad.velocity_mps = zeros(numel(time_s), 3);
verifyError(testCase, @() teleopdelay.simulink.create_simulation_input(paths, ...
    teleopdelay.config.default_config(), bad), 'teleopDelay:InvalidTrajectoryShape');
bad = trajectory;
bad.position_m(1,1) = NaN;
verifyError(testCase, @() teleopdelay.simulink.create_simulation_input(paths, ...
    teleopdelay.config.default_config(), bad), 'teleopDelay:InvalidTrajectoryValue');
bad = trajectory;
bad.velocity_mps(1,1) = Inf;
verifyError(testCase, @() teleopdelay.simulink.create_simulation_input(paths, ...
    teleopdelay.config.default_config(), bad), 'teleopDelay:InvalidTrajectoryValue');
end

function testCommunicationBufferBoundary(testCase)
config = teleopdelay.config.default_config();
capacity = teleopdelay.config.communication_buffer_capacity();
config.communication.sample_period = config.simulation.fixed_step;
config.communication.delay = (capacity - 1) * config.communication.sample_period;
verifyTrue(testCase, teleopdelay.config.validate_config(config));
config.communication.delay = capacity * config.communication.sample_period;
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:CommunicationBufferOverflow');
config.communication.delay = (capacity - 1 + 1e-6) * config.communication.sample_period;
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:CommunicationBufferOverflow');
end

function testCommunicationModelInterface(testCase)
paths = teleopdelay.simulink.model_paths(project_root());
load_system(paths.communication);
load_system(paths.plant);
load_system(paths.system);
cleanup = onCleanup(@() close_models(paths));
verifyEqual(testCase, string(get_param(paths.communicationModelName, 'ParameterArgumentNames')), ...
    "sample_period_s,delay_s");
verifyEqual(testCase, get_param([char(paths.systemModelName) '/sampled_communication'], 'Ports'), ...
    [2 5 0 0 0 0 0 0 0 0]);
verifyEqual(testCase, string(get_param([char(paths.communicationModelName) '/position_xy_m'], 'Unit')), "m");
verifyEqual(testCase, string(get_param([char(paths.communicationModelName) '/velocity_mps'], 'Unit')), "m/s");
for blockName = ["zoh_command_xy_m", "cv_command_xy_m"]
    blockPath = [char(paths.communicationModelName) '/' char(blockName)];
    verifyEqual(testCase, string(get_param(blockPath, 'PortDimensions')), "2");
    verifyEqual(testCase, string(get_param(blockPath, 'OutDataTypeStr')), "double");
    verifyEqual(testCase, string(get_param(blockPath, 'Unit')), "m");
    verifyEqual(testCase, string(get_param(blockPath, 'SampleTime')), "-1");
end
for blockName = ["packet_timestamp_s", "packet_age_s"]
    blockPath = [char(paths.communicationModelName) '/' char(blockName)];
    verifyEqual(testCase, string(get_param(blockPath, 'PortDimensions')), "1");
    verifyEqual(testCase, string(get_param(blockPath, 'OutDataTypeStr')), "double");
    verifyEqual(testCase, string(get_param(blockPath, 'Unit')), "s");
    verifyEqual(testCase, string(get_param(blockPath, 'SampleTime')), "-1");
end
validityPath = [char(paths.communicationModelName) '/packet_valid'];
verifyEqual(testCase, string(get_param(validityPath, 'PortDimensions')), "1");
verifyEqual(testCase, string(get_param(validityPath, 'OutDataTypeStr')), "boolean");
verifyEqual(testCase, string(get_param(validityPath, 'SampleTime')), "-1");
clear cleanup;
close_models(paths);
end

function simulation = run_case(config, trajectory, paths)
simulationInput = teleopdelay.simulink.create_simulation_input(paths, config, trajectory);
simulation = teleopdelay.simulink.run_case(simulationInput, paths, config);
end

function trajectory = constant_velocity_trajectory(config, velocity)
time_s = teleopdelay.timegrid.create(config.simulation.duration, config.simulation.dt);
p0 = [0.25, -0.75];
position_m = p0 + time_s * velocity;
velocity_mps = repmat(velocity, numel(time_s), 1);
trajectory = struct('time_s', time_s, 'position_m', position_m, 'velocity_mps', velocity_mps);
end

function verifyRejected(testCase, functionHandle)
verifyTrue(testCase, did_reject(functionHandle));
end

function rejected = did_reject(functionHandle)
rejected = false;
try
    functionHandle();
catch
    rejected = true;
end
end

function root = project_root()
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

function close_models(paths)
if bdIsLoaded(paths.systemModelName), close_system(paths.systemModelName, 0); end
if bdIsLoaded(paths.communicationModelName), close_system(paths.communicationModelName, 0); end
if bdIsLoaded(paths.plantModelName), close_system(paths.plantModelName, 0); end
end
