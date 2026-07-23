function entry = render_dimensionless(diagnostics, theory, metric, figureId, figuresDirectory, config)
% render_dimensionless  Render G against delay- and age-based dimensionless axes.

if metric == "omega_delay"
    xLabel = "omega*delay";
    metricName = "q_delay";
else
    xLabel = "omega*mean packet age";
    metricName = "q_age";
end
fig = figure("Visible", "off", "Color", "white", "Position", [100, 100, 1250, 700]);
cleanup = onCleanup(@() close(fig));
layout = tiledlayout(1, 2, "TileSpacing", "compact", "Padding", "compact");
trajectoryNames = ["circle", "lissajous_1_2"];
colors = struct("improvement", [0.10, 0.50, 0.20], "equivalent", [0.85, 0.50, 0.05], ...
    "degradation", [0.75, 0.10, 0.10]);
for panel = 1:2
    trajectory = trajectoryNames(panel);
    nexttile(layout); hold on;
    subset = diagnostics(diagnostics.trajectory == trajectory, :);
    if metric == "omega_delay"
        subsetX = double(subset.q_delay);
    else
        subsetX = double(subset.q_age);
    end
    for label = ["improvement", "equivalent", "degradation"]
        selected = subset.classification == label;
        scatter(subsetX(selected), ...
            subset.performance_ratio(selected), 42, colors.(char(label)), "filled", ...
            "DisplayName", label);
    end
    yline(1, "k--", "G=1", "HandleVisibility", "off");
    if trajectory == "circle"
        xline(theory.q_candidate, "Color", [0.2, 0.2, 0.2], "LineStyle", ":", ...
            "DisplayName", "ideal q candidate");
    else
        xline(theory.q_candidate / 2, "Color", [0.45, 0.15, 0.55], "LineStyle", ":", ...
            "DisplayName", "q2=2q candidate");
        xline(theory.q_candidate, "Color", [0.2, 0.2, 0.2], "LineStyle", "-.", ...
            "DisplayName", "q1 candidate");
    end
    grid on; xlabel(xLabel); ylabel("performance ratio G"); title(trajectory, "Interpreter", "none");
    legend("Location", "best");
end
sgtitle(layout, "Dimensionless organization: " + metricName + " (theory lines are ideal candidates only)");
caption = "G against " + xLabel + " for circle and 1:2 Lissajous. The ideal sinusoid candidate is a comparison line, not an empirical boundary.";
entry = teleopdelay.analysis.save_figure(fig, figuresDirectory, figureId, struct( ...
    "trajectory", "circle|lissajous_1_2", ...
    "case_ids", strjoin(string(diagnostics.case_id), "|"), "caption", caption, ...
    "metric", "performance_ratio G versus " + metricName, ...
    "axes_contract", xLabel + ", G dimensionless, horizontal G=1, trajectory panels, ideal candidate lines"), config.figure_dpi);
clear cleanup;
end
