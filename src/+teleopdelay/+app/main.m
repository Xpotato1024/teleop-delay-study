function [status, output] = main(projectRoot)
% main  設定、軌道、Simulink実行を結線するアプリケーション入口。

if nargin < 1
    projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename("fullpath")))));
end

config = teleopdelay.config.default_config();
teleopdelay.config.validate_config(config);
time_s = teleopdelay.timegrid.create(config.simulation.duration, config.simulation.dt);
trajectory = teleopdelay.trajectory.generate(time_s, config.trajectory);
paths = teleopdelay.simulink.model_paths(projectRoot);
teleopdelay.simulink.validate_models(paths);
simulationInput = teleopdelay.simulink.create_simulation_input(paths, config, trajectory);
simulation = teleopdelay.simulink.run_case(simulationInput, paths, config);

output = struct("config", config, "trajectory", trajectory, "simulation", simulation);
status = 0;
end
