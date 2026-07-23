function config = validate_config(config)
% validate_config  Validate analysis configuration contracts.

if ~isstruct(config) || ~isscalar(config) || ...
        ~all(isfield(config, ["analysis_schema_version", "event_acceleration_percentile", "convergence"]))
    error("teleopDelay:AnalysisConfigInvalid", "Analysis configuration is incomplete.");
end
percentile = double(config.event_acceleration_percentile);
if ~isreal(percentile) || ~isscalar(percentile) || ~isfinite(percentile) || ...
        percentile < 0 || percentile > 100
    error("teleopDelay:AnalysisConfigInvalid", ...
        "event_acceleration_percentile must be a finite scalar in [0, 100].");
end
requiredConvergence = ["schema_version", "base_fixed_step_s", "refined_fixed_step_s", ...
    "sample_period_s", "solver", "alignment_tolerance"];
if ~isstruct(config.convergence) || ~isscalar(config.convergence) || ...
        ~all(isfield(config.convergence, requiredConvergence))
    error("teleopDelay:AnalysisConfigInvalid", "Convergence configuration is incomplete.");
end
numericValues = [double(config.convergence.base_fixed_step_s), ...
    double(config.convergence.refined_fixed_step_s), double(config.convergence.sample_period_s), ...
    double(config.convergence.alignment_tolerance)];
if any(~isreal(numericValues)) || any(~isfinite(numericValues)) || any(numericValues <= 0) || ...
        string(config.convergence.solver) ~= "ode4"
    error("teleopDelay:AnalysisConfigInvalid", "Convergence configuration is invalid.");
end
end
