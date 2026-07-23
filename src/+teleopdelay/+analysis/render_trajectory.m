function entry = render_trajectory(input, analysis, trajectory, figureId, figuresDirectory, config)
% render_trajectory  Render deterministic reference/ZOH/CV representative paths.

roles = analysis.tables.representative_cases( ...
    analysis.tables.representative_cases.trajectory == trajectory & ...
    (analysis.tables.representative_cases.role == "best_improvement" | ...
     startsWith(analysis.tables.representative_cases.role, "worst_degradation") | ...
     analysis.tables.representative_cases.role == "nearest_boundary"), :);
orderedRoles = ["best_improvement", "worst_degradation", "worst_degradation_fallback", "nearest_boundary"];
selected = strings(0, 1);
selectedRoles = strings(0, 1);
for role = orderedRoles
    row = roles(roles.role == role, :);
    if ~isempty(row) && ~ismember(row.case_id, selected)
        selected(end + 1) = row.case_id; %#ok<AGROW>
        selectedRoles(end + 1) = row.role; %#ok<AGROW>
    end
end
if isempty(selected)
    error("teleopDelay:AnalysisFigureDataMissing", "No representative path case was selected for %s.", trajectory);
end
fig = figure("Visible", "off", "Color", "white", "Position", [100, 100, 1400, 650]);
cleanup = onCleanup(@() close(fig));
layout = tiledlayout(1, numel(selected), "TileSpacing", "compact", "Padding", "compact");
allPositions = [];
for index = 1:numel(selected)
    caseResult = teleopdelay.analysis.case_by_id(input, selected(index));
    allPositions = [allPositions; caseResult.simulation.reference_position_xy_m; ...
        caseResult.simulation.zoh_position_xy_m; caseResult.simulation.cv_position_xy_m]; %#ok<AGROW>
end
limits = [min(allPositions, [], 1), max(allPositions, [], 1)];
margin = max(0.05, 0.05 * max(limits(3:4) - limits(1:2)));
for index = 1:numel(selected)
    nexttile(layout);
    caseResult = teleopdelay.analysis.case_by_id(input, selected(index));
    reference = caseResult.simulation.reference_position_xy_m;
    plot(reference(:, 1), reference(:, 2), "k--", "LineWidth", 1.4); hold on;
    plot(caseResult.simulation.zoh_position_xy_m(:, 1), caseResult.simulation.zoh_position_xy_m(:, 2), ...
        "Color", [0.85, 0.20, 0.15], "LineWidth", 1.1);
    plot(caseResult.simulation.cv_position_xy_m(:, 1), caseResult.simulation.cv_position_xy_m(:, 2), ...
        "Color", [0.05, 0.30, 0.80], "LineWidth", 1.1);
    plot(reference(1, 1), reference(1, 2), "o", "MarkerFaceColor", [0.1, 0.6, 0.2], ...
        "MarkerEdgeColor", "none", "MarkerSize", 7);
    plot(reference(end, 1), reference(end, 2), "s", "MarkerFaceColor", [0.9, 0.5, 0.0], ...
        "MarkerEdgeColor", "none", "MarkerSize", 6);
    axis equal; xlim(limits([1, 3]) + [-margin, margin]); ylim(limits([2, 4]) + [-margin, margin]);
    grid on; xlabel("x [m]"); ylabel("y [m]");
    row = analysis.tables.case_classification( ...
        analysis.tables.case_classification.case_id == selected(index), :);
    title(sprintf("%s\nG=%.4g, delay=%.2g s, omega=%.2g rad/s", ...
        strrep(selectedRoles(index), "_", " "), row.performance_ratio, ...
        row.delay_s, row.omega_rad_s), "Interpreter", "tex");
    if index == 1
        legend("reference", "ZOH", "CV", "start", "end", "Location", "best");
    end
end
sgtitle(layout, string(trajectory) + " representative trajectories");
caption = "Reference, ZOH, and CV plant paths for automatically selected " + ...
    string(trajectory) + " cases; green circle=start and orange square=end.";
entry = teleopdelay.analysis.save_figure(fig, figuresDirectory, figureId, struct( ...
    "trajectory", trajectory, "case_ids", strjoin(selected, "|"), "caption", caption, ...
    "metric", "reference/ZOH/CV trajectory position", ...
    "axes_contract", "x [m], y [m], equal aspect ratio, start/end markers"), config.figure_dpi);
clear cleanup;
end
