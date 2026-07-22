function [caseId, canonicalKey] = case_id(caseDefinition)
% case_id  Build an order-independent identifier from canonical case fields.

required = ["trajectory", "amplitude_m", "omega_rad_s", "delay_s", ...
    "sample_period_s", "time_constant_s", "dt_s", "fixed_step_s", ...
    "total_cycles", "warmup_cycles", "solver", "nominal_duration_s", ...
    "expected_duration_s", "duration_s"];
if ~isstruct(caseDefinition) || ~isscalar(caseDefinition) || ...
        ~all(isfield(caseDefinition, required))
    error("teleopDelay:ExperimentManifestMissingField", ...
        "A case definition is missing one or more canonical fields.");
end

parts = [
    "schema=issue8.standard.v1"
    "trajectory=" + canonical_text(caseDefinition.trajectory)
    "amplitude_m=" + canonical_number(caseDefinition.amplitude_m)
    "omega_rad_s=" + canonical_number(caseDefinition.omega_rad_s)
    "delay_s=" + canonical_number(caseDefinition.delay_s)
    "sample_period_s=" + canonical_number(caseDefinition.sample_period_s)
    "time_constant_s=" + canonical_number(caseDefinition.time_constant_s)
    "dt_s=" + canonical_number(caseDefinition.dt_s)
    "fixed_step_s=" + canonical_number(caseDefinition.fixed_step_s)
    "total_cycles=" + canonical_number(caseDefinition.total_cycles)
    "warmup_cycles=" + canonical_number(caseDefinition.warmup_cycles)
    "solver=" + canonical_text(caseDefinition.solver)
    "nominal_duration_s=" + canonical_number(caseDefinition.nominal_duration_s)
    "expected_duration_s=" + canonical_number(caseDefinition.expected_duration_s)
    "duration_s=" + canonical_number(caseDefinition.duration_s)];
canonicalKey = strjoin(parts, "|");

tokens = [
    "case"
    "trajectory-" + id_token(caseDefinition.trajectory)
    "A-" + id_token(caseDefinition.amplitude_m)
    "w-" + id_token(caseDefinition.omega_rad_s)
    "d-" + id_token(caseDefinition.delay_s)
    "sp-" + id_token(caseDefinition.sample_period_s)
    "T-" + id_token(caseDefinition.time_constant_s)
    "dt-" + id_token(caseDefinition.dt_s)
    "fs-" + id_token(caseDefinition.fixed_step_s)
    "tc-" + id_token(caseDefinition.total_cycles)
    "wc-" + id_token(caseDefinition.warmup_cycles)
    "solver-" + id_token(caseDefinition.solver)
    "duration-" + id_token(caseDefinition.duration_s)];
caseId = strjoin(tokens, "__");
end

function text = canonical_text(value)
if ~(isstring(value) && isscalar(value) && ~ismissing(value))
    error("teleopDelay:ExperimentManifestInvalidField", ...
        "Canonical text fields must be nonmissing string scalars.");
end
text = string(value);
end

function text = canonical_number(value)
if ~(isa(value, "double") && isscalar(value) && isreal(value) && isfinite(value))
    error("teleopDelay:ExperimentManifestNonFinite", ...
        "Canonical numeric fields must be finite double scalars.");
end
text = string(sprintf("%.17g", value));
end

function token = id_token(value)
if isstring(value)
    token = replace(string(value), ["-", ".", "+", "|", " "], ...
        ["_", "p", "plus", "_", "_"]);
else
    token = replace(canonical_number(double(value)), ["-", ".", "+", "|", " "], ...
        ["m", "p", "plus", "_", "_"]);
end
end
