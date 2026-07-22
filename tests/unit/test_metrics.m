function tests = test_metrics
tests = functiontests(localfunctions);
end

function testEvaluationConfigValidation(testCase)
config = fixture_config();
verifyTrue(testCase, teleopdelay.config.validate_config(config));
config.evaluation.total_cycles = 0;
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    "teleopDelay:InvalidEvaluationConfig");
config = fixture_config();
config.evaluation.warmup_cycles = config.evaluation.total_cycles;
verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
    "teleopDelay:InvalidEvaluationConfig");
for value = [-1, 1.5, NaN, Inf]
    config = fixture_config();
    config.evaluation.warmup_cycles = value;
    verifyError(testCase, @() teleopdelay.config.validate_config(config), ...
        "teleopDelay:InvalidEvaluationConfig");
end
end

function testPeriodAndGridAlignedDuration(testCase)
config = fixture_config();
verifyEqual(testCase, 2 * pi / config.trajectory.omega, 1.0, AbsTol=1e-14);
verifyEqual(testCase, teleopdelay.metrics.grid_aligned_duration(2.0, 0.1), ...
    2.0, AbsTol=0);
verifyEqual(testCase, teleopdelay.metrics.grid_aligned_duration(1.86, 0.1), ...
    1.9, AbsTol=1e-14);
end

