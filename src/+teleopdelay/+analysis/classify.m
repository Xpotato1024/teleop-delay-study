function classification = classify(aggregate, boundaryTolerance)
% classify  Classify CV performance by G=rmse_cv/rmse_zoh.

if ~istable(aggregate) || ~isscalar(boundaryTolerance) || ...
        ~isreal(boundaryTolerance) || ~isfinite(boundaryTolerance) || boundaryTolerance < 0
    error("teleopDelay:AnalysisInputMetricInvalid", "Invalid classification input.");
end
G = double(aggregate.performance_ratio);
if any(~isfinite(G))
    error("teleopDelay:AnalysisInputMetricInvalid", "performance_ratio must be finite.");
end
classification = aggregate;
classification.boundary_tolerance = repmat(double(boundaryTolerance), height(aggregate), 1);
classification.classification = strings(height(aggregate), 1);
classification.classification(G < 1 - boundaryTolerance) = "improvement";
classification.classification(abs(G - 1) <= boundaryTolerance) = "equivalent";
classification.classification(G > 1 + boundaryTolerance) = "degradation";
classification.boundary_distance = abs(G - 1);
classification.improvement_sign_consistent = ...
    abs(double(aggregate.improvement_percent) - (1 - G) * 100) <= ...
    64 * eps(max(1, abs(double(aggregate.improvement_percent))));
if any(~classification.improvement_sign_consistent)
    error("teleopDelay:AnalysisInputSchemaMismatch", ...
        "improvement_percent is not sign-consistent with performance_ratio.");
end
classification = sortrows(classification, {'trajectory', 'delay_s', 'omega_rad_s', 'case_id'});
end
