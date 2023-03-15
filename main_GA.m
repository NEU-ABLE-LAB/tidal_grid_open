%MAIN_GA Optimize battery and generator sizes using genetic algorithm
%   Size a single LIB and generator to meet demand using a simple charge
%   law of charge when supply>demand, and discharge otherwise.

%% Make island
sys = make_island_aspirational('Genetic Algorithm');

%% GA Optimization
% The independent variables are
%   (1) log10(gen_rated_power_total)
%   (2) battery_filter_span
%   (3) gen_rated_power_split

% Cost function
fun = @(x)cost_fun_design(sys, ...
        10^x(1), ... gen_rated_power_total
        x(2), ... battery_filter_span
        x(3) ... gen_rated_power_split
    );

nvars = 3;

% Lower bound
lb = [log10(1); 1; 0];

% Upper bound
ub = [ ...
        ... gen_rated_power_total upper bound
        log10(sum(cellfun(@(x)(x.MAX_RATED_POWER),sys.gens))), ...
        ... battery_filter_span upper bound
        8760, ...
        ... gen_rated_power_split upper bound
        100 ...
    ];

% Optimization options
options = optimoptions( ...
   'ga', ... name
   'Display', 'iter', ...
   'PlotFcn', 'gaplotbestf');

% Run the partical swarm optimization
x = ga(fun, nvars, [],[],[],[],lb, ub, [], options);

%% Plot results
[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
sys.plot(sprintf('LCOE: %.1f %s/kW', LCOE*100,  char(0162)))

