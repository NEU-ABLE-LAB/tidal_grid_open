%MAIN_particle Optimize battery and generator sizes using particle swarm
%   Size a single LIB and generator to meet demand using a simple charge
%   law of charge when supply>demand, and discharge otherwise.

%% Parameters
configs = struct('name',{}, 'island_base',{}, 'params',{});

% % 2018 Cost estimates for batteries, with Brushett2020 flow battery cost model
% configs(end+1) = struct( ...
%     'name', 'Brushett2020_2018' ...
%     ,'island_base', @make_island_Brushett2020_2018 ...
%     ,'params', {{}} ...
% );

% 2025 Cost estimates for batteries, with Brushett2020 flow battery cost model
configs(end+1) = struct( ...
    'name', 'Brushett2020_2025' ...
    ,'island_base', @make_island_Brushett2020_2025 ...
    ,'params', {{}} ...
);

% Total number of configurations to test
n_configs = length(configs);
    

%% Optimize each island type
syss = cell(1,n_configs);
problems = cell(1,n_configs);
solutions = cell(1,n_configs);
summaries = cell(1,n_configs);
swarmSizes = logspace(2,3.7,5);
timings = zeros(size(swarmSizes));

for config_n = 1:n_configs
    for swarmSize = swarmSizes

        tic;

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
           ... Increased swarm size from default of 100 to encourage exploration
           'SwarmSize', swarmSize, ... 
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
    
        timings(config_n) = toc;
        fprintf('SwarmSize=%d : LCOE=%d : Time=%d', ...
            swarmSize, LCOE, toc);
    end
end
