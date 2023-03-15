function sys = make_island_Zakeri2015(name,nameValueArgs)
% http://dx.doi.org/10.1016/j.rser.2014.10.011

arguments
    
    %% Name
    name string = "PNNL2019_2025"
    
    %% Demand inputs
    nameValueArgs.d_profile_fName
    nameValueArgs.household_annual_kWh
    nameValueArgs.households
    
    %% LIB inputs
    
    % Should the LIB be installed
    nameValueArgs.install_LIB (1,1) {mustBeNumericOrLogical} ...
        = true
    
    % Energy capacity capital cost + construction & commissioning
    % From Fig 4. - cost of storage part
    % http://dx.doi.org/10.1016/j.rser.2014.10.011
    nameValueArgs.LIB_cost_E (1,1) {mustBePositive} ...
        = 969.84 % ($/kWh)
    
    % Power conversion system (PCS) + balance of plant (BOP)
    % From Fig 3. - independent power conversion costs
    % http://dx.doi.org/10.1016/j.rser.2014.10.011
    nameValueArgs.LIB_cost_P (1,1) {mustBePositive} ...
        = 564.82 % ($/kW)

    % Cycles @ 80% DOD
    % "long lifetime (~10,000 cycles)" pg 12
    % http://dx.doi.org/10.1016/j.rser.2014.10.011
    nameValueArgs.LIB_cycle_life (1,1) {mustBePositive,mustBeInteger} ...
        = 10000 % (total charges)
    
    % Max lifespan in years
    % estimated from flow battery from
    % http://dx.doi.org/10.1016/j.rser.2014.10.011
    nameValueArgs.LIB_max_years_life (1,1) {mustBePositive,mustBeInteger} ...
        = 15 % (Years)

    %% flow inputs
    
    % Should the flow battery be installed
    nameValueArgs.install_flow (1,1) {mustBeNumericOrLogical} = true
    
    % CAPEX per kWh
    % From Fig 4. - cost of storage part (NOTE: this includes the membrane
    % costs at the typical installed power outputs)
    % http://dx.doi.org/10.1016/j.rser.2014.10.011
    nameValueArgs.flow_cost_E ... %TODO (1,1) {mustBeNonnegative} account for functional
        = 393+180   % ($/kWh)
    
    % CAPEX per kW
    % From Fig 3. - independent power conversion costs
    % http://dx.doi.org/10.1016/j.rser.2014.10.011
    nameValueArgs.flow_cost_P ... %TODO (1,1) {mustBeNonnegative} account for functional
        = 211+95 % ($/kW)
    
    % Cycle life
    % "bulk energy storage and T&D applications with 365–500 cycles per year."
    % times the 15 year lifetime below.
    % http://dx.doi.org/10.1016/j.rser.2014.10.011
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
    
end

%% Make island
args2pass = [fieldnames(nameValueArgs) struct2cell(nameValueArgs)]';
sys = make_island_aspirational(name, args2pass{:});