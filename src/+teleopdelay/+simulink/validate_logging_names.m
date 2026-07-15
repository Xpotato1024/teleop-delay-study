function names = validate_logging_names(names)
% validate_logging_names  Dataset loggingの必須element名と重複を検証する。

if isstring(names)
    names = cellstr(names);
end
if ~iscell(names) || any(~cellfun(@ischar, names))
    error("teleopDelay:InvalidLoggingContract", ...
        "Logging element names must be a cell array of character vectors.");
end
requiredNames = {'command_xy_m', 'position_xy_m'};
if numel(names) ~= numel(requiredNames) || ...
        numel(unique(names)) ~= numel(names) || ...
        ~all(ismember(requiredNames, names))
    error("teleopDelay:InvalidLoggingContract", ...
        "yout must contain exactly one command_xy_m and one position_xy_m element.");
end
end
