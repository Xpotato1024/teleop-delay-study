function isValid = validate_config(config)
% validate_config  シミュレーション設定を検証する。

assert(isstruct(config), 'config must be a struct.');
requiredGroups = {'simulation', 'communication', 'plant', 'trajectory', 'random'};
for groupIndex = 1:numel(requiredGroups)
    groupName = requiredGroups{groupIndex};
    assert(isfield(config, groupName), 'Missing config group: %s.', groupName);
end

validateattributes(config.simulation.dt, {'numeric'}, {'scalar', 'real', 'finite', 'positive'}, mfilename, 'simulation.dt');
validateattributes(config.simulation.duration, {'numeric'}, {'scalar', 'real', 'finite', 'positive'}, mfilename, 'simulation.duration');
validateattributes(config.communication.sample_period, {'numeric'}, {'scalar', 'real', 'finite', 'positive'}, mfilename, 'communication.sample_period');
validateattributes(config.communication.delay, {'numeric'}, {'scalar', 'real', 'finite'}, mfilename, 'communication.delay');
assert(config.communication.delay >= 0, 'communication.delay must be nonnegative.');
validateattributes(config.plant.time_constant, {'numeric'}, {'scalar', 'real', 'finite', 'positive'}, mfilename, 'plant.time_constant');
validateattributes(config.trajectory.amplitude, {'numeric'}, {'scalar', 'real', 'finite', 'positive'}, mfilename, 'trajectory.amplitude');
validateattributes(config.trajectory.omega, {'numeric'}, {'scalar', 'real', 'finite', 'positive'}, mfilename, 'trajectory.omega');
validateattributes(config.random.seed, {'numeric'}, {'scalar', 'real', 'finite'}, mfilename, 'random.seed');
assert(config.random.seed >= 0 && config.random.seed == floor(config.random.seed), ...
    'random.seed must be a nonnegative integer.');
validate_string_scalar(config.trajectory.type, "config.trajectory.type");
if ~any(config.trajectory.type == ["circle", "lissajous_1_2"])
    error("teleopDelay:InvalidConfig", ...
        "config.trajectory.type must be exactly circle or lissajous_1_2.");
end
validateattributes(config.simulation.fixed_step, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'positive'}, mfilename, 'simulation.fixed_step');
validate_string_scalar(config.simulation.solver, "config.simulation.solver");
if config.simulation.solver ~= "ode4"
    error("teleopDelay:InvalidConfig", ...
        "config.simulation.solver must be exactly ode4 for the foundation model.");
end

isValid = true;
end

function validate_string_scalar(value, fieldName)
if ~(isstring(value) && isscalar(value) && ~ismissing(value))
    error("teleopDelay:InvalidConfig", "%s must be a nonmissing string scalar.", fieldName);
end
end
