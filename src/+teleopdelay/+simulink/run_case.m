function simulation = run_case(simulationInput, paths, config)
% run_case  headless simulationを実行し、logging結果を共通schemaへ変換する。

load_system(paths.plant);
load_system(paths.system);
cleanup = onCleanup(@() close_models(paths));
set_param(paths.systemModelName, "SimulationCommand", "update");
simulationOutput = sim(simulationInput);
loggedOutputs = simulationOutput.yout;
elementNames = cellstr(loggedOutputs.getElementNames());
teleopdelay.simulink.validate_logging_names(elementNames);
command = loggedOutputs.getElement("command_xy_m").Values;
position = loggedOutputs.getElement("position_xy_m").Values;
simulation = struct( ...
    "time_s", command.Time, ...
    "command_xy_m", command.Data, ...
    "position_xy_m", position.Data, ...
    "solver", string(config.simulation.solver), ...
    "fixed_step_s", config.simulation.fixed_step);
assert(isequal(size(simulation.time_s, 2), 1), 'simulation.time_s must be a column.');
assert(isequal(size(simulation.command_xy_m), [numel(simulation.time_s), 2]), ...
    'simulation.command_xy_m must be N-by-2.');
assert(isequal(size(simulation.position_xy_m), [numel(simulation.time_s), 2]), ...
    'simulation.position_xy_m must be N-by-2.');
assert(all(isfinite(simulation.command_xy_m), "all") && all(isfinite(simulation.position_xy_m), "all"), ...
    'simulation output must be finite.');
clear cleanup;
close_if_loaded(paths.systemModelName);
end

function close_models(paths)
close_if_loaded(paths.systemModelName);
close_if_loaded(paths.plantModelName);
end

function close_if_loaded(modelName)
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
end
