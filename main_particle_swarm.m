%MAIN_particle_swarm Determine ideal size of swarm to optimize battery and
%generator sizes using particle swarm
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
config = struct( ...
    'name', 'Brushett2020_2025' ...
    ,'island_base', @make_island_Brushett2020_2025 ...
    ,'params', {{}} ...
);
   

%% Optimize each island type
swarmSizes = round(logspace(2,3.7,5));
nSwarmSizes = length(swarmSizes);

timings = zeros(1,nSwarmSizes);
syss = cell(1,nSwarmSizes);
problems = cell(1,nSwarmSizes);
solutions = cell(1,nSwarmSizes);
summaries = cell(1,nSwarmSizes);

for swarmSizeN = 1:nSwarmSizes

    swarmSize = swarmSizes(swarmSizeN);

    tic;

    %% Make island

    name = config.name;
    island_base = config.island_base;
    params = config.params;

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
       'Display', 'final', ...
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
    syss{swarmSizeN} = sys;
    problems{swarmSizeN} = problem;
    solutions{swarmSizeN} = solution;
    summaries{swarmSizeN} = summary;

    timings(swarmSizeN) = toc;
    
    fprintf('SwarmSize=%d : LCOE=%d : Time=%d\n', ...
        swarmSize, LCOE, toc);
end

%% RESULTS
% On Discovery with 65 workers

% LCOE variation with swarm Size
% ==============================
% (cellfun(@(x)(x.lcoe.total),summaries) - summaries{1}.lcoe.total)
% 0   -0.0053776   -0.0062261   -0.0050337   -0.0054277

% Timings
% =======
% swarmSizes
% 100         266           708          1884        5012
% timings
% 71.517       52.043        67.37        111.7       225.34