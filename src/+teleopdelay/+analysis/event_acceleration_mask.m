function [events, threshold] = event_acceleration_mask(acceleration, percentile)
% event_acceleration_mask  Deterministic percentile-based event selection.

acceleration = double(acceleration(:));
percentile = double(percentile);
if isempty(acceleration) || any(~isfinite(acceleration)) || ~isreal(acceleration) || ...
        ~isscalar(percentile) || ~isfinite(percentile) || ~isreal(percentile) || ...
        percentile < 0 || percentile > 100
    error("teleopDelay:AnalysisConfigInvalid", ...
        "Acceleration event inputs are invalid.");
end
sortedAcceleration = sort(acceleration);
index = max(1, min(numel(sortedAcceleration), ...
    ceil((percentile / 100) * numel(sortedAcceleration))));
threshold = sortedAcceleration(index);
events = acceleration >= threshold;
end
