function trajectory = circle(time_s, parameters)
% circle  円軌道の位置、速度、加速度を解析式で返す。

validateattributes(time_s, {'numeric'}, {'column', 'real', 'finite'});
validateattributes(parameters, {'struct'}, {'scalar'});
validateattributes(parameters.amplitude, {'numeric'}, {'scalar', 'real', 'finite', 'positive'});
validateattributes(parameters.omega, {'numeric'}, {'scalar', 'real', 'finite', 'positive'});
if numel(time_s) < 2 || any(diff(time_s) <= 0)
    error('teleopDelay:InvalidTimeVector', ...
        'time_s must contain at least two strictly increasing samples.');
end
A = parameters.amplitude;
omega = parameters.omega;
position_m = [A * cos(omega * time_s), A * sin(omega * time_s)];
velocity_mps = [-A * omega * sin(omega * time_s), A * omega * cos(omega * time_s)];
acceleration_mps2 = [-A * omega^2 * cos(omega * time_s), -A * omega^2 * sin(omega * time_s)];
trajectory = struct( ...
    "type", "circle", ...
    "time_s", time_s, ...
    "position_m", position_m, ...
    "velocity_mps", velocity_mps, ...
    "acceleration_mps2", acceleration_mps2, ...
    "parameters", parameters);
end
