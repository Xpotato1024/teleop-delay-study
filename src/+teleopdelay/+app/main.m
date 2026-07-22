function [status, output] = main(projectRoot)
% main  設定、軌道、Simulink実行を結線するアプリケーション入口。

if nargin < 1
    projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename("fullpath")))));
end

config = teleopdelay.config.default_config();
teleopdelay.config.validate_config(config);
nominal_end_s = config.evaluation.total_cycles * 2 * pi / config.trajectory.omega;
config.simulation.duration = teleopdelay.metrics.grid_aligned_duration( ...
    nominal_end_s, config.simulation.dt);
time_s = teleopdelay.timegrid.create(config.simulation.duration, config.simulation.dt);
trajectory = teleopdelay.trajectory.generate(time_s, config.trajectory);
paths = teleopdelay.simulink.model_paths(projectRoot);
teleopdelay.simulink.validate_models(paths);
simulationInput = teleopdelay.simulink.create_simulation_input(paths, config, trajectory);
simulation = teleopdelay.simulink.run_case(simulationInput, paths, config);
evaluation = teleopdelay.metrics.build_evaluation_window(config, trajectory, simulation);
tracking = teleopdelay.metrics.tracking_metrics(config, trajectory, simulation, evaluation);
evaluation = merge_structs(evaluation, tracking);

output = struct("config", config, "trajectory", trajectory, ...
    "simulation", simulation, "evaluation", evaluation);
status = 0;
end

function combined = merge_structs(first, second)
combined = first;
names = fieldnames(second);
for index = 1:numel(names)
    combined.(names{index}) = second.(names{index});
end
end
