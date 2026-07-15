function tests = test_config
tests = functiontests(localfunctions);
end

function testDefaultConfigSatisfiesDispatcherContract(testCase)
config = teleopdelay.config.default_config();
verifyTrue(testCase, teleopdelay.config.validate_config(config));
time_s = teleopdelay.timegrid.create(0.1, 0.05);
trajectory = teleopdelay.trajectory.generate(time_s, config.trajectory);
verifyEqual(testCase, trajectory.type, config.trajectory.type);
end

function testTrajectoryTypeRequiresExactStringScalar(testCase)
config = teleopdelay.config.default_config();
config.trajectory.type = 'circle';
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:InvalidConfig');
config.trajectory.type = ["circle", "lissajous_1_2"];
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:InvalidConfig');
config.trajectory.type = "Circle";
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:InvalidConfig');
config.trajectory = rmfield(config.trajectory, 'type');
verifyRejected(testCase, @() teleopdelay.config.validate_config(config));
end

function testSolverRequiresExactStringScalar(testCase)
config = teleopdelay.config.default_config();
config.simulation.solver = 'ode4';
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:InvalidConfig');
config.simulation.solver = ["ode4", "ode45"];
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:InvalidConfig');
config.simulation.solver = "ODE4";
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    'teleopDelay:InvalidConfig');
config.simulation = rmfield(config.simulation, 'solver');
verifyRejected(testCase, @() teleopdelay.config.validate_config(config));
end

function verifyRejected(testCase, functionHandle)
rejected = false;
try
    functionHandle();
catch
    rejected = true;
end
verifyTrue(testCase, rejected);
end
