function tests = test_sha256
tests = functiontests(localfunctions);
end

function testSha256ReturnsUppercaseDigestForBinaryFile(testCase)
filePath = string(tempname) + ".bin";
cleanup = onCleanup(@() delete_if_exists(filePath));
fileId = fopen(filePath, "wb");
assert(fileId >= 0);
fwrite(fileId, uint8([97, 98, 99]), "uint8");
fclose(fileId);
digest = teleopdelay.experiment.sha256_file(filePath);
verifyClass(testCase, digest, "string");
verifyEqual(testCase, digest, ...
    "BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD");
verifyEqual(testCase, digest, upper(digest));
end

function testSha256RejectsMissingFile(testCase)
verifyError(testCase, @() teleopdelay.experiment.sha256_file( ...
    string(tempname) + ".missing"), "teleopDelay:SHA256FileError");
end

function delete_if_exists(filePath)
if isfile(filePath)
    delete(filePath);
end
end
