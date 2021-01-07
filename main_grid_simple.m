%MAIN_grid grid search a single battery and generator pair 

confirmClearCloseAll

%% Parameters

% How much should the maximum generator rated power be scaled down
% gen_rated_power_limit_scale = 2E2;
gen_rated_power_limit_scale = 1;

% Number of points to evaluate on each axis of the grid
grid_n_pts = 100;

% Maximum LCOE to show on graph
max_LCOE = 100; % ($/kWh)

% The base island configuration
% island_base = @make_island_aspirational;
% island_base = @make_island_Zakeri2015;
% island_base = @make_island_PNNL2019_2018;
% island_base = @make_island_PNNL2019_2025;
% island_base = @make_island_Brushett2020_2018;
island_base = @make_island_Brushett2020_2025;

% Devices to install
install_solar = [true  true  true  false];
install_tidal = [true  true  false true ];
install_LIB   = [true  false true  true ];
install_flow  = [false true  true  true ];
installed_names = [...
    "Solar-Tidal-LIB", ...
    "Solar-Tidal-Flow", ...
    "Solar-LIB-Flow", ...
    "Tidal-LIB-Flow", ...
];

%% Make island
N_installed = length(installed_names);
syss = cell(1,N_installed);
problems = cell(1,N_installed);
solutions = cell(1,N_installed);
summaries = cell(1,N_installed);

for installed_sys_N = 1:N_installed
% for installed_sys_N = N_installed

    % Install system
    sys = island_base(...
        ['Grid Search - ' ...
            func2str(island_base)...
            ' [' installed_names{installed_sys_N} ']'], ...
        'install_solar', install_solar(installed_sys_N), ...
        'install_tidal', install_tidal(installed_sys_N), ...
        'install_LIB',   install_LIB(installed_sys_N), ...
        'install_flow',  install_flow(installed_sys_N));

    % Run Grid Search
    [problem, solution] = grid_search(...
            sys, ...
            gen_rated_power_limit_scale, ...
            grid_n_pts);
        
    % Plot results
    summary = grid_plot(sys, problem, solution, max_LCOE);
    
    syss{installed_sys_N} = sys;
    problems{installed_sys_N} = problem;
    solutions{installed_sys_N} = solution;
    summaries{installed_sys_N} = summary;

end

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

%% Grid search
function [problem, solution] = grid_search(...
        sys, ...
        gen_rated_power_limit_scale, ...
        grid_n_pts)

    % Formulate problem
    problem = sys2prob(sys);

    % Identify variables
    assert(problem.nvars == 2, 'Exactly two optimization variables not found');

    % Reduce scale of max rated power
    if strcmp(problem.scale,'linear')
        problem.ub(contains(problem.varNames,'_gen_rated_power')) = ...
            problem.ub(contains(problem.varNames,'_gen_rated_power')) ...
            ./ gen_rated_power_limit_scale;
    end

    % Define grid
    if strcmp(problem.scale,'linear')
        x = linspace(problem.lb(1), problem.ub(1), grid_n_pts);
        y = linspace(problem.lb(2), problem.ub(2), grid_n_pts);
    elseif strcmp(problem.scale,'log')
        x = log10(logspace(problem.lb(1), problem.ub(1), grid_n_pts));
        y = log10(logspace(problem.lb(2), problem.ub(2), grid_n_pts));
    end
    [X,Y] = meshgrid(x,y);

    % Evaluate problem on grid
    Z = zeros(size(X));
    objective = problem.objective;
    parfor k = 1:numel(X)
        Z(k) = objective([X(k); Y(k)]); %#ok<PFBNS>
    end
%     Z = arrayfun(@(x,y)(problem.objective([x;y])), X,Y);
    [~, k_min] = min(Z(:));
    x_min = X(k_min);
    y_min = Y(k_min);
    
    % Improve minimum
    problem.solver = 'fmincon';
    problem.x0 = [x_min; y_min];
    problem.options = optimoptions('fmincon', ...
        'Display','off');
    [xy_min, z_min] = fmincon(problem);
    x_min = xy_min(1);
    y_min = xy_min(2);
    
    % Construction solution structure
    solution = struct(...
        'X',X, 'Y',Y, 'Z',Z, ...
        'x_min',x_min, 'y_min',y_min, 'z_min',z_min, 'k_min',k_min);

end

%% Plot results
function summary = grid_plot(sys, problem, solution, max_LCOE)
    
    % Unpack solution
    if strcmp(problem.scale,'linear')
        X = solution.X;
        Y = solution.Y;
        Z = solution.Z;
        x_min = solution.x_min;
        y_min = solution.y_min;
        z_min = solution.z_min;
        k_min = solution.k_min;
    elseif strcmp(problem.scale,'log')
        X = 10.^solution.X;
        Y = 10.^solution.Y;
        Z = solution.Z;
        x_min = 10.^solution.x_min;
        y_min = 10.^solution.y_min;
        z_min = solution.z_min;
        k_min = solution.k_min;
    end

    % Get best value
    [LCOE, LCOE_parts, LCOE_parts_names, summary] ...
        = problem.objective([solution.x_min, solution.y_min]);
    plot_title = sprintf('LCOE - %.0f $/MWh', LCOE*1000);
    
    % Plot grid surface
    figure('windowstyle','docked')
    
    Z0 = Z*1000; % Convert $/kWH to $/MWh
    Z0(Z0>max_LCOE*1000) = nan;
%     Z0 = log10(Z0);

    [~,h_s] = contourf(X,Y,Z0,10);
%     [~,h_s] = contourf(X,Y,Z0, 0:1000:max_LCOE*1000, ...
%         'ShowText', 'on');
%     h_s.TextList = h_s.TextList(1:5:end);
    h_s.LineStyle = 'none';
    h_s.Parent.XScale = 'log';
    h_s.Parent.YScale = 'log';
    
    title([sys.NAME ': ' plot_title])
    xlabel(strrep(problem.varNames{1},'_',' '))
    ylabel(strrep(problem.varNames{2},'_',' '))
    zlabel('LCOE ($)')
    view(2)
    h_cb = colorbar;
    h_cb.Label.String = 'LCOE ($/MWh)';
    
    % Plot contours
    hold on
    [~,h_c] = contourf(X,Y,Z0,5);

    % Plot best point
    plot3(x_min, y_min, z_min, ...
        'r.', 'MarkerSize',20)
    hold off

    %% Plot LCOE pie chart & time series data
    sys.LCOE(true);
    sys.plot(plot_title)

end
