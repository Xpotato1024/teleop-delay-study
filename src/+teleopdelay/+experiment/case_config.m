function config = case_config(caseDefinition)
% case_config  Convert one manifest definition to the existing config schema.

required = ["trajectory", "amplitude_m", "omega_rad_s", "delay_s", ...
    "sample_period_s", "time_constant_s", "dt_s", "fixed_step_s", ...
    "total_cycles", "warmup_cycles", "solver", "duration_s"];
if ~isstruct(caseDefinition) || ~isscalar(caseDefinition) || ...
        ~all(isfield(caseDefinition, required))
    error("teleopDelay:ExperimentManifestMissingField", ...
        "A case definition is missing one or more required fields.");
end

config = teleopdelay.config.default_config();
config.simulation.dt = caseDefinition.dt_s;
config.simulation.fixed_step = caseDefinition.fixed_step_s;
config.simulation.duration = caseDefinition.duration_s;
config.simulation.solver = caseDefinition.solver;
config.communication.sample_period = caseDefinition.sample_period_s;
config.communication.delay = caseDefinition.delay_s;
config.plant.time_constant = caseDefinition.time_constant_s;
config.trajectory.type = caseDefinition.trajectory;
config.trajectory.amplitude = caseDefinition.amplitude_m;
config.trajectory.omega = caseDefinition.omega_rad_s;
config.evaluation.total_cycles = caseDefinition.total_cycles;
config.evaluation.warmup_cycles = caseDefinition.warmup_cycles;
end
