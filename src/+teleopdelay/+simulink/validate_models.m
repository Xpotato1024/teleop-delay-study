function info = validate_models(paths)
% validate_models  追跡済みmodelの存在と公開interfaceをread-onlyで検証する。

if ~isfile(paths.plant) || ~isfile(paths.system)
    error("teleopDelay:MissingModel", ...
        "Tracked Simulink models are missing. Run the explicit build_models command.");
end
plantWasLoaded = bdIsLoaded(paths.plantModelName);
systemWasLoaded = bdIsLoaded(paths.systemModelName);
load_system(paths.plant);
load_system(paths.system);
cleanup = onCleanup(@() close_new_models(paths, plantWasLoaded, systemWasLoaded));
set_param(paths.systemModelName, "SimulationCommand", "update");

plantInput = [char(paths.plantModelName) '/command_xy_m'];
plantOutput = [char(paths.plantModelName) '/position_xy_m'];
systemInput = [char(paths.systemModelName) '/command_xy_m'];
commandSink = [char(paths.systemModelName) '/command_logging_sink'];
positionSink = [char(paths.systemModelName) '/position_logging_sink'];
modelBlock = [char(paths.systemModelName) '/first_order_2d'];
verify_port(plantInput, "input");
verify_port(plantOutput, "output");
verify_port(systemInput, "input");
verify_port(commandSink, "output");
verify_port(positionSink, "output");
assert(strcmp(get_param(modelBlock, "ModelName"), paths.plantModelName), ...
    "The top-level model must reference first_order_2d.");
ports = get_param(modelBlock, "Ports");
assert(numel(ports) >= 2 && isequal(ports(1:2), [1 1]), ...
    "The Model Reference must have one input and one output port.");
info = struct("plant", paths.plant, "system", paths.system, ...
    "input_dimension", 2, "output_dimension", 2, "unit", "m", "data_type", "double");
clear cleanup;
close_new_models(paths, plantWasLoaded, systemWasLoaded);
end

function verify_port(blockPath, role)
assert(strcmp(get_param(blockPath, "PortDimensions"), "2"), ...
    "%s port must have dimension 2.", role);
assert(strcmp(get_param(blockPath, "OutDataTypeStr"), "double"), ...
    "%s port must have double type.", role);
assert(strcmp(get_param(blockPath, "Unit"), "m"), ...
    "%s port must have unit m.", role);
end

function close_new_models(paths, plantWasLoaded, systemWasLoaded)
if ~systemWasLoaded && bdIsLoaded(paths.systemModelName)
    close_system(paths.systemModelName, 0);
end
if ~plantWasLoaded && bdIsLoaded(paths.plantModelName)
    close_system(paths.plantModelName, 0);
end
end
