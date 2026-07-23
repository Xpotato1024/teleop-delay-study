function digest = sha256_file(filePath)
% sha256_file  Return an uppercase SHA-256 digest for a binary file.

filePath = string(filePath);
if ~isscalar(filePath)
    error("teleopDelay:SHA256FileError", ...
        "The file path to hash must be a scalar text value.");
end
if strlength(filePath) == 0 || ~isfile(filePath)
    error("teleopDelay:SHA256FileError", ...
        "The file to hash does not exist: %s", filePath);
end
fileId = fopen(filePath, "rb");
if fileId < 0
    error("teleopDelay:SHA256FileError", ...
        "The file to hash could not be opened: %s", filePath);
end
cleanup = onCleanup(@() fclose(fileId));
bytes = fread(fileId, Inf, "*uint8");
try
    digestAlgorithm = java.security.MessageDigest.getInstance("SHA-256");
    digestAlgorithm.update(bytes);
    hashBytes = typecast(digestAlgorithm.digest(), "uint8");
catch exception
    error("teleopDelay:SHA256Unavailable", ...
        "SHA-256 calculation is unavailable for %s: %s", filePath, exception.message);
end
digest = string(upper(reshape(dec2hex(hashBytes, 2).', 1, [])));
clear cleanup;
end
