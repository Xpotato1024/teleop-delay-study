function canonical_time = validate_logged_time_alignment(time_vectors, names)
% validate_logged_time_alignment  8つのlogged Values.Timeの共通gridを検証する。

if ~iscell(time_vectors) || isempty(time_vectors)
    error("teleopDelay:InvalidLoggedTime", ...
        "time_vectors must be a nonempty cell array.");
end
if nargin < 2 || isempty(names)
    names = cellstr(compose("signal_%d", 1:numel(time_vectors)));
elseif isstring(names)
    names = cellstr(names);
end
if ~iscell(names) || numel(names) ~= numel(time_vectors)
    error("teleopDelay:InvalidLoggedTime", ...
        "names must match the number of time vectors.");
end

canonical_time = time_vectors{1};
validate_time_vector(canonical_time, names{1});
for index = 2:numel(time_vectors)
    candidate_time = time_vectors{index};
    validate_time_vector(candidate_time, names{index});
    if ~isequal(size(candidate_time), size(canonical_time))
        error("teleopDelay:MisalignedLoggedSignal", ...
            "Logged signal %s has a time vector with a different shape or length.", ...
            names{index});
    end
    % 32*eps scales with the recorded time magnitude and only covers double roundoff.
    time_tolerance = 32 * eps(max([1; abs(canonical_time); abs(candidate_time)]));
    if any(abs(candidate_time - canonical_time) > time_tolerance)
        error("teleopDelay:MisalignedLoggedSignal", ...
            "Logged signal %s is not aligned with the canonical time vector.", ...
            names{index});
    end
end
end

function validate_time_vector(time_s, name)
if ~(isa(time_s, "double") && isreal(time_s) && iscolumn(time_s) && ...
        ~isempty(time_s) && all(isfinite(time_s)) && all(diff(time_s) > 0))
    error("teleopDelay:InvalidLoggedTime", ...
        "Logged signal %s must have a finite, strictly increasing N-by-1 double time vector.", ...
        name);
end
end
