function style_figure(fig)
% style_figure  Apply report-safe contrast independent of MATLAB theme.

set(fig, "Color", "white");
fontObjects = findall(fig, "-property", "FontColor");
for index = 1:numel(fontObjects)
    fontObjects(index).FontColor = [0.05, 0.05, 0.05];
end
textObjects = findall(fig, "Type", "text");
for index = 1:numel(textObjects)
    textObjects(index).Color = [0.05, 0.05, 0.05];
end
axesObjects = findall(fig, "Type", "axes");
for index = 1:numel(axesObjects)
    set(axesObjects(index), "Color", "white", "XColor", [0.05, 0.05, 0.05], ...
        "YColor", [0.05, 0.05, 0.05], "GridColor", [0.65, 0.65, 0.65]);
end
legends = findall(fig, "Type", "legend");
for index = 1:numel(legends)
    set(legends(index), "Color", "white", "TextColor", [0.05, 0.05, 0.05]);
end
end
