function tests = test_trajectory
tests = functiontests(localfunctions);
end

function testCircleAtZero(testCase)
parameters = struct('type', "circle", 'amplitude', 2, 'omega', 3);
trajectory = teleopdelay.trajectory.generate([0; 0.1], parameters);
verifyEqual(testCase, trajectory.position_m(1,:), [2 0], AbsTol=1e-14);
verifyEqual(testCase, trajectory.velocity_mps(1,:), [0 6], AbsTol=1e-14);
verifyEqual(testCase, trajectory.acceleration_mps2(1,:), [-18 0], AbsTol=1e-14);
end

function testCirclePeriodAndRadius(testCase)
parameters = struct('type', "circle", 'amplitude', 1.2, 'omega', 2.5);
period = 2*pi/parameters.omega;
trajectory = teleopdelay.trajectory.generate([0; period], parameters);
verifyEqual(testCase, trajectory.position_m(1,:), trajectory.position_m(2,:), AbsTol=1e-13);
verifyEqual(testCase, vecnorm(trajectory.position_m, 2, 2), ...
    repmat(parameters.amplitude, 2, 1), AbsTol=1e-13);
end

function testCircleAnalyticDerivative(testCase)
parameters = struct('type', "circle", 'amplitude', 1, 'omega', 1.7);
dt = 1e-4;
time_s = (0:dt:2*pi).';
trajectory = teleopdelay.trajectory.generate(time_s, parameters);
finite_velocity = (trajectory.position_m(3:end,:) - trajectory.position_m(1:end-2,:)) / (2*dt);
finite_acceleration = (trajectory.velocity_mps(3:end,:) - trajectory.velocity_mps(1:end-2,:)) / (2*dt);
verifyLessThan(testCase, max(abs(finite_velocity - trajectory.velocity_mps(2:end-1,:)), [], 'all'), 1e-7);
verifyLessThan(testCase, max(abs(finite_acceleration - trajectory.acceleration_mps2(2:end-1,:)), [], 'all'), 1e-7);
end

function testLissajousAtZeroAndPeriod(testCase)
parameters = struct('type', "lissajous_1_2", 'amplitude', 2, 'omega', 1.5);
period = 2*pi/parameters.omega;
trajectory = teleopdelay.trajectory.generate([0; period], parameters);
verifyEqual(testCase, trajectory.position_m(1,:), [0 0], AbsTol=1e-14);
verifyEqual(testCase, trajectory.velocity_mps(1,:), [3 6], AbsTol=1e-14);
verifyEqual(testCase, trajectory.acceleration_mps2(1,:), [0 0], AbsTol=1e-14);
verifyEqual(testCase, trajectory.position_m(1,:), trajectory.position_m(2,:), AbsTol=1e-13);
end

function testLissajousAnalyticDerivative(testCase)
parameters = struct('type', "lissajous_1_2", 'amplitude', 1, 'omega', 1.3);
dt = 1e-4;
time_s = (0:dt:2*pi/parameters.omega).';
trajectory = teleopdelay.trajectory.generate(time_s, parameters);
finite_velocity = (trajectory.position_m(3:end,:) - trajectory.position_m(1:end-2,:)) / (2*dt);
finite_acceleration = (trajectory.velocity_mps(3:end,:) - trajectory.velocity_mps(1:end-2,:)) / (2*dt);
verifyLessThan(testCase, max(abs(finite_velocity - trajectory.velocity_mps(2:end-1,:)), [], 'all'), 2e-7);
verifyLessThan(testCase, max(abs(finite_acceleration - trajectory.acceleration_mps2(2:end-1,:)), [], 'all'), 5e-7);
end

function testTrajectoryShapeTypeAndFinite(testCase)
parameters = struct('type', "circle", 'amplitude', 1, 'omega', 1);
time_s = (0:0.1:1).';
trajectory = teleopdelay.trajectory.generate(time_s, parameters);
verifySize(testCase, trajectory.time_s, [numel(time_s) 1]);
verifySize(testCase, trajectory.position_m, [numel(time_s) 2]);
verifySize(testCase, trajectory.velocity_mps, [numel(time_s) 2]);
verifySize(testCase, trajectory.acceleration_mps2, [numel(time_s) 2]);
verifyEqual(testCase, trajectory.type, "circle");
verifyTrue(testCase, all(isfinite(trajectory.position_m), 'all'));
verifyTrue(testCase, all(isfinite(trajectory.velocity_mps), 'all'));
verifyTrue(testCase, all(isfinite(trajectory.acceleration_mps2), 'all'));
end

function testDispatcherTypeValidation(testCase)
parameters = struct('type', 'circle', 'amplitude', 1, 'omega', 1);
verifyRejected(testCase, @() teleopdelay.trajectory.generate([0; 1], parameters));
parameters.type = ["circle", "lissajous_1_2"];
verifyRejected(testCase, @() teleopdelay.trajectory.generate([0; 1], parameters));
parameters.type = "unknown";
verifyError(testCase, @() teleopdelay.trajectory.generate([0; 1], parameters), ...
    'teleopDelay:InvalidTrajectoryType');
end

function testTimeVectorValidation(testCase)
parameters = struct('type', "circle", 'amplitude', 1, 'omega', 1);
verifyRejected(testCase, @() teleopdelay.trajectory.generate([0 1], parameters));
verifyRejected(testCase, @() teleopdelay.trajectory.generate([0; 0], parameters));
verifyRejected(testCase, @() teleopdelay.trajectory.generate([1; 0], parameters));
verifyRejected(testCase, @() teleopdelay.trajectory.generate([0; NaN], parameters));
verifyRejected(testCase, @() teleopdelay.trajectory.generate([0; Inf], parameters));
verifyRejected(testCase, @() teleopdelay.trajectory.generate(0, parameters));
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
