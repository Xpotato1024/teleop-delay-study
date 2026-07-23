function entry = render_dimensionless(diagnostics, theory, metric, figureId, figuresDirectory, config)
% render_dimensionless  Render G against delay- and age-based dimensionless axes.

if metric == "omega_delay"
    xLabel = "無次元通信遅延 ωL";
    figureText = teleopdelay.analysis.figure_text_contract().figure_07;
else
    xLabel = "ω × 平均パケット齢";
    figureText = teleopdelay.analysis.figure_text_contract().figure_08;
end
fig = figure("Visible", "off", "Color", "white", "Position", [100, 100, 1250, 700]);
cleanup = onCleanup(@() teleopdelay.analysis.close_figure(fig));
layout = tiledlayout(1, 2, "TileSpacing", "compact", "Padding", "compact");
trajectoryNames = ["circle", "lissajous_1_2"];
colors = struct("improvement", [0.10, 0.50, 0.20], "equivalent", [0.85, 0.50, 0.05], ...
    "degradation", [0.75, 0.10, 0.10]);
for panel = 1:2
    trajectory = trajectoryNames(panel);
    nexttile(layout);
    hold on;
    subset = diagnostics(diagnostics.trajectory == trajectory, :);
    if metric == "omega_delay"
        subsetX = double(subset.q_delay);
    else
        subsetX = double(subset.q_age);
    end
    for label = ["improvement", "equivalent", "degradation"]
        selected = subset.classification == label;
        scatter(subsetX(selected), subset.performance_ratio(selected), 42, ...
            colors.(char(label)), "filled", "DisplayName", status_label(label));
    end
    yline(1, "k--", "HandleVisibility", "off");
    if trajectory == "circle"
        xline(theory.q_candidate, "Color", [0.2, 0.2, 0.2], "LineStyle", ":", ...
            "DisplayName", "基本周波数の理論候補（実測境界ではない）");
    else
        xline(theory.q_candidate / 2, "Color", [0.45, 0.15, 0.55], "LineStyle", ":", ...
            "DisplayName", "2倍周波数成分の理論候補（2ωL ≈ 1.895、実測境界ではない）");
        xline(theory.q_candidate, "Color", [0.2, 0.2, 0.2], "LineStyle", "-.", ...
            "DisplayName", "基本周波数の理論候補（実測境界ではない）");
    end
    grid on;
    xlabel(xLabel, "Interpreter", "none");
    ylabel("性能比 G", "Interpreter", "none");
    if trajectory == "circle"
        title("円軌道", "Interpreter", "none");
    else
        title("1:2リサジュー軌道", "Interpreter", "none");
    end
    legend("Location", "best", "Interpreter", "none");
end
superTitle = sgtitle(layout, figureText.title);
superTitle.Color = [0.05, 0.05, 0.05];
annotation(fig, "textbox", [0.10, 0.925, 0.80, 0.020], ...
    "String", "理論候補線は実測境界でも文献値でもなく、理想正弦波から導出した比較用候補である。", ...
    "EdgeColor", "none", "HorizontalAlignment", "center", ...
    "FontSize", 8, "Interpreter", "none");
fontName = teleopdelay.analysis.style_figure(fig);
metadata = struct( ...
    "trajectory", "circle|lissajous_1_2", ...
    "case_ids", strjoin(string(diagnostics.case_id), "|"), ...
    "caption", figureText.caption, "metric", figureText.metric, ...
    "axes_contract", figureText.axes_contract, "font_name", fontName);
entry = teleopdelay.analysis.save_figure(fig, figuresDirectory, figureId, metadata, config.figure_dpi);
teleopdelay.analysis.close_figure(fig);
clear cleanup;
end

function label = status_label(value)
switch string(value)
    case "improvement"
        label = "改善";
    case "equivalent"
        label = "同等";
    case "degradation"
        label = "悪化";
    otherwise
        error("teleopDelay:AnalysisFigureStatusInvalid", "Unknown classification: %s", value);
end
end
