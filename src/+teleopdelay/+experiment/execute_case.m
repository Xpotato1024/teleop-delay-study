function output = execute_case(caseDefinition, projectRoot)
% execute_case  Execute one manifest case through the existing simulation API.

if nargin < 2 || strlength(string(projectRoot)) == 0
    projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename("fullpath")))));
end
projectRoot = char(string(projectRoot));
config = teleopdelay.experiment.case_config(caseDefinition);
teleopdelay.config.validate_config(config);
time_s = teleopdelay.timegrid.create(config.simulation.duration, config.simulation.dt);
trajectory = teleopdelay.trajectory.generate(time_s, config.trajectory);
paths = teleopdelay.simulink.model_paths(projectRoot);
teleopdelay.simulink.validate_models(paths);
simulationInput = teleopdelay.simulink.create_simulation_input(paths, config, trajectory);
simulation = teleopdelay.simulink.run_case(simulationInput, paths, config);
evaluation = teleopdelay.metrics.build_evaluation_window(config, trajectory, simulation);
tracking = teleopdelay.metrics.tracking_metrics(config, trajectory, simulation, evaluation);
evaluation = merge_structs(evaluation, tracking);
output = struct( ...
    "config", config, ...
    "trajectory", trajectory, ...
    "simulation", simulation, ...
    "evaluation", evaluation);
end

function combined = merge_structs(first, second)
combined = first;
names = fieldnames(second);
for index = 1:numel(names)
    combined.(names{index}) = second.(names{index});
end
end
