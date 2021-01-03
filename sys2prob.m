% sys2prob Formulate an optimization problem given a system
function problem = sys2prob(sys)

scale = 'log';

%% The independent variables are
%   gen_rated_power[1..N_GENS]
%   battery_filter_span, if two batteries are installed
nvars = sys.N_GENS + (sys.N_BATTS-1);
varNames = cellfun(@(x)([x.NAME '_gen_rated_power (kW)']),sys.gens, ...
    'UniformOutput',false);

%% Cost function
if sys.N_BATTS == 1
    
    fun = @(x)cost_fun_design(sys, ...
            x(1:sys.N_GENS) ... Rated power of each generator 
        );
    
elseif sys.N_BATTS == 2
    
    fun = @(x)cost_fun_design(sys, ...
            x(1:sys.N_GENS), ... Rated power of each generator 
            x(sys.N_GENS+1) ... Battery filter span
        );
    varNames{end+1} = 'battery_filter_span';
    
end

%% Lower bound
lb = [...
    ones(sys.N_GENS,1); ...
    1*ones(sys.N_BATTS-1)...
];

%% Upper bound

ub = [ ...
        ... Rated power of each generator upper bound
        cellfun(@(x)(x.MAX_RATED_POWER),sys.gens)'; ...
        ... battery_filter_span upper bound
        ( 10*8760 * ones(sys.N_BATTS-1) ) ...
    ];

%% Use log scale
if strcmp(scale,'log')
    lb = log10(lb);
    ub = log10(ub);
    obj = @(x)fun(10.^x);
else
    obj = fun;
end

%% Define problem
problem = struct(...
    'objective', obj, ...
    'nvars', nvars, ...
    'lb', lb, ...
    'ub', ub, ...
    'varNames', {varNames},...
    'scale', scale ...
);
