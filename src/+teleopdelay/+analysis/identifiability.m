function diagnostics = identifiability(aggregate)
% identifiability  Record rank/collinearity without fitting causal coefficients.

omegaDelay = double(aggregate.omega_delay);
omegaAge = double(aggregate.omega_mean_packet_age);
omegaT = double(aggregate.omega_time_constant);
omegaSample = double(aggregate.omega_sample_period);
rows = cell(0, 9);
rows(end + 1, :) = diagnostic_row("all_dimensionless_predictors", ...
    "omega_delay, omega_mean_packet_age, omega_time_constant, omega_sample_period", ...
    [omegaDelay, omegaAge, omegaT, omegaSample], ...
    "The 40-case design contains fixed time constant and sample period.");
rows(end + 1, :) = diagnostic_row("time_constant_vs_sample_period", ...
    "omega_time_constant, omega_sample_period", [omegaT, omegaSample], ...
    "Both columns are omega multiplied by fixed constants; their independent effects cannot be separated.");
rows(end + 1, :) = diagnostic_row("delay_vs_mean_age", ...
    "omega_delay, omega_mean_packet_age", [omegaDelay, omegaAge], ...
    "Mean packet age includes sampling-period effects and is compared diagnostically, not treated as identical by definition.");
diagnostics = cell2table(rows, 'VariableNames', {'model', 'predictor_set', 'rank', ...
    'column_count', 'exact_collinearity', 'near_collinearity', ...
    'independently_identifiable', 'causal_contribution_identifiable', 'notes'});
diagnostics.rank = double(diagnostics.rank);
diagnostics.column_count = double(diagnostics.column_count);
diagnostics.exact_collinearity = logical(diagnostics.exact_collinearity);
diagnostics.near_collinearity = logical(diagnostics.near_collinearity);
diagnostics.independently_identifiable = logical(diagnostics.independently_identifiable);
diagnostics.causal_contribution_identifiable = logical(diagnostics.causal_contribution_identifiable);
end

function row = diagnostic_row(model, predictorSet, matrix, notes)
scaled = matrix ./ vecnorm(matrix, 2, 1);
singularValues = svd([ones(size(scaled, 1), 1), scaled], "econ");
rankTolerance = max(size(scaled)) * eps(max(1, singularValues(1))) * 1e3;
rankValue = sum(singularValues > rankTolerance);
conditionNumber = singularValues(1) / max(singularValues(end), realmin);
exact = rankValue < size(scaled, 2) + 1;
near = conditionNumber >= 1e10;
independent = ~exact && ~near;
row = {string(model), string(predictorSet), rankValue, size(matrix, 2) + 1, ...
    exact, near, independent, false, string(notes)};
end
