function [tolerance, contract] = boundary_tolerance(values, convergence, config)
% boundary_tolerance  Apply the documented convergence-based tolerance contract.

machineFloor = config.machine_precision_multiplier * eps(max(1, max(abs(values))));
if isstruct(convergence) && isfield(convergence, "available") && convergence.available
    deltas = double(convergence.table.delta_performance_ratio);
    maximumDelta = max([0; abs(deltas)]);
    tolerance = max(machineFloor, config.classification_safety_factor * maximumDelta);
    source = "convergence-based";
else
    maximumDelta = NaN;
    tolerance = machineFloor;
    source = "machine-precision-only";
end
contract = struct( ...
    "boundary_tolerance", tolerance, ...
    "machine_precision_floor", machineFloor, ...
    "maximum_convergence_delta_G", maximumDelta, ...
    "safety_factor", config.classification_safety_factor, ...
    "source", source, ...
    "classification_rule", "improvement: G < 1-tol; equivalent: abs(G-1)<=tol; degradation: G > 1+tol");
end
