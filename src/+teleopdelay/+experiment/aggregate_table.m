function aggregate = aggregate_table(manifest, caseResults)
% aggregate_table  Convert per-case outputs into the fixed Issue #8 schema.

teleopdelay.experiment.validate_manifest(manifest);
if ~iscell(caseResults) || numel(caseResults) ~= manifest.case_count
    error("teleopDelay:ExperimentAggregationInvalidInput", ...
        "caseResults must contain one entry for every manifest case.");
end

n = manifest.case_count;
caseId = strings(n, 1);
trajectory = strings(n, 1);
omega_rad_s = zeros(n, 1);
delay_s = zeros(n, 1);
sample_period_s = zeros(n, 1);
time_constant_s = zeros(n, 1);
fixed_step_s = zeros(n, 1);
duration_s = zeros(n, 1);
warmup_cycles = zeros(n, 1);
evaluation_start_s = nan(n, 1);
evaluation_end_s = nan(n, 1);
omega_delay = zeros(n, 1);
mean_packet_age_s = nan(n, 1);
omega_mean_packet_age = nan(n, 1);
omega_time_constant = zeros(n, 1);
omega_sample_period = zeros(n, 1);
rmse_zoh_m = nan(n, 1);
rmse_cv_m = nan(n, 1);
nrmse_zoh = nan(n, 1);
nrmse_cv = nan(n, 1);
max_error_zoh_m = nan(n, 1);
max_error_cv_m = nan(n, 1);
performance_ratio = nan(n, 1);
improvement_percent = nan(n, 1);
status = strings(n, 1);
error_identifier = strings(n, 1);
error_message = strings(n, 1);

for index = 1:n
    definition = manifest.cases(index);
    caseId(index) = definition.case_id;
    trajectory(index) = definition.trajectory;
    omega_rad_s(index) = definition.omega_rad_s;
    delay_s(index) = definition.delay_s;
    sample_period_s(index) = definition.sample_period_s;
    time_constant_s(index) = definition.time_constant_s;
    fixed_step_s(index) = definition.fixed_step_s;
    duration_s(index) = definition.duration_s;
    warmup_cycles(index) = definition.warmup_cycles;
    omega_delay(index) = definition.omega_rad_s * definition.delay_s;
    omega_time_constant(index) = definition.omega_rad_s * definition.time_constant_s;
    omega_sample_period(index) = definition.omega_rad_s * definition.sample_period_s;

    result = caseResults{index};
    if ~isstruct(result) || ~isfield(result, "status")
        error("teleopDelay:ExperimentAggregationInvalidInput", ...
            "Each case result must contain a status field.");
    end
    status(index) = string(result.status);
    if isfield(result, "error_identifier")
        error_identifier(index) = string(result.error_identifier);
    end
    if isfield(result, "error_message")
        error_message(index) = string(result.error_message);
    end
    if status(index) ~= "success"
        continue;
    end
    if ~all(isfield(result, ["simulation", "evaluation"]))
        error("teleopDelay:ExperimentAggregationInvalidInput", ...
            "A successful case result must contain simulation and evaluation.");
    end
    simulation = result.simulation;
    evaluation = result.evaluation;
    duration_s(index) = simulation.time_s(end);
    evaluation_start_s(index) = evaluation.sample_start_s;
    evaluation_end_s(index) = evaluation.sample_end_s;
    mean_packet_age_s(index) = evaluation.mean_packet_age_s;
    omega_mean_packet_age(index) = evaluation.omega_mean_packet_age;
    rmse_zoh_m(index) = evaluation.rmse_zoh_m;
    rmse_cv_m(index) = evaluation.rmse_cv_m;
    nrmse_zoh(index) = evaluation.nrmse_zoh;
    nrmse_cv(index) = evaluation.nrmse_cv;
    max_error_zoh_m(index) = evaluation.max_error_zoh_m;
    max_error_cv_m(index) = evaluation.max_error_cv_m;
    performance_ratio(index) = evaluation.performance_ratio;
    improvement_percent(index) = evaluation.improvement_percent;
end

variableNames = { ...
    "case_id", "trajectory", "omega_rad_s", "delay_s", ...
    "sample_period_s", "time_constant_s", "fixed_step_s", "duration_s", ...
    "warmup_cycles", "evaluation_start_s", "evaluation_end_s", ...
    "omega_delay", "mean_packet_age_s", "omega_mean_packet_age", ...
    "omega_time_constant", "omega_sample_period", "rmse_zoh_m", ...
    "rmse_cv_m", "nrmse_zoh", "nrmse_cv", "max_error_zoh_m", ...
    "max_error_cv_m", "performance_ratio", "improvement_percent", ...
    "status", "error_identifier", "error_message"};
aggregate = table(caseId, trajectory, omega_rad_s, delay_s, sample_period_s, ...
    time_constant_s, fixed_step_s, duration_s, warmup_cycles, ...
    evaluation_start_s, evaluation_end_s, omega_delay, mean_packet_age_s, ...
    omega_mean_packet_age, omega_time_constant, omega_sample_period, ...
    rmse_zoh_m, rmse_cv_m, nrmse_zoh, nrmse_cv, max_error_zoh_m, ...
    max_error_cv_m, performance_ratio, improvement_percent, status, ...
    error_identifier, error_message, 'VariableNames', cellstr(string(variableNames)));
end
