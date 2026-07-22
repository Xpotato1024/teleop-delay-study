function metrics = tracking_metrics(config, trajectory, simulation, evaluation)
% tracking_metrics  評価window内の追従誤差とpacket ageを計算する。

teleopdelay.config.validate_config(config);
validate_time_alignment(trajectory, simulation);
requiredSignals = ["zoh_position_xy_m", "cv_position_xy_m", ...
    "reference_position_xy_m", "packet_age_s", "packet_valid"];
for signalName = requiredSignals
    if ~isfield(simulation, char(signalName))
        error("teleopDelay:InvalidMetricInput", ...
            "simulation.%s is required.", signalName);
    end
end

time_s = simulation.time_s;
sampleCount = numel(time_s);
validate_xy(simulation.zoh_position_xy_m, sampleCount, "zoh_position_xy_m");
validate_xy(simulation.cv_position_xy_m, sampleCount, "cv_position_xy_m");
validate_xy(simulation.reference_position_xy_m, sampleCount, "reference_position_xy_m");
validate_column(simulation.packet_age_s, sampleCount, "packet_age_s");
if ~(islogical(simulation.packet_valid) && iscolumn(simulation.packet_valid) && ...
        numel(simulation.packet_valid) == sampleCount)
    error("teleopDelay:InvalidMetricInput", ...
        "simulation.packet_valid must be an N-by-1 logical vector.");
end

if ~isstruct(evaluation) || ~isfield(evaluation, "mask")
    error("teleopDelay:InvalidMetricInput", ...
        "evaluation.mask is required.");
end
mask = evaluation.mask;
if ~(islogical(mask) && iscolumn(mask) && numel(mask) == sampleCount && any(mask))
    error("teleopDelay:InvalidMetricInput", ...
        "evaluation.mask must be a nonempty logical column matching simulation.");
end

reference = simulation.reference_position_xy_m;
zoh_error = simulation.zoh_position_xy_m - reference;
cv_error = simulation.cv_position_xy_m - reference;
zoh_error_norm = sqrt(sum(zoh_error.^2, 2));
cv_error_norm = sqrt(sum(cv_error.^2, 2));
rmse_zoh_m = sqrt(mean(sum(zoh_error(mask,:).^2, 2)));
rmse_cv_m = sqrt(mean(sum(cv_error(mask,:).^2, 2)));
max_error_zoh_m = max(zoh_error_norm(mask));
max_error_cv_m = max(cv_error_norm(mask));

% RMSE zero判定はdoubleのmachine precisionだけを根拠にし、任意の固定thresholdを置かない。
zero_tolerance_m = 32 * eps(max([1; abs(rmse_zoh_m); abs(rmse_cv_m)]));
zoh_is_zero = rmse_zoh_m <= zero_tolerance_m;
cv_is_zero = rmse_cv_m <= zero_tolerance_m;
if zoh_is_zero && cv_is_zero
    performance_ratio = 1.0;
    improvement_percent = 0.0;
elseif zoh_is_zero
    error("teleopDelay:UndefinedPerformanceRatio", ...
        "performance_ratio is undefined when only the ZOH RMSE is zero.");
else
    performance_ratio = rmse_cv_m / rmse_zoh_m;
    improvement_percent = (1.0 - performance_ratio) * 100.0;
end

valid_in_evaluation = mask & simulation.packet_valid;
if ~any(valid_in_evaluation)
    error("teleopDelay:NoValidPacketInEvaluation", ...
        "The evaluation window contains no valid packet sample.");
end
mean_packet_age_s = mean(simulation.packet_age_s(valid_in_evaluation));
omega = config.trajectory.omega;
metrics = struct( ...
    "rmse_zoh_m", rmse_zoh_m, ...
    "rmse_cv_m", rmse_cv_m, ...
    "nrmse_zoh", rmse_zoh_m / config.trajectory.amplitude, ...
    "nrmse_cv", rmse_cv_m / config.trajectory.amplitude, ...
    "max_error_zoh_m", max_error_zoh_m, ...
    "max_error_cv_m", max_error_cv_m, ...
    "performance_ratio", performance_ratio, ...
    "improvement_percent", improvement_percent, ...
    "mean_packet_age_s", mean_packet_age_s, ...
    "omega_delay", omega * config.communication.delay, ...
    "omega_mean_packet_age", omega * mean_packet_age_s, ...
    "omega_time_constant", omega * config.plant.time_constant, ...
    "omega_sample_period", omega * config.communication.sample_period, ...
    "zero_tolerance_m", zero_tolerance_m);
validate_metric_scalars(metrics);
end

function validate_time_alignment(trajectory, simulation)
if ~isstruct(trajectory) || ~isfield(trajectory, "time_s") || ...
        ~isstruct(simulation) || ~isfield(simulation, "time_s")
    error("teleopDelay:InvalidMetricInput", ...
        "trajectory.time_s and simulation.time_s are required.");
end
trajectoryTime = trajectory.time_s;
simulationTime = simulation.time_s;
if ~(isa(trajectoryTime, "double") && iscolumn(trajectoryTime) && ...
        all(isfinite(trajectoryTime)) && isa(simulationTime, "double") && ...
        iscolumn(simulationTime) && all(isfinite(simulationTime)) && ...
        isequal(size(trajectoryTime), size(simulationTime)))
    error("teleopDelay:InvalidMetricInput", ...
        "trajectory.time_s and simulation.time_s must be matching N-by-1 vectors.");
end
time_tolerance = 32 * eps(max([1; abs(trajectoryTime); abs(simulationTime)]));
if any(abs(trajectoryTime - simulationTime) > time_tolerance)
    error("teleopDelay:InvalidMetricInput", ...
        "trajectory.time_s and simulation.time_s must be aligned.");
end
if ~isfield(trajectory, "position_m") || ...
        ~isequal(size(trajectory.position_m), [numel(trajectoryTime), 2]) || ...
        ~isa(trajectory.position_m, "double") || ~isreal(trajectory.position_m) || ...
        ~all(isfinite(trajectory.position_m), "all")
    error("teleopDelay:InvalidMetricInput", ...
        "trajectory.position_m must be a finite N-by-2 array.");
end
end

function validate_xy(value, sampleCount, name)
if ~(isa(value, "double") && isreal(value) && ...
        isequal(size(value), [sampleCount, 2]) && all(isfinite(value), "all"))
    error("teleopDelay:InvalidMetricInput", ...
        "simulation.%s must be a finite N-by-2 double array.", name);
end
end

function validate_column(value, sampleCount, name)
if ~(isa(value, "double") && isreal(value) && ...
        isequal(size(value), [sampleCount, 1]) && all(isfinite(value)))
    error("teleopDelay:InvalidMetricInput", ...
        "simulation.%s must be a finite N-by-1 double vector.", name);
end
end

function validate_metric_scalars(metrics)
names = fieldnames(metrics);
for index = 1:numel(names)
    value = metrics.(names{index});
    if ~(isa(value, "double") && isscalar(value) && isreal(value) && isfinite(value))
        error("teleopDelay:InvalidMetricOutput", ...
            "Metric %s must be a finite real scalar.", names{index});
    end
end
end
