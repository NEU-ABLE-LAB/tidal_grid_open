%MAIN_grid grid search a single battery and generator pair 

%% Make island
sys = make_island_aspirational('Partical Swarm', ...
    'install_solar', true, ...
    'install_tidal', false, ...
    'install_LIB',   true, ...
    'install_flow',  false);

%% Grid search

% The independent variables are
%   gen_rated_power[1..N_GENS]
%   battery_filter_span, if two batteries are installed
nvars = sys.N_GENS + (sys.N_BATTS-1);

% Cost function
if sys.N_BATTS == 1
    
    fun = @(x)cost_fun_design(sys, ...
            x(1:sys.N_GENS) ... Rated power of each generator 
        );
    
elseif sys.N_BATTS == 2
    
    fun = @(x)cost_fun_design(sys, ...
            x(1:sys.N_GENS), ... Rated power of each generator 
            x(3) ... Battery filter span
        );
    
end

% Lower bound
lb = [zeros(sys.N_GENS,1); 1*ones(sys.N_BATTS-1)];

% Upper bound
ub = [ ...
        ... Rated power of each generator upper bound
        cellfun(@(x)(x.MAX_RATED_POWER),sys.gens)'; ...
        ... battery_filter_span upper bound
        10*8760 * ones(sys.N_BATTS-1) ...
    ];

% Optimization options
options = optimoptions( ...
   'particleswarm', ... name
   'Display', 'iter', ...
   'PlotFcn', 'pswplotbestf');

% Run the partical swarm optimization
x = particleswarm(fun, nvars, lb, ub, options);

%% Plot results
[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
sys.plot(sprintf('LCOE: %.1f %s/kW', LCOE*100,  char(0162)))

