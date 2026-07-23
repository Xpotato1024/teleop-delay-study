function manifest = standard_manifest(varargin)
% standard_manifest  Generate the canonical Issue #8 factorial manifest.

parser = inputParser;
addParameter(parser, "TrajectoryTypes", ["circle", "lissajous_1_2"]);
addParameter(parser, "Delays", [0, 0.10, 0.20, 0.40, 0.50]);
addParameter(parser, "Omegas", [0.5, 1.0, 2.0, 4.0]);
parse(parser, varargin{:});

trajectoryTypes = string(parser.Results.TrajectoryTypes(:).');
delays = double(parser.Results.Delays(:).');
omegas = double(parser.Results.Omegas(:).');
if isempty(trajectoryTypes) || isempty(delays) || isempty(omegas)
    error("teleopDelay:ExperimentManifestInvalidField", ...
        "Factorial manifest axes must not be empty.");
end
if any(ismissing(trajectoryTypes)) || any(~ismember(trajectoryTypes, ...
        ["circle", "lissajous_1_2"]))
    error("teleopDelay:InvalidConfig", ...
        "trajectory must be circle or lissajous_1_2.");
end
if any(~isfinite(delays)) || any(~isfinite(omegas))
    error("teleopDelay:ExperimentManifestNonFinite", ...
        "Manifest axes must contain only finite values.");
end
if any(delays < 0) || any(omegas <= 0)
    error("teleopDelay:InvalidConfig", ...
        "delay must be nonnegative and omega must be positive.");
end

baseConfig = teleopdelay.config.default_config();
schemaVersion = "issue8.standard.v1";
emptyDefinition = struct( ...
    "case_id", "", ...
    "canonical_key", "", ...
    "trajectory", "", ...
    "amplitude_m", 0.0, ...
    "omega_rad_s", 0.0, ...
    "delay_s", 0.0, ...
    "sample_period_s", 0.0, ...
    "time_constant_s", 0.0, ...
    "dt_s", 0.0, ...
    "fixed_step_s", 0.0, ...
    "total_cycles", 0.0, ...
    "warmup_cycles", 0.0, ...
    "solver", "", ...
    "nominal_duration_s", 0.0, ...
    "expected_duration_s", 0.0, ...
    "duration_s", 0.0);
cases = repmat(emptyDefinition, 0, 1);

for trajectoryType = trajectoryTypes
    for delay = delays
        for omega = omegas
            config = baseConfig;
            config.simulation.dt = 0.005;
            config.simulation.fixed_step = config.simulation.dt;
            config.communication.sample_period = 0.020;
            config.communication.delay = delay;
            config.plant.time_constant = 0.10;
            config.trajectory.type = trajectoryType;
            config.trajectory.omega = omega;
            config.evaluation.total_cycles = 10;
            config.evaluation.warmup_cycles = 2;
            nominalDuration = config.evaluation.total_cycles * 2 * pi / omega;
            duration = teleopdelay.metrics.grid_aligned_duration( ...
                nominalDuration, config.simulation.fixed_step);
            config.simulation.duration = duration;
            teleopdelay.config.validate_config(config);

            definition = emptyDefinition;
            definition.trajectory = trajectoryType;
            definition.amplitude_m = double(config.trajectory.amplitude);
            definition.omega_rad_s = double(omega);
            definition.delay_s = double(delay);
            definition.sample_period_s = double(config.communication.sample_period);
            definition.time_constant_s = double(config.plant.time_constant);
            definition.dt_s = double(config.simulation.dt);
            definition.fixed_step_s = double(config.simulation.fixed_step);
            definition.total_cycles = double(config.evaluation.total_cycles);
            definition.warmup_cycles = double(config.evaluation.warmup_cycles);
            definition.solver = string(config.simulation.solver);
            definition.nominal_duration_s = double(nominalDuration);
            definition.expected_duration_s = double(duration);
            definition.duration_s = double(duration);
            [definition.case_id, definition.canonical_key] = ...
                teleopdelay.experiment.case_id(definition);
            cases(end + 1, 1) = definition; %#ok<AGROW>
        end
    end
end

sortMatrix = zeros(numel(cases), 3);
for index = 1:numel(cases)
    sortMatrix(index, :) = [ ...
        double(cases(index).trajectory == "lissajous_1_2"), ...
        cases(index).delay_s, cases(index).omega_rad_s];
end
[~, order] = sortrows(sortMatrix, [1, 2, 3]);
cases = cases(order);
manifest = struct( ...
    "schema_version", schemaVersion, ...
    "experiment_id", "", ...
    "case_count", double(numel(cases)), ...
    "condition_fields", ["trajectory", "amplitude_m", "omega_rad_s", ...
        "delay_s", "sample_period_s", "time_constant_s", "dt_s", ...
        "fixed_step_s", "total_cycles", "warmup_cycles", "solver", ...
        "nominal_duration_s", "expected_duration_s", "duration_s"], ...
    "cases", cases);
manifest.experiment_id = teleopdelay.experiment.experiment_id(manifest);
teleopdelay.experiment.validate_manifest(manifest);
end
