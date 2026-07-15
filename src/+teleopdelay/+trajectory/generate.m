function trajectory = generate(time_s, parameters)
% generate  指定された決定論的軌道を生成する。

validateattributes(time_s, {'numeric'}, {'column', 'real', 'finite'});
validateattributes(parameters, {'struct'}, {'scalar'});
required = ["type", "amplitude", "omega"];
assert(all(isfield(parameters, required)), 'trajectory parameters are incomplete.');
if ~isstring(parameters.type) || ~isscalar(parameters.type)
    error('teleopDelay:InvalidTrajectoryType', ...
        'trajectory.type must be a string scalar.');
end
if numel(time_s) < 2 || any(diff(time_s) <= 0)
    error('teleopDelay:InvalidTimeVector', ...
        'time_s must contain at least two strictly increasing samples.');
end
validateattributes(parameters.amplitude, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'positive'});
validateattributes(parameters.omega, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'positive'});
switch string(parameters.type)
    case "circle"
        trajectory = teleopdelay.trajectory.circle(time_s, parameters);
    case "lissajous_1_2"
        trajectory = teleopdelay.trajectory.lissajous_1_2(time_s, parameters);
    otherwise
        error('teleopDelay:InvalidTrajectoryType', 'Unsupported trajectory type: %s.', parameters.type);
end
end
