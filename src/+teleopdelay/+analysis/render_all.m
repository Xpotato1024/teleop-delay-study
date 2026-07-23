function manifest = render_all(input, analysis, figuresDirectory, config)
% render_all  Render the fixed eight-figure Issue #9 set.

if ~isfolder(figuresDirectory)
    mkdir(figuresDirectory);
end
entries = cell(8, 1);
entries{1} = teleopdelay.analysis.render_system_architecture(figuresDirectory, config);
entries{2} = teleopdelay.analysis.render_trajectory(input, analysis, ...
    "circle", "figure_02_representative_circle", figuresDirectory, config);
entries{3} = teleopdelay.analysis.render_trajectory(input, analysis, ...
    "lissajous_1_2", "figure_03_representative_lissajous", figuresDirectory, config);
entries{4} = teleopdelay.analysis.render_error_timeseries(input, analysis, figuresDirectory, config);
entries{5} = teleopdelay.analysis.render_condition_map( ...
    analysis.tables.case_classification, analysis.tables.boundary_brackets, ...
    "circle", "figure_05_circle_delay_omega_map", figuresDirectory, config);
entries{6} = teleopdelay.analysis.render_condition_map( ...
    analysis.tables.case_classification, analysis.tables.boundary_brackets, ...
    "lissajous_1_2", "figure_06_lissajous_delay_omega_map", figuresDirectory, config);
entries{7} = teleopdelay.analysis.render_dimensionless( ...
    analysis.tables.dimensionless_diagnostics, analysis.theory, ...
    "omega_delay", "figure_07_performance_vs_omega_delay", figuresDirectory, config);
entries{8} = teleopdelay.analysis.render_dimensionless( ...
    analysis.tables.dimensionless_diagnostics, analysis.theory, ...
    "q_age", "figure_08_performance_vs_omega_mean_packet_age", figuresDirectory, config);
manifest = entries_to_table(entries);
end

function manifest = entries_to_table(entries)
names = fieldnames(entries{1});
manifest = table();
for name = names.'
    values = cellfun(@(entry) entry.(name{1}), entries);
    if islogical(values)
        manifest.(name{1}) = logical(values);
    elseif isnumeric(values)
        manifest.(name{1}) = double(values);
    else
        manifest.(name{1}) = string(values);
    end
end
manifest = sortrows(manifest, "figure_id");
end
