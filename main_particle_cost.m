%MAIN_particle Parametric study of how component costs affect LCOE for
%optimized battery and generator sizes using particle swarm
%
%   Size a single LIB and generator to meet demand using a simple charge
%   law of charge when supply>demand, and discharge otherwise.

confirmClearCloseAll

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
nSteps = 20;
costScaleMin = 0.1;
costScaleMax = 2;
costScale = linspace(costScaleMin, costScaleMax, nSteps);
LIB_cost_E = 189+96*costScale;
flow_cost_P = costScale;
solar_cost_P = 2800*costScale;
tidal_cost_P = 4300*costScale;

clear configs
configs(nSteps*4) = struct('name',{{}}, 'island_base',{{}}, 'params',{{}});

% Assign parameters to configurations
configs(0*nSteps+(1:nSteps)) = struct( ...
    'name', config_base.name ...
    ,'island_base', config_base.island_base ...
    ,'params', arrayfun(@(x)({'LIB_cost_E',x}),LIB_cost_E, ...
        'UniformOutput',false) ...
);
configs(1*nSteps+(1:nSteps)) = struct( ...
    'name', config_base.name ...
    ,'island_base', config_base.island_base ...
    ,'params', arrayfun(@(x)({'flow_cost_P',x}),flow_cost_P, ...
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
       'Display', 'final', ...
       ... Increased swarm size from default of 100 to encourage exploration
       'SwarmSize', 200, ... 
       'UseParallel', true, ...
       'PlotFcn', 'pswplotbestf');

    % Run the partical swarm optimization
    problem.solver = 'particleswarm';
    problem.options = options;
    [x,~,~,solution] = particleswarm(problem);
    
    %% Plot results
    problem.objective(x);
    [LCOE, LCOE_parts, LCOE_parts_names, summary] = sys.LCOE(false);
%     sys.plot(sprintf('LCOE: %.0f $/MWh', LCOE*1000))
    
    %% Save inputs and outputs
    syss{config_n} = sys;
    problems{config_n} = problem;
    solutions{config_n} = solution;
    summaries{config_n} = summary;
    
end

%% Results

% The parts of the LCOE to consider
lcoeParts = {'tidal','solar', ...
    'LIB_Energy','LIB_Power','LIB_error',...
    'flow_Energy','flow_Power','flow_error','grid'};

% Li-Ion Battery Cost
figure('WindowStyle','docked')
subplot(2,2,1)
area(costScale, cell2mat( cellfun( ...
    @(y)(cellfun(@(x)(y.lcoe.(x).cost),lcoeParts)),...
    summaries((1:nSteps)+0*nSteps)',...
    'UniformOutput',false)))
title('Li-Ion Battery Cost')
ylabel('LCOE ($/kW)')
xlabel('Baseline cost multiplier')
xlim([0.1 2])

% Flow Battery Cost
subplot(2,2,2)
area(costScale, cell2mat( cellfun( ...
    @(y)(cellfun(@(x)(y.lcoe.(x).cost),lcoeParts)),...
    summaries((1:nSteps)+1*nSteps)',...
    'UniformOutput',false)))
title('Flow Battery Cost')
ylabel('LCOE ($/kW)')
xlabel('Baseline cost multiplier')
xlim([0.1 2])

% Solar PV Cost
subplot(2,2,3)
area(costScale, cell2mat( cellfun( ...
    @(y)(cellfun(@(x)(y.lcoe.(x).cost),lcoeParts)),...
    summaries((1:nSteps)+0*nSteps)',...
    'UniformOutput',false)))
title('Solar PV Cost')
ylabel('LCOE ($/kW)')
xlabel('Baseline cost multiplier')
xlim([0.1 2])

% Tidal Generator Cost
subplot(2,2,4)
area(costScale, cell2mat( cellfun( ...
    @(y)(cellfun(@(x)(y.lcoe.(x).cost),lcoeParts)),...
    summaries((1:nSteps)+0*nSteps)',...
    'UniformOutput',false)))
title('Tidal Generator Cost')
ylabel('LCOE ($/kW)')
xlabel('Baseline cost multiplier')
xlim([0.1 2])

legend(strrep(lcoeParts','_',' '), 'Interpreter','Latex')

pathBase = ['output/' mfilename '_' datestr(now(),'yyyymmdd-hhMMss')];

% Save workspace
save([pathBase '.mat'])

% Save Figures
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = get(FigHandle, 'Name');
  if isempty(FigName)
      FigName = sprintf('Figure %d', FigHandle.Number);
  end
  savefig(FigHandle, [pathBase '_' FigName, '.fig']);
end