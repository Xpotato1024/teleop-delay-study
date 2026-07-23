function entry = render_condition_map(classification, brackets, trajectory, figureId, figuresDirectory, config)
% render_condition_map  Render a discrete delay-by-omega G map.

omegas = sort(unique(classification.omega_rad_s));
delays = sort(unique(classification.delay_s));
allG = double(classification.performance_ratio);
map = nan(numel(delays), numel(omegas));
for rowIndex = 1:numel(delays)
    for columnIndex = 1:numel(omegas)
        match = classification.trajectory == trajectory & ...
            classification.delay_s == delays(rowIndex) & classification.omega_rad_s == omegas(columnIndex);
        map(rowIndex, columnIndex) = classification.performance_ratio(find(match, 1));
    end
end
fig = figure("Visible", "off", "Color", "white", "Position", [100, 100, 1050, 750]);
cleanup = onCleanup(@() teleopdelay.analysis.close_figure(fig));
imagesc(omegas, delays, map); set(gca, "YDir", "normal"); hold on;
colormap(fig, parula(256)); clim([min(allG), max(allG)]); colorbar;
xlabel("omega [rad/s]"); ylabel("delay [s]");
title(string(trajectory) + " discrete performance ratio map G=RMSE_{CV}/RMSE_{ZOH}");
grid on; set(gca, "Layer", "top", "XTick", omegas, "YTick", delays);
selectedBrackets = brackets(brackets.trajectory == trajectory & brackets.bracket_type ~= "nearest-G-pair", :);
omegaSpacing = min(diff(omegas));
delaySpacing = min(diff(delays));
for index = 1:height(selectedBrackets)
    lowerX = selectedBrackets.lower_omega_rad_s(index);
    lowerY = selectedBrackets.lower_delay_s(index);
    upperX = selectedBrackets.upper_omega_rad_s(index);
    upperY = selectedBrackets.upper_delay_s(index);
    if lowerX == upperX
        markerX = [lowerX, upperX] + 0.22 * omegaSpacing;
        markerY = [lowerY, upperY];
    else
        markerX = [lowerX, upperX];
        markerY = [lowerY, upperY] + 0.22 * delaySpacing;
    end
    plot(markerX, markerY, "kx", "LineWidth", 1.5, "MarkerSize", 8);
end
for rowIndex = 1:numel(delays)
    for columnIndex = 1:numel(omegas)
        text(omegas(columnIndex), delays(rowIndex), sprintf("%.3f", map(rowIndex, columnIndex)), ...
            "HorizontalAlignment", "center", "FontSize", 10, "Color", "k");
    end
end
plot(nan, nan, "kx", "LineWidth", 1.5, "MarkerSize", 8);
legend("G=1 adjacent bracket marks", "Location", "best");
teleopdelay.analysis.style_figure(fig);
caption = "Discrete 5-by-4 delay/omega grid; cell text is G and offset crosses mark adjacent G=1 brackets. No interpolated measured boundary is drawn.";
entry = teleopdelay.analysis.save_figure(fig, figuresDirectory, figureId, struct( ...
    "trajectory", trajectory, "case_ids", strjoin(string(classification.case_id(classification.trajectory == trajectory)), "|"), ...
    "caption", caption, "metric", "performance_ratio G", ...
    "axes_contract", "omega [rad/s] versus delay [s]; discrete cells only; common G scale across trajectories"), config.figure_dpi);
teleopdelay.analysis.close_figure(fig);
clear cleanup;
end
