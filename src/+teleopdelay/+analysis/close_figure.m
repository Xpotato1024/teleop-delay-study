function close_figure(fig)
% close_figure  Close a report figure when its graphics handle is valid.

if isgraphics(fig, "figure")
    close(fig);
end
end
