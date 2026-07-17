function tests = test_timegrid
tests = functiontests(localfunctions);
end

function testFixedGridShapeAndEndpoint(testCase)
time_s = teleopdelay.timegrid.create(0.3, 0.1);
verifyEqual(testCase, time_s, (0:0.1:0.3).', AbsTol=8*eps(1));
verifySize(testCase, time_s, [4 1]);
verifyEqual(testCase, time_s(end), 0.3, AbsTol=0);
end

function testZeroDurationIsSingleSample(testCase)
verifyEqual(testCase, teleopdelay.timegrid.create(0, 0.1), 0);
end

function testNonIntegerStepRejected(testCase)
verifyError(testCase, @() teleopdelay.timegrid.create(1, 0.03), ...
    'teleopDelay:InvalidTimeGrid');
verifyError(testCase, @() teleopdelay.timegrid.create(0.300000000000001, 0.1), ...
    'teleopDelay:InvalidTimeGrid');
end

function testInvalidInputsRejected(testCase)
verifyRejected(testCase, @() teleopdelay.timegrid.create(-1, 0.1));
verifyRejected(testCase, @() teleopdelay.timegrid.create(1, 0));
verifyRejected(testCase, @() teleopdelay.timegrid.create(NaN, 0.1));
verifyRejected(testCase, @() teleopdelay.timegrid.create(1, Inf));
verifyRejected(testCase, @() teleopdelay.timegrid.create(Inf, 0.1));
end

function verifyRejected(testCase, functionHandle)
rejected = false;
try
    functionHandle();
catch
    rejected = true;
end
verifyTrue(testCase, rejected);
end
