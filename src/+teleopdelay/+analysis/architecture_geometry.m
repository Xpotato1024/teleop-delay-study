function geometry = architecture_geometry()
% architecture_geometry  Return routed geometry for the architecture figure.

contract = teleopdelay.analysis.architecture_contract();
positions = node_positions();
edges = repmat(struct("source", "", "target", "", "points", zeros(0, 2)), ...
    1, size(contract.required_edges, 1));
for index = 1:size(contract.required_edges, 1)
    source = contract.required_edges(index, 1);
    target = contract.required_edges(index, 2);
    waypoints = edge_waypoints(source, target);
    edges(index).source = source;
    edges(index).target = target;
    edges(index).points = routed_points(positions.(char(source)), ...
        positions.(char(target)), waypoints);
end
geometry = struct( ...
    "positions", positions, ...
    "edges", edges, ...
    "crossings", find_crossings(edges, positions, contract.nodes));
end

function positions = node_positions()
positions = struct( ...
    "continuous_target", [0.03, 0.72, 0.15, 0.10], ...
    "sender_sampling", [0.21, 0.72, 0.15, 0.10], ...
    "fixed_delay", [0.39, 0.72, 0.15, 0.10], ...
    "latest_packet", [0.57, 0.70, 0.20, 0.14], ...
    "zoh_reconstruction", [0.48, 0.46, 0.16, 0.10], ...
    "cv_reconstruction", [0.48, 0.20, 0.16, 0.10], ...
    "reference_plant", [0.22, 0.20, 0.18, 0.10], ...
    "zoh_plant", [0.70, 0.46, 0.12, 0.10], ...
    "cv_plant", [0.70, 0.20, 0.12, 0.10], ...
    "evaluation", [0.87, 0.42, 0.10, 0.20]);
end

function waypoints = edge_waypoints(source, target)
waypoints = zeros(0, 2);
if source == "latest_packet" && target == "cv_reconstruction"
    % Route on the right side of the ZOH reconstruction box.
    waypoints = [0.66, 0.62; 0.66, 0.34];
elseif source == "reference_plant" && target == "evaluation"
    % Keep the reference comparison route below the lower plant boxes.
    waypoints = [0.42, 0.14; 0.84, 0.14];
end
end

function points = routed_points(source, target, waypoints)
sourceCenter = rectangle_center(source);
targetCenter = rectangle_center(target);
route = [sourceCenter; waypoints; targetCenter];
points = route;
sourceDirection = route(2, :) - sourceCenter;
targetDirection = route(end - 1, :) - targetCenter;
points(1, :) = sourceCenter + rectangle_intersection(source, sourceDirection);
points(end, :) = targetCenter + rectangle_intersection(target, targetDirection);
end

function center = rectangle_center(rectangle)
center = [rectangle(1) + rectangle(3) / 2, rectangle(2) + rectangle(4) / 2];
end

function offset = rectangle_intersection(rectangle, direction)
if all(direction == 0)
    error("teleopDelay:AnalysisArchitectureGeometryInvalid", ...
        "Architecture edge endpoints cannot share a node center.");
end
halfWidth = rectangle(3) / 2;
halfHeight = rectangle(4) / 2;
scales = [halfWidth / abs(direction(1)), halfHeight / abs(direction(2))];
scales(~isfinite(scales)) = inf;
offset = direction * min(scales);
end

function crossings = find_crossings(edges, positions, nodes)
crossings = table('Size', [0, 4], ...
    'VariableTypes', {'string', 'string', 'string', 'double'}, ...
    'VariableNames', {'source', 'target', 'intermediate_node', 'segment_index'});
for edgeIndex = 1:numel(edges)
    points = edges(edgeIndex).points;
    for segmentIndex = 1:size(points, 1) - 1
        first = points(segmentIndex, :);
        second = points(segmentIndex + 1, :);
        for nodeIndex = 1:numel(nodes)
            node = nodes(nodeIndex);
            if node == edges(edgeIndex).source || node == edges(edgeIndex).target
                continue;
            end
            rectangle = positions.(char(node));
            if segment_intersects_interior(first, second, rectangle)
                row = table(edges(edgeIndex).source, edges(edgeIndex).target, node, ...
                    segmentIndex, "VariableNames", crossings.Properties.VariableNames);
                crossings = [crossings; row]; %#ok<AGROW>
            end
        end
    end
end
end

function intersects = segment_intersects_interior(first, second, rectangle)
% Use an open rectangle interior so boundary endpoints are allowed.
lower = rectangle(1:2);
upper = rectangle(1:2) + rectangle(3:4);
delta = second - first;
tLower = 0;
tUpper = 1;
for dimension = 1:2
    if abs(delta(dimension)) < eps
        if first(dimension) <= lower(dimension) || first(dimension) >= upper(dimension)
            intersects = false;
            return;
        end
        continue;
    end
    values = [(lower(dimension) - first(dimension)) / delta(dimension), ...
        (upper(dimension) - first(dimension)) / delta(dimension)];
    tLower = max(tLower, min(values));
    tUpper = min(tUpper, max(values));
end
intersects = tUpper > tLower && tUpper > 0 && tLower < 1;
end
