function tolerance = machine_tolerance(values)
% machine_tolerance  Scale-aware machine-precision floor for G classifications.

validateattributes(values, {'numeric'}, {'vector', 'real', 'finite'});
scale = max(1.0, max(abs(double(values))));
tolerance = 32 * eps(scale);
end
