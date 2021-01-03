function sys = make_island_Brushett2020_2025(name,nameValueArgs)
% Use Brushett 2020 flow battery model with other data from PNNL2019_2025
% https://doi.org/10.1021/acsenergylett.0c00140

arguments
    
    %% Name
    name string = "Brushett2020"
    
    %% Demand inputs
    nameValueArgs.d_profile_fName
    nameValueArgs.household_annual_kWh
    nameValueArgs.households
    
    %% LIB inputs
    
    nameValueArgs.install_LIB
    nameValueArgs.LIB_cost_E
    nameValueArgs.LIB_cost_P
    nameValueArgs.LIB_cycle_life
    nameValueArgs.LIB_max_years_life

    %% flow inputs
    
    % Should the flow battery be installed
    nameValueArgs.install_flow (1,1) {mustBeNumericOrLogical} = true
    
    % CAPEX per kWh
    nameValueArgs.flow_cost_E ... %TODO (1,1) {mustBeNonnegative} account for functional
        = 'default'   % ($/kWh)
    
    % CAPEX per kW
    nameValueArgs.flow_cost_P ... %TODO (1,1) {mustBeNonnegative} account for functional
        = 'default' % ($/kW)
    
    % Cycle life
    nameValueArgs.flow_cycle_life (1,1) {mustBePositive,mustBeInteger} ...
        = 500*15 % (charge and discharge switches)
    
    % Max lifespan in years
    % "The storage cost and replacement costs (after 15 yr)" pg 12
    % http://dx.doi.org/10.1016/j.rser.2014.10.011
    nameValueArgs.flow_max_years_life (1,1) {mustBePositive,mustBeInteger} ...
        = 15 % (Years)
    
    %% tidal inputs
    nameValueArgs.install_tidal
    nameValueArgs.tidal_cost_P
    nameValueArgs.tidal_lifetime
    
    %% solar inputs
    nameValueArgs.install_solar
    nameValueArgs.solar_cost_P
    nameValueArgs.solar_lifetime
        
    %% Other inputs
    nameValueArgs.grid_costs
    
    % Base island to fill in missing parameters
    nameValueArgs.base_islands = {@make_island_PNNL2019_2025} %TODO test is function handle
    
end

%% Construct cost function
assert(~xor(strcmp(nameValueArgs.flow_cost_E, 'default'), ...
        strcmp(nameValueArgs.flow_cost_P, 'default')), ...
    'Both energy and power costs must be default to use default function');

if strcmp(nameValueArgs.flow_cost_E, 'default') ...
        && strcmp(nameValueArgs.flow_cost_P, 'default')
    
    % Use captial cost ($/kWh) wrt E/P ratio from Fig 5 
    %   https://doi.org/10.1021/acsenergylett.0c00140
    flow_cost_E_fun = load('fitCostCuveResult.mat');
    flow_cost_E_fun = @(x)(feval(flow_cost_E_fun.fitobject, x));
    % Assume energy capacity cost is independent of E/P
    nameValueArgs.flow_cost_E = 0.7*feval(flow_cost_E_fun, inf) ...
        + 180; % Plus Construction and Commissioning costs
    % The remain cost is related to powr
    nameValueArgs.flow_cost_P = @(x)(...
        0.7*(feval(flow_cost_E_fun, ...
                x.capacity_energy / x.capacity_power) ...
            ... Subject baseline energy cost
            - feval(flow_cost_E_fun, inf)) ...
        ... Convert from $/kWh to $/kW
        * x.capacity_energy / x.capacity_power ... 
        + 211 + 95 ... Plus PCS and BOP costs
    );
    
end

%% Make island

% Make island from base island
base_island = nameValueArgs.base_islands{1};
if length(nameValueArgs.base_islands) <= 1
    nameValueArgs = rmfield(nameValueArgs, 'base_islands');
else
    nameValueArgs.base_islands = nameValueArgs.base_islands{min(2,end):end};
end

% Arrange arguments to pas
args2pass = [fieldnames(nameValueArgs) struct2cell(nameValueArgs)]';

% Make island
sys = base_island(name, args2pass{:});