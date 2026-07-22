function duration_s = grid_aligned_duration(nominal_end_s, fixed_step_s)
% grid_aligned_duration  固定gridでnominal endを覆う最小のendpointを返す。

validate_scalar(nominal_end_s, "nominal_end_s", false);
validate_scalar(fixed_step_s, "fixed_step_s", true);
if nominal_end_s < 0
    error("teleopDelay:InvalidEvaluationWindow", ...
        "nominal_end_s must be nonnegative.");
end

step_count = nominal_end_s / fixed_step_s;
nearest_step = round(step_count);
% これはgrid境界の丸めだけを吸収するmachine-precision toleranceである。
grid_tolerance = 16 * eps(max(1, abs(step_count)));
if abs(step_count - nearest_step) <= grid_tolerance
    step_count = nearest_step;
else
    step_count = ceil(step_count);
end
duration_s = step_count * fixed_step_s;
if ~isfinite(duration_s) || ~isreal(duration_s)
    error("teleopDelay:InvalidEvaluationWindow", ...
        "The grid-aligned duration must be finite and real.");
end
end

function validate_scalar(value, name, mustBePositive)
if ~(isa(value, "double") && isscalar(value) && isreal(value) && isfinite(value))
    error("teleopDelay:InvalidEvaluationWindow", ...
        "%s must be a finite real double scalar.", name);
end
if mustBePositive && value <= 0
    error("teleopDelay:InvalidEvaluationWindow", ...
        "%s must be positive.", name);
end
end
