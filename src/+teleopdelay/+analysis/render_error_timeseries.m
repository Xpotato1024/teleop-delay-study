function entry = render_error_timeseries(input, analysis, figuresDirectory, config)
% render_error_timeseries  Render Lissajous errors and acceleration event marks.

row = analysis.tables.representative_cases( ...
    analysis.tables.representative_cases.role == "lissajous_direction_change", :);
if isempty(row)
    error("teleopDelay:AnalysisFigureDataMissing", "No Lissajous direction-change case was selected.");
end
caseResult = teleopdelay.analysis.case_by_id(input, row.case_id(1));
classificationRow = analysis.tables.case_classification( ...
    analysis.tables.case_classification.case_id == row.case_id(1), :);
mask = logical(caseResult.evaluation.mask);
t = double(caseResult.simulation.time_s(mask));
reference = caseResult.simulation.reference_position_xy_m(mask, :);
zohError = vecnorm(caseResult.simulation.zoh_position_xy_m(mask, :) - reference, 2, 2);
cvError = vecnorm(caseResult.simulation.cv_position_xy_m(mask, :) - reference, 2, 2);
acceleration = vecnorm(caseResult.trajectory.acceleration_mps2(mask, :), 2, 2);
[events, threshold] = teleopdelay.analysis.event_acceleration_mask( ...
    acceleration, config.event_acceleration_percentile);
fig = figure("Visible", "off", "Color", "white", "Position", [100, 100, 1300, 750]);
cleanup = onCleanup(@() teleopdelay.analysis.close_figure(fig));
layout = tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");
nexttile(layout);
plot(t, zohError, "Color", [0.85, 0.20, 0.15], "LineWidth", 1.1); hold on;
plot(t, cvError, "Color", [0.05, 0.30, 0.80], "LineWidth", 1.1);
scatter(t(events), zohError(events), 10, "k", "filled");
grid on; xlabel("time [s]"); ylabel("tracking error norm [m]");
legend("||x_{ZOH}-x_{ref}||", "||x_{CV}-x_{ref}||", "high-acceleration event", "Location", "best");
title("Lissajous error time series");
nexttile(layout);
plot(t, acceleration, "Color", [0.20, 0.40, 0.20], "LineWidth", 1.1); hold on;
yline(threshold, "k--", compose("%.17gth percentile threshold", config.event_acceleration_percentile));
scatter(t(events), acceleration(events), 10, "k", "filled");
grid on; xlabel("time [s]"); ylabel("acceleration magnitude [m/s^2]");
title(sprintf("direction-change diagnostic: selected case, G=%.4g", classificationRow.performance_ratio(1)));
superTitle = sgtitle(layout, "Events mark temporal coincidence only; no causal claim is made.");
superTitle.Color = [0.05, 0.05, 0.05];
teleopdelay.analysis.style_figure(fig);
caption = "Lissajous ZOH/CV error norms with deterministic acceleration threshold marks for the selected direction-change case.";
entry = teleopdelay.analysis.save_figure(fig, figuresDirectory, ...
    "figure_04_lissajous_error_timeseries", struct( ...
    "trajectory", "lissajous_1_2", "case_ids", row.case_id(1), "caption", caption, ...
    "metric", "error norm and acceleration magnitude", ...
    "axes_contract", compose("time [s], error [m], acceleration [m/s^2], %.17gth percentile event threshold", ...
    config.event_acceleration_percentile)), config.figure_dpi);
teleopdelay.analysis.close_figure(fig);
clear cleanup;
end
