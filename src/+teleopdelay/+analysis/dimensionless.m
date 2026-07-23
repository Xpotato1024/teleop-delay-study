function diagnostics = dimensionless(aggregate, classification, theory)
% dimensionless  Build q_delay/q_age diagnostics without collapsing Lissajous.

diagnostics = aggregate(:, {'case_id', 'trajectory', 'omega_rad_s', 'delay_s', ...
    'mean_packet_age_s', 'performance_ratio', 'improvement_percent', ...
    'omega_time_constant', 'omega_sample_period'});
diagnostics.classification = classification.classification;
diagnostics.q_delay = double(aggregate.omega_delay);
diagnostics.q_age = double(aggregate.omega_mean_packet_age);
diagnostics.q1_age = diagnostics.q_age;
diagnostics.q2_age = 2 * diagnostics.q_age;
diagnostics.theoretical_q_candidate = repmat(theory.q_candidate, height(aggregate), 1);
diagnostics.q_delay_minus_candidate = diagnostics.q_delay - theory.q_candidate;
diagnostics.q_age_minus_candidate = diagnostics.q_age - theory.q_candidate;
diagnostics = sortrows(diagnostics, {'trajectory', 'delay_s', 'omega_rad_s', 'case_id'});
end
