function isValid = validate_config(config)
% validate_config  シミュレーション設定の最小限の入力検証を行う。

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

isValid = true;
end
