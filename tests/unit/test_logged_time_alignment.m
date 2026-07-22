function tests = test_logged_time_alignment
tests = functiontests(localfunctions);
end

function testMatchingLoggedTimesAreAccepted(testCase)
time_s = (0:0.1:1).';
time_vectors = {time_s, time_s, time_s + eps(time_s), time_s};
canonical = teleopdelay.simulink.validate_logged_time_alignment( ...
    time_vectors, {"a", "b", "c", "d"});
verifyEqual(testCase, canonical, time_s);
end

function testMisalignedLoggedTimeIsRejected(testCase)
time_s = (0:0.1:1).';
time_vectors = {time_s, time_s};
time_vectors{2}(5) = time_vectors{2}(5) + 1e-6;
verifyError(testCase, @() teleopdelay.simulink.validate_logged_time_alignment( ...
    time_vectors, {"canonical", "misaligned"}), ...
    "teleopDelay:MisalignedLoggedSignal");
end

function testInvalidLoggedTimeShapeAndMonotonicityAreRejected(testCase)
time_s = (0:0.1:1).';
verifyError(testCase, @() teleopdelay.simulink.validate_logged_time_alignment( ...
    {time_s, time_s.'}, {"a", "row"}), "teleopDelay:InvalidLoggedTime");
nonmonotonic = time_s;
nonmonotonic(5) = nonmonotonic(4);
verifyError(testCase, @() teleopdelay.simulink.validate_logged_time_alignment( ...
    {time_s, nonmonotonic}, {"a", "nonmonotonic"}), ...
    "teleopDelay:InvalidLoggedTime");
end
