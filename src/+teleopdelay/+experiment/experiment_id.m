function experimentId = experiment_id(manifest)
% experiment_id  Build a short deterministic identifier from all case fields.

if ~isstruct(manifest) || ~isscalar(manifest) || ~isfield(manifest, "cases")
    error("teleopDelay:ExperimentManifestMissingField", ...
        "manifest.cases is required to build experiment_id.");
end
cases = manifest.cases;
if isempty(cases)
    error("teleopDelay:ExperimentManifestInvalidField", ...
        "manifest.cases must not be empty.");
end
if ~isfield(manifest, "schema_version")
    error("teleopDelay:ExperimentManifestMissingField", ...
        "manifest.schema_version is required to build experiment_id.");
end
canonicalKeys = sort(string({cases.canonical_key}));
signatureText = string(manifest.schema_version) + "|" + strjoin(canonicalKeys, ";");
signature = stable_token(signatureText);
experimentId = "i8v1_n" + string(numel(cases)) + "_" + signature;
end

function token = stable_token(text)
hashValue = 2166136261;
bytes = uint8(char(text));
for index = 1:numel(bytes)
    hashValue = mod(hashValue * 131 + double(bytes(index)), 4294967291);
end
token = lower(string(dec2hex(uint32(hashValue), 8)));
end
