%MAIN_particle Parametric study of how component costs affect LCOE for
%optimized battery and generator sizes using particle swarm
%
%   Size a single LIB and generator to meet demand using a simple charge
%   law of charge when supply>demand, and discharge otherwise.

%% Parameters

% % 2018 Cost estimates for batteries, with Brushett2020 flow battery cost model
% config = struct( ...
%     'name', 'Brushett2020_2018' ...
%     ,'island_base', @make_island_Brushett2020_2018 ...
%     ,'params', {{}} ...
% );

% 2025 Cost estimates for batteries, with Brushett2020 flow battery cost model
config_base = struct( ...
    'name', 'Brushett2020_2025' ...
    ,'island_base', @make_island_Brushett2020_2025 ...
    ,'params', {{}} ...
);

% Cost parameters to vary
nSteps = 10;
LIB_cost_E = 189+96*linspace(0.5,1.5,nSteps);
flow_cost_P = linspace(0.5,1.5,nSteps);
solar_cost_P = 2800*linspace(0.5,1.5,nSteps);
tidal_cost_P = 4300*linspace(0.5,1.5,nSteps);

clear configs
configs(nSteps*4) = struct('name',{{}}, 'island_base',{{}}, 'params',{{}});

% Assign parameters to configurations
configs(0*nSteps+(1:nSteps)) = struct( ...
    'name', config_base.name ...
    ,'island_base', config_base.island_base ...
    ,'params', arrayfun(@(x)({'LIB_cost_E_array',x}),LIB_cost_E, ...
        'UniformOutput',false) ...
);
configs(1*nSteps+(1:nSteps)) = struct( ...
    'name', config_base.name ...
    ,'island_base', config_base.island_base ...
    ,'params', arrayfun(@(x)({'flow_cost_P_array',x}),flow_cost_P, ...
        'UniformOutput',false) ...
);
configs(2*nSteps+(1:nSteps)) = struct( ...
    'name', config_base.name ...
    ,'island_base', config_base.island_base ...
    ,'params', arrayfun(@(x)({'solar_cost_P',x}),solar_cost_P, ...
        'UniformOutput',false) ...
);
configs(3*nSteps+(1:nSteps)) = struct( ...
    'name', config_base.name ...
    ,'island_base', config_base.island_base ...
    ,'params', arrayfun(@(x)({'tidal_cost_P',x}),tidal_cost_P, ...
        'UniformOutput',false) ...
);

% Total number of configurations to test
n_configs = length(configs);


%% Optimize each island type
syss = cell(1,n_configs);
problems = cell(1,n_configs);
solutions = cell(1,n_configs);
summaries = cell(1,n_configs);

for config_n = 1:n_configs

    %% Make island
    
    name = configs(config_n).name;
    island_base = configs(config_n).island_base;
    params = configs(config_n).params;
        
    sys = island_base(['Partical Swarm - ' name], params{:});
    
    %% Particle Swarm Optimization

    % Formulate problem
    problem = sys2prob(sys);

    % Optimization options
    options = optimoptions( ...
       'particleswarm', ... name
       'HybridFcn','fmincon', ...
       'Display', 'iter', ...
       'UseParallel', true, ...
       'PlotFcn', 'pswplotbestf');

    % Run the partical swarm optimization
    problem.solver = 'particleswarm';
    problem.options = options;
    [x,~,~,solution] = particleswarm(problem);
    
    %% Plot results
    problem.objective(x);
    [LCOE, LCOE_parts, LCOE_parts_names, summary] = sys.LCOE(true);
    sys.plot(sprintf('LCOE: %.0f $/MWh', LCOE*1000))
    
    %% Save inputs and outputs
    syss{config_n} = sys;
    problems{config_n} = problem;
    solutions{config_n} = solution;
    summaries{config_n} = summary;
    
end
