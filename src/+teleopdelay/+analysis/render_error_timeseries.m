function entry = render_error_timeseries(input, analysis, figuresDirectory, config)
% render_error_timeseries  Render errors and shared high-acceleration events.

row = analysis.tables.representative_cases( ...
    analysis.tables.representative_cases.role == "lissajous_direction_change", :);
if isempty(row)
    error("teleopDelay:AnalysisFigureDataMissing", "No Lissajous direction-change case was selected.");
end
caseResult = teleopdelay.analysis.case_by_id(input, row.case_id(1));
mask = logical(caseResult.evaluation.mask);
t = double(caseResult.simulation.time_s(mask));
reference = caseResult.simulation.reference_position_xy_m(mask, :);
zohError = vecnorm(caseResult.simulation.zoh_position_xy_m(mask, :) - reference, 2, 2);
cvError = vecnorm(caseResult.simulation.cv_position_xy_m(mask, :) - reference, 2, 2);
acceleration = vecnorm(caseResult.trajectory.acceleration_mps2(mask, :), 2, 2);
[events, threshold] = teleopdelay.analysis.event_acceleration_mask( ...
    acceleration, config.event_acceleration_percentile);
textContract = teleopdelay.analysis.figure_text_contract();
eventContract = teleopdelay.analysis.event_display_contract();
fig = figure("Visible", "off", "Color", "white", "Position", [100, 100, 1300, 750]);
cleanup = onCleanup(@() teleopdelay.analysis.close_figure(fig));
layout = tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");
nexttile(layout);
plot(t, zohError, "Color", [0.85, 0.20, 0.15], "LineWidth", 1.1, ...
    "DisplayName", "ZOH追従誤差");
hold on;
plot(t, cvError, "Color", [0.05, 0.30, 0.80], "LineWidth", 1.1, ...
    "DisplayName", "CV追従誤差");
upperLimits = ylim;
upperRange = max(diff(upperLimits), eps(max(abs(upperLimits))));
rugY = upperLimits(1) + 0.03 * upperRange;
plot(t(events), repmat(rugY, sum(events), 1), "k|", "MarkerSize", 10, ...
    "LineWidth", 1.2, "DisplayName", eventContract.upper_label);
grid on;
xlabel("時刻 [s]", "Interpreter", "none");
ylabel("追従誤差ノルム [m]", "Interpreter", "none");
title(textContract.figure_04.upper_title, "Interpreter", "none");
legend("Location", "best", "Interpreter", "none");
nexttile(layout);
plot(t, acceleration, "Color", [0.20, 0.40, 0.20], "LineWidth", 1.1, ...
    "DisplayName", "目標加速度");
hold on;
yline(threshold, "k--", sprintf("%.0fパーセンタイル閾値", config.event_acceleration_percentile), ...
    "DisplayName", eventContract.percentile_label);
plot(t(events), acceleration(events), "k.", "MarkerSize", 12, ...
    "DisplayName", eventContract.lower_label);
grid on;
xlabel("時刻 [s]", "Interpreter", "none");
ylabel("加速度ノルム [m/s^2]", "Interpreter", "none");
title(textContract.figure_04.lower_title, "Interpreter", "none");
legend("Location", "best", "Interpreter", "none");
superTitle = sgtitle(layout, textContract.figure_04.title);
superTitle.Color = [0.05, 0.05, 0.05];
annotation(fig, "textbox", [0.12, 0.205, 0.76, 0.025], ...
    "String", eventContract.note, "EdgeColor", "none", ...
    "HorizontalAlignment", "center", "FontSize", 8, "Interpreter", "none");
fontName = teleopdelay.analysis.style_figure(fig);
metadata = struct( ...
    "trajectory", "lissajous_1_2", "case_ids", row.case_id(1), ...
    "caption", textContract.figure_04.caption, "metric", textContract.figure_04.metric, ...
    "axes_contract", textContract.figure_04.axes_contract, "font_name", fontName);
entry = teleopdelay.analysis.save_figure(fig, figuresDirectory, ...
    "figure_04_lissajous_error_timeseries", metadata, config.figure_dpi);
teleopdelay.analysis.close_figure(fig);
clear cleanup;
end