function testGridBoundariesAndSampleInclusion(testCase)
config = fixture_config();
[trajectory, simulation] = fixture_signals((0:0.1:2).');
evaluation = teleopdelay.metrics.build_evaluation_window(config, trajectory, simulation);
verifyEqual(testCase, evaluation.period_s, 1.0, AbsTol=1e-14);
verifyEqual(testCase, evaluation.nominal_start_s, 1.0, AbsTol=1e-14);
verifyEqual(testCase, evaluation.nominal_end_s, 2.0, AbsTol=1e-14);
verifyEqual(testCase, evaluation.sample_start_s, 1.0, AbsTol=0);
verifyEqual(testCase, evaluation.sample_end_s, 2.0, AbsTol=0);
verifyEqual(testCase, evaluation.sample_count, 11);
verifyTrue(testCase, evaluation.mask(11));
verifyTrue(testCase, evaluation.mask(end));
verifyFalse(testCase, evaluation.mask(10));

config.trajectory.omega = 2 * pi / 0.93;
config.simulation.duration = teleopdelay.metrics.grid_aligned_duration( ...
    config.evaluation.total_cycles * 2 * pi / config.trajectory.omega, 0.1);
teleopdelay.config.validate_config(config);
evaluation = teleopdelay.metrics.build_evaluation_window(config, trajectory, simulation);
verifyEqual(testCase, evaluation.nominal_start_s, 0.93, AbsTol=1e-14);
verifyEqual(testCase, evaluation.nominal_end_s, 1.86, AbsTol=1e-14);
verifyEqual(testCase, evaluation.sample_start_s, 1.0, AbsTol=1e-14);
verifyEqual(testCase, evaluation.sample_end_s, 1.8, AbsTol=1e-14);
verifyEqual(testCase, evaluation.sample_count, 9);
verifyFalse(testCase, evaluation.mask(10));
end

function testEvaluationCoverageAndEmptyWindowRejection(testCase)
config = fixture_config();
[trajectory, simulation] = fixture_signals((0:0.1:1.9).');
verifyError(testCase, @() teleopdelay.metrics.build_evaluation_window( ...
    config, trajectory, simulation), "teleopDelay:EvaluationWindowOutOfRange");

[trajectory, simulation] = fixture_signals([0; 3]);
verifyError(testCase, @() teleopdelay.metrics.build_evaluation_window( ...
    config, trajectory, simulation), "teleopDelay:EmptyEvaluationWindow");
end

function testTrackingMetricsAgainstHandCalculation(testCase)
config = fixture_config();
config.trajectory.amplitude = 2.0;
[trajectory, simulation] = fixture_signals((0:0.5:2).');
simulation.zoh_position_xy_m = [1, 0; 1, 0; 1, 0; 0, 2; 0, 0];
simulation.cv_position_xy_m = [0.5, 0; 0.5, 0; 0.5, 0; 0, 1; 0, 0];
simulation.packet_age_s = [0; 0; 0.2; 0.3; 0.4];
simulation.packet_valid = [false; false; true; true; true];
evaluation = teleopdelay.metrics.build_evaluation_window(config, trajectory, simulation);
metrics = teleopdelay.metrics.tracking_metrics(config, trajectory, simulation, evaluation);
verifyEqual(testCase, metrics.rmse_zoh_m, sqrt(5 / 3), AbsTol=1e-14);
verifyEqual(testCase, metrics.rmse_cv_m, sqrt(1.25 / 3), AbsTol=1e-14);
verifyEqual(testCase, metrics.nrmse_zoh, sqrt(5 / 3) / 2, AbsTol=1e-14);
verifyEqual(testCase, metrics.nrmse_cv, sqrt(1.25 / 3) / 2, AbsTol=1e-14);
verifyEqual(testCase, metrics.max_error_zoh_m, 2.0, AbsTol=1e-14);
verifyEqual(testCase, metrics.max_error_cv_m, 1.0, AbsTol=1e-14);
verifyEqual(testCase, metrics.performance_ratio, 0.5, AbsTol=1e-14);
verifyEqual(testCase, metrics.improvement_percent, 50.0, AbsTol=1e-12);
verifyEqual(testCase, metrics.mean_packet_age_s, 0.3, AbsTol=1e-14);
verifyEqual(testCase, metrics.omega_delay, 2 * pi * 0.1, AbsTol=1e-14);
verifyEqual(testCase, metrics.omega_mean_packet_age, 2 * pi * 0.3, AbsTol=1e-14);
verifyEqual(testCase, metrics.omega_time_constant, 2 * pi * 0.2, AbsTol=1e-14);
verifyEqual(testCase, metrics.omega_sample_period, 2 * pi * 0.1, AbsTol=1e-14);
end

function testPacketValidityIsFailClosed(testCase)
config = fixture_config();
[trajectory, simulation] = fixture_signals((0:0.5:2).');
evaluation = teleopdelay.metrics.build_evaluation_window(config, trajectory, simulation);

simulation.packet_valid(:) = true;
metrics = teleopdelay.metrics.tracking_metrics(config, trajectory, simulation, evaluation);
verifyTrue(testCase, isfinite(metrics.rmse_zoh_m));

simulation.packet_valid(:) = false;
verifyError(testCase, @() teleopdelay.metrics.tracking_metrics( ...
    config, trajectory, simulation, evaluation), ...
    "teleopDelay:NoValidPacketInEvaluation");

simulation.packet_valid(:) = true;
simulation.packet_valid(find(evaluation.mask, 1)) = false;
verifyError(testCase, @() teleopdelay.metrics.tracking_metrics( ...
    config, trajectory, simulation, evaluation), ...
    "teleopDelay:IncompletePacketHistoryInEvaluation");

simulation.packet_valid(:) = true;
simulation.packet_age_s(evaluation.mask) = -eps;
verifyError(testCase, @() teleopdelay.metrics.tracking_metrics( ...
    config, trajectory, simulation, evaluation), ...
    "teleopDelay:InvalidPacketAgeInEvaluation");
end

function testCircleAndLissajousUseTheSameFixedGridEvaluationContract(testCase)
config = fixture_config();
time_s = (0:0.1:2).';
expected_mask = false(numel(time_s), 1);
expected_mask(11:21) = true;
for trajectory_type = ["circle", "lissajous_1_2"]
    config.trajectory.type = trajectory_type;
    trajectory = teleopdelay.trajectory.generate(time_s, config.trajectory);
    [~, simulation] = fixture_signals(time_s);
    evaluation_window = teleopdelay.metrics.build_evaluation_window( ...
        config, trajectory, simulation);
    tracking = teleopdelay.metrics.tracking_metrics( ...
        config, trajectory, simulation, evaluation_window);
    evaluation = merge_structs(evaluation_window, tracking);

    verifyEqual(testCase, evaluation.nominal_end_s - evaluation.nominal_start_s, ...
        (config.evaluation.total_cycles - config.evaluation.warmup_cycles) * 1.0, ...
        AbsTol=1e-14);
    verifyEqual(testCase, evaluation.mask, expected_mask);
    verifyEqual(testCase, evaluation.sample_count, 11);
    verifyEqual(testCase, evaluation.sample_start_s, 1.0, AbsTol=0);
    verifyEqual(testCase, evaluation.sample_end_s, 2.0, AbsTol=0);
    verifyFalse(testCase, any(evaluation.mask(1:10)));
    verifyTrue(testCase, all(evaluation.mask(11:21)));
    required_metrics = ["rmse_zoh_m", "rmse_cv_m", "nrmse_zoh", ...
        "nrmse_cv", "max_error_zoh_m", "max_error_cv_m", ...
        "performance_ratio", "improvement_percent", "mean_packet_age_s", ...
        "omega_delay", "omega_mean_packet_age", "omega_time_constant", ...
        "omega_sample_period"];
    for name = required_metrics
        verifyTrue(testCase, isscalar(evaluation.(char(name))) && ...
            isreal(evaluation.(char(name))) && isfinite(evaluation.(char(name))));
    end
end
end

function combined = merge_structs(first, second)
combined = first;
names = fieldnames(second);
for index = 1:numel(names)
    combined.(names{index}) = second.(names{index});
end
end

function testZeroDenominatorContracts(testCase)
config = fixture_config();
[trajectory, simulation] = fixture_signals((0:0.5:2).');
evaluation = teleopdelay.metrics.build_evaluation_window(config, trajectory, simulation);
simulation.packet_valid(:) = true;
metrics = teleopdelay.metrics.tracking_metrics(config, trajectory, simulation, evaluation);
verifyEqual(testCase, metrics.performance_ratio, 1.0);
verifyEqual(testCase, metrics.improvement_percent, 0.0);
simulation.cv_position_xy_m(evaluation.mask, 1) = 1e-3;
verifyError(testCase, @() teleopdelay.metrics.tracking_metrics( ...
    config, trajectory, simulation, evaluation), ...
    "teleopDelay:UndefinedPerformanceRatio");
end

function testInvalidMetricInputsAndPacketAgeContract(testCase)
config = fixture_config();
[trajectory, simulation] = fixture_signals((0:0.5:2).');
evaluation = teleopdelay.metrics.build_evaluation_window(config, trajectory, simulation);
simulation.reference_position_xy_m(1, 1) = NaN;
verifyError(testCase, @() teleopdelay.metrics.tracking_metrics( ...
    config, trajectory, simulation, evaluation), "teleopDelay:InvalidMetricInput");
simulation.reference_position_xy_m(1, 1) = 0;
simulation.packet_valid(:) = false;
verifyError(testCase, @() teleopdelay.metrics.tracking_metrics( ...
    config, trajectory, simulation, evaluation), ...
    "teleopDelay:NoValidPacketInEvaluation");
simulation.packet_valid(:) = true;
simulation.zoh_position_xy_m = zeros(numel(simulation.time_s), 3);
verifyError(testCase, @() teleopdelay.metrics.tracking_metrics( ...
    config, trajectory, simulation, evaluation), "teleopDelay:InvalidMetricInput");
end

function config = fixture_config()
config = teleopdelay.config.default_config();
config.simulation.dt = 0.1;
config.simulation.fixed_step = 0.1;
config.simulation.duration = 2.0;
config.communication.sample_period = 0.1;
config.communication.delay = 0.1;
config.trajectory.omega = 2 * pi;
config.evaluation.total_cycles = 2;
config.evaluation.warmup_cycles = 1;
teleopdelay.config.validate_config(config);
end

function [trajectory, simulation] = fixture_signals(time_s)
time_s = double(time_s(:));
N = numel(time_s);
trajectory = struct("time_s", time_s, "position_m", zeros(N, 2), ...
    "velocity_mps", zeros(N, 2));
simulation = struct("time_s", time_s, ...
    "zoh_position_xy_m", zeros(N, 2), ...
    "cv_position_xy_m", zeros(N, 2), ...
    "reference_position_xy_m", zeros(N, 2), ...
    "packet_age_s", zeros(N, 1), ...
    "packet_valid", true(N, 1));
end
