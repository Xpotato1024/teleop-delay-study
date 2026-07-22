function simulationInput = create_simulation_input(paths, config, trajectory)
% create_simulation_input  外部軌道とsimulation設定をSimulationInputへ束ねる。

validateattributes(trajectory.time_s, {'numeric'}, {'column', 'real', 'finite'});
N = numel(trajectory.time_s);
if ~isequal(size(trajectory.position_m), [N, 2]) || ...
        ~isequal(size(trajectory.velocity_mps), [N, 2])
    error("teleopDelay:InvalidTrajectoryShape", ...
        "trajectory position and velocity must both be N-by-2.");
end
if ~all(isfinite(trajectory.position_m), "all") || ~all(isfinite(trajectory.velocity_mps), "all")
    error("teleopDelay:InvalidTrajectoryValue", ...
        "trajectory position and velocity must be finite.");
end
simulationInput = Simulink.SimulationInput(paths.systemModelName);
position = timeseries(trajectory.position_m, trajectory.time_s, "Name", "position_xy_m");
velocity = timeseries(trajectory.velocity_mps, trajectory.time_s, "Name", "velocity_mps");
externalInput = Simulink.SimulationData.Dataset;
externalInput = externalInput.addElement(position);
externalInput = externalInput.addElement(velocity);
simulationInput = simulationInput.setExternalInput(externalInput);
simulationInput = simulationInput.setModelParameter( ...
    "StopTime", string(trajectory.time_s(end)), ...
    "Solver", string(config.simulation.solver), ...
    "FixedStep", string(config.simulation.fixed_step));
simulationInput = simulationInput.setVariable("time_constant_s", config.plant.time_constant, ...
    Workspace=paths.systemModelName);
simulationInput = simulationInput.setVariable("sample_period_s", config.communication.sample_period, ...
    Workspace=paths.systemModelName);
simulationInput = simulationInput.setVariable("delay_s", config.communication.delay, ...
    Workspace=paths.systemModelName);
end
