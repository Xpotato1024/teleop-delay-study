function fontName = style_figure(fig)
% style_figure  Apply report-safe contrast and the fixed Japanese font contract.

availableFonts = string(listfonts);
priority = ["Yu Gothic", "Meiryo", "Noto Sans CJK JP", "Noto Sans JP"];
fontName = priority(find(ismember(priority, availableFonts), 1));
if isempty(fontName)
    error("teleopDelay:AnalysisJapaneseFontUnavailable", ...
        "No supported Japanese report font is available.");
end
set(fig, "DefaultAxesFontName", fontName, "DefaultTextFontName", fontName);
fontObjects = findall(fig, "-property", "FontName");
for index = 1:numel(fontObjects)
    fontObjects(index).FontName = fontName;
end

set(fig, "Color", "white");
fontObjects = findall(fig, "-property", "FontColor");
for index = 1:numel(fontObjects)
    fontObjects(index).FontColor = [0.05, 0.05, 0.05];
end
textObjects = findall(fig, "Type", "text");
for index = 1:numel(textObjects)
    textObjects(index).Color = [0.05, 0.05, 0.05];
end
textBoxObjects = findall(fig, "Type", "textbox");
for index = 1:numel(textBoxObjects)
    textBoxObjects(index).Color = [0.05, 0.05, 0.05];
end
subplotTextObjects = findall(fig, "Type", "subplottext");
for index = 1:numel(subplotTextObjects)
    subplotTextObjects(index).Color = [0.05, 0.05, 0.05];
end
axesObjects = findall(fig, "Type", "axes");
for index = 1:numel(axesObjects)
    set(axesObjects(index), "Color", "white", "XColor", [0.05, 0.05, 0.05], ...
        "YColor", [0.05, 0.05, 0.05], "GridColor", [0.65, 0.65, 0.65]);
    labels = [axesObjects(index).XLabel, axesObjects(index).YLabel, ...
        axesObjects(index).ZLabel, axesObjects(index).Title];
    for labelIndex = 1:numel(labels)
        if isgraphics(labels(labelIndex))
            labels(labelIndex).Color = [0.05, 0.05, 0.05];
        end
    end
end
legends = findall(fig, "Type", "legend");
for index = 1:numel(legends)
    set(legends(index), "Color", "white", "TextColor", [0.05, 0.05, 0.05]);
end
end
