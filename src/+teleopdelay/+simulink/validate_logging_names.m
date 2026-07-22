function names = validate_logging_names(names)
% validate_logging_names  Dataset loggingの必須element名と重複を検証する。

if isstring(names)
    names = cellstr(names);
end
if ~iscell(names) || any(~cellfun(@ischar, names))
    error("teleopDelay:InvalidLoggingContract", ...
        "Logging element names must be a cell array of character vectors.");
end
requiredNames = {'zoh_command_xy_m', 'cv_command_xy_m', ...
    'zoh_position_xy_m', 'cv_position_xy_m', ...
    'packet_timestamp_s', 'packet_age_s', 'packet_valid'};
if numel(names) ~= numel(requiredNames) || ...
        numel(unique(names)) ~= numel(names) || ...
        ~all(ismember(requiredNames, names))
    error("teleopDelay:InvalidLoggingContract", ...
        "yout must contain exactly the required named simulation elements.");
end
end
