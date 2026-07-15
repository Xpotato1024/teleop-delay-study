function trajectory = generate(time_s, parameters)
% generate  指定された決定論的軌道を生成する。

validateattributes(time_s, {'numeric'}, {'column', 'real', 'finite'});
validateattributes(parameters, {'struct'}, {'scalar'});
required = ["type", "amplitude", "omega"];
assert(all(isfield(parameters, required)), 'trajectory parameters are incomplete.');
switch string(parameters.type)
    case "circle"
        trajectory = teleopdelay.trajectory.circle(time_s, parameters);
    case "lissajous_1_2"
        trajectory = teleopdelay.trajectory.lissajous_1_2(time_s, parameters);
    otherwise
        error('teleopDelay:InvalidTrajectoryType', 'Unsupported trajectory type: %s.', parameters.type);
end
end
