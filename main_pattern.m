%MAIN_particle Optimize battery and generator sizes using pattern search
%   Size a single LIB and generator to meet demand using a simple charge
%   law of charge when supply>demand, and discharge otherwise.

%% Make island
sys = make_island_aspirational('Pattern search');

%% Pattern search
% The independent variables are
%   gen_rated_power_total
%   battery_filter_span
%   gen_rated_power_split

% Cost function
fun = @(x)cost_fun_design(sys, ...
        x(1), ... gen_rated_power_total
        x(2), ... battery_filter_span
        x(3) ... gen_rated_power_split
    );

nvars = 3;

% Lower bound
lb = [0; 1; 0];

% Upper bound
ub = [ ...
        ... gen_rated_power_total upper bound
        sum(cellfun(@(x)(x.MAX_RATED_POWER),sys.gens)), ...
        ... battery_filter_span upper bound
        8760, ...
        ... gen_rated_power_split upper bound
        100 ...
    ];

% Initial condition
x0 = x;

% Optimization options
options = optimoptions( ...
   'patternsearch', ... name
   'Display', 'iter', ...
   'PlotFcn', 'psplotbestf');

% Run the partical swarm optimization
x = patternsearch(fun, x0, [],[],[],[],lb, ub, [], options);

%% Plot results
[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
sys.plot(sprintf('LCOE: %.1f %s/kW', LCOE*100,  char(0162)))

