function info = validate_models(paths)
% validate_models  追跡済みmodelの存在と公開interfaceをread-onlyで検証する。

if ~isfile(paths.plant) || ~isfile(paths.communication) || ~isfile(paths.system)
    error("teleopDelay:MissingModel", ...
        "Tracked Simulink models are missing. Run the explicit build_models command.");
end
plantWasLoaded = bdIsLoaded(paths.plantModelName);
communicationWasLoaded = bdIsLoaded(paths.communicationModelName);
systemWasLoaded = bdIsLoaded(paths.systemModelName);
load_system(paths.plant);
load_system(paths.communication);
load_system(paths.system);
cleanup = onCleanup(@() close_new_models(paths, plantWasLoaded, communicationWasLoaded, systemWasLoaded));
set_param(paths.plantModelName, "SimulationCommand", "update");
set_param(paths.systemModelName, "SimulationCommand", "update");

plantInput = [char(paths.plantModelName) '/command_xy_m'];
plantOutput = [char(paths.plantModelName) '/position_xy_m'];
communicationInput = [char(paths.communicationModelName) '/position_xy_m'];
communicationVelocity = [char(paths.communicationModelName) '/velocity_mps'];
communicationModelBlock = [char(paths.systemModelName) '/sampled_communication'];
zohPlant = [char(paths.systemModelName) '/zoh_first_order_2d'];
cvPlant = [char(paths.systemModelName) '/cv_first_order_2d'];
verify_port(plantInput, "input");
verify_port(plantOutput, "output");
verify_port(communicationInput, "communication position input", "m");
verify_port(communicationVelocity, "communication velocity input", "m/s");
verify_model_ports(communicationModelBlock, 2, 5, "communication Model Reference");
verify_model_ports(zohPlant, 1, 1, "ZOH plant Model Reference");
verify_model_ports(cvPlant, 1, 1, "CV plant Model Reference");
verify_sample_time(plantInput, "plant input");
verify_sample_time(plantOutput, "plant output");
stateBlock = [char(paths.plantModelName) '/first_order_state_space'];
assert(strcmp(get_param(stateBlock, "BlockType"), "StateSpace"), ...
    "The plant must use a State-Space block.");
compiledSampleTime = get_param(stateBlock, "CompiledSampleTime");
assert(isequal(compiledSampleTime, [0 0]), ...
    "The plant State-Space block must have continuous compiled sample time.");
assert(strcmp(get_param(paths.systemModelName, "Solver"), "ode4"), ...
    "The top-level model must use the ode4 solver.");
assert(strcmp(get_param(communicationModelBlock, "ModelName"), paths.communicationModelName), ...
    "The top-level model must reference sampled_communication.");
info = struct("plant", paths.plant, "communication", paths.communication, "system", paths.system, ...
    "input_dimension", 2, "output_dimension", 2, "unit", "m", "data_type", "double", ...
    "sample_time", -1, "plant_state_sample_time", 0, "solver", "ode4");
clear cleanup;
close_new_models(paths, plantWasLoaded, communicationWasLoaded, systemWasLoaded);
end

function verify_port(blockPath, role, expectedUnit)
if nargin < 3, expectedUnit = "m"; end
assert(strcmp(get_param(blockPath, "PortDimensions"), "2"), ...
    "%s port must have dimension 2.", role);
assert(strcmp(get_param(blockPath, "OutDataTypeStr"), "double"), ...
    "%s port must have double type.", role);
assert(strcmp(get_param(blockPath, "Unit"), expectedUnit), ...
    "%s port has an unexpected unit.", role);
end

function verify_model_ports(blockPath, inputCount, outputCount, role)
ports = get_param(blockPath, "Ports");
assert(numel(ports) >= 2 && isequal(ports(1:2), [inputCount outputCount]), ...
    "%s has an unexpected port count.", role);
end

function verify_sample_time(blockPath, role)
sampleTime = string(get_param(blockPath, "SampleTime"));
assert(sampleTime == "-1", "%s must have inherited sample time -1.", role);
end

function close_new_models(paths, plantWasLoaded, communicationWasLoaded, systemWasLoaded)
if ~systemWasLoaded && bdIsLoaded(paths.systemModelName)
    close_system(paths.systemModelName, 0);
end
if ~communicationWasLoaded && bdIsLoaded(paths.communicationModelName)
    close_system(paths.communicationModelName, 0);
end
if ~plantWasLoaded && bdIsLoaded(paths.plantModelName)
    close_system(paths.plantModelName, 0);
end
end
