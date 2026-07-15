function time_s = create(duration_s, dt_s)
% create  0からdurationまでの固定刻み時間gridを生成する。

validateattributes(duration_s, {'numeric'}, {'scalar', 'real', 'finite', 'nonnegative'});
validateattributes(dt_s, {'numeric'}, {'scalar', 'real', 'finite', 'positive'});
step_count = duration_s / dt_s;
rounded_step_count = round(step_count);
if abs(step_count - rounded_step_count) > 1e-10 * max(1, abs(step_count))
    error('teleopDelay:InvalidTimeGrid', ...
        'duration / dt must be an integer number of fixed steps.');
end
time_s = (0:rounded_step_count).' * dt_s;
time_s(end) = duration_s;
end
