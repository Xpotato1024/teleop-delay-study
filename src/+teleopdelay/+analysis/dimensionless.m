function diagnostics = dimensionless(aggregate, classification, theory)
% dimensionless  Build q_delay/q_age diagnostics without collapsing Lissajous.

aggregateIds = string(aggregate.case_id);
classificationIds = string(classification.case_id);
if height(aggregate) ~= height(classification) || numel(unique(aggregateIds)) ~= height(aggregate) || ...
        numel(unique(classificationIds)) ~= height(classification) || ...
        ~isequal(sort(aggregateIds), sort(classificationIds))
    error("teleopDelay:AnalysisInputSchemaMismatch", ...
        "Aggregate and classification must contain the same unique case_id set.");
end
[isMember, classificationIndex] = ismember(aggregateIds, classificationIds);
if ~all(isMember)
    error("teleopDelay:AnalysisInputSchemaMismatch", ...
        "Every aggregate case_id must occur in classification.");
end
diagnostics = aggregate(:, {'case_id', 'trajectory', 'omega_rad_s', 'delay_s', ...
    'mean_packet_age_s', 'performance_ratio', 'improvement_percent', ...
    'omega_time_constant', 'omega_sample_period'});
diagnostics.classification = classification.classification(classificationIndex);
diagnostics.performance_ratio = double(classification.performance_ratio(classificationIndex));
diagnostics.improvement_percent = double(classification.improvement_percent(classificationIndex));
diagnostics.q_delay = double(aggregate.omega_delay);
diagnostics.q_age = double(aggregate.omega_mean_packet_age);
diagnostics.q1_age = diagnostics.q_age;
diagnostics.q2_age = 2 * diagnostics.q_age;
diagnostics.theoretical_q_candidate = repmat(theory.q_candidate, height(aggregate), 1);
diagnostics.q_delay_minus_candidate = diagnostics.q_delay - theory.q_candidate;
diagnostics.q_age_minus_candidate = diagnostics.q_age - theory.q_candidate;
diagnostics = sortrows(diagnostics, {'trajectory', 'delay_s', 'omega_rad_s', 'case_id'});
end
