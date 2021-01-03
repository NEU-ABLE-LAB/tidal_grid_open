function sys = make_island_PNNL2019_2018(name,nameValueArgs)
% https://www.energy.gov/sites/prod/files/2019/07/f65/Storage%20Cost%20and%20Performance%20Characterization%20Report_Final.pdf
arguments
    
    %% Name
    name string = "PNNL2019_2018"
    
    %% Demand inputs
    nameValueArgs.d_profile_fName
    nameValueArgs.household_annual_kWh
    nameValueArgs.households
    
    %% LIB inputs
    
    % Should the LIB be installed
    nameValueArgs.install_LIB (1,1) {mustBeNumericOrLogical} ...
        = true
    
    % Energy capacity capital cost + construction & commissioning
    nameValueArgs.LIB_cost_E (1,1) {mustBePositive} ...
        = 271+101 % ($/kWh)
    
    % Power conversion system (PCS) + balance of plant (BOP)
    nameValueArgs.LIB_cost_P (1,1) {mustBePositive} ...
        = 288+100 % ($/kW)

    % Cycles @ 80% DOD
    nameValueArgs.LIB_cycle_life (1,1) {mustBePositive,mustBeInteger} ...
        = 3500 % (total charges)
    
    % Max lifespan in years
    nameValueArgs.LIB_max_years_life (1,1) {mustBePositive,mustBeInteger} ...
        = 10 % (Years)

    %% flow inputs
    
    % Should the flow battery be installed
    nameValueArgs.install_flow (1,1) {mustBeNumericOrLogical} = true
    
    % Energy capacity capital cost + construction & commissioning
    % NOTE: This also includes the membrane costs
    nameValueArgs.flow_cost_E ... %TODO (1,1) {mustBeNonnegative} account for functional
        = 555+190   % ($/kWh)
    
    % Power conversion system (PCS) + balance of plant (BOP)
    nameValueArgs.flow_cost_P ... %TODO (1,1) {mustBeNonnegative} account for functional
        = 350+100 % ($/kW)
    
    % Cycles @ 80% DOD
    nameValueArgs.flow_cycle_life (1,1) {mustBePositive,mustBeInteger} ...
        = 10000 % (charge and discharge switches)
    
    % Max lifespan in years
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
    
end

%% Make island
args2pass = [fieldnames(nameValueArgs) struct2cell(nameValueArgs)]';
sys = make_island_aspirational(name, args2pass{:});