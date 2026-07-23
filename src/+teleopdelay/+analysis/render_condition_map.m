function entry = render_condition_map(classification, brackets, trajectory, figureId, figuresDirectory, config)
% render_condition_map  Render a discrete index-coordinate delay-by-omega map.

layout = teleopdelay.analysis.condition_map_layout(classification, brackets, trajectory);
textContract = teleopdelay.analysis.figure_text_contract();
if string(trajectory) == "circle"
    figureText = textContract.figure_05;
else
    figureText = textContract.figure_06;
end
allG = double(classification.performance_ratio);
visual = teleopdelay.analysis.condition_map_visual_contract();
fig = figure("Visible", "off", "Color", "white", ...
    "Position", visual.figure_position);
cleanup = onCleanup(@() teleopdelay.analysis.close_figure(fig));
ax = axes(fig, "Position", visual.axes_position);
imagesc(ax, layout.omega_index, layout.delay_index, layout.map);
set(ax, "YDir", "normal", "XTick", layout.omega_index, "YTick", layout.delay_index, ...
    "XTickLabel", compose("%.3g", layout.omegas), ...
    "YTickLabel", compose("%.3g", layout.delays), "Layer", "top");
hold(ax, "on");
colormap(fig, parula(256));
colorLimits = [min(allG), max(allG)];
if colorLimits(1) == colorLimits(2)
    colorLimits = colorLimits + [-1, 1] * max(1e-12, abs(colorLimits(1)) * 1e-6);
end
clim(ax, colorLimits);
colorbarHandle = colorbar(ax);
colorbarHandle.Units = "normalized";
colorbarHandle.Position = visual.colorbar_position;
colorbarHandle.Label.String = "性能比 G = RMSE_CV / RMSE_ZOH";
colorbarHandle.Label.Interpreter = "none";
xlabel(ax, "角周波数 ω [rad/s]", "Interpreter", "none");
ylabel(ax, "通信遅延 L [s]", "Interpreter", "none");
title(ax, figureText.title, "Interpreter", "none");
xlim(ax, [0.5, numel(layout.omega_index) + 0.5]);
ylim(ax, [0.5, numel(layout.delay_index) + 0.5]);
grid(ax, "on");
for rowIndex = 1:numel(layout.delay_index)
    for columnIndex = 1:numel(layout.omega_index)
        text(ax, layout.omega_index(columnIndex), layout.delay_index(rowIndex), ...
            sprintf("%.3f", layout.map(rowIndex, columnIndex)), ...
            "HorizontalAlignment", "center", "FontSize", 10, ...
            "Color", "k", "Interpreter", "none");
    end
end
for index = 1:numel(layout.markers)
    plot(ax, layout.markers(index).x, layout.markers(index).y, "kx", ...
        "LineWidth", 1.5, "MarkerSize", 8, "HandleVisibility", "off");
end
plot(ax, nan, nan, "kx", "LineWidth", 1.5, "MarkerSize", 8, ...
    "DisplayName", "G=1を挟む隣接条件");
legendHandle = legend(ax, "Location", visual.legend_location, ...
    "Orientation", visual.legend_orientation, "Interpreter", "none");
legendHandle.Units = "normalized";
legendHandle.Location = "none";
legendHandle.Position = visual.legend_position;
fontName = teleopdelay.analysis.style_figure(fig);
metadata = struct( ...
    "trajectory", trajectory, ...
    "case_ids", strjoin(string(classification.case_id(classification.trajectory == trajectory)), "|"), ...
    "caption", figureText.caption, "metric", figureText.metric, ...
    "axes_contract", figureText.axes_contract, "font_name", fontName);
entry = teleopdelay.analysis.save_figure(fig, figuresDirectory, figureId, metadata, config.figure_dpi);
teleopdelay.analysis.close_figure(fig);
clear cleanup;
end
