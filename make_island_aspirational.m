function sys = make_island_aspirational(name,nameValueArgs)
%MAKE_ISLAND_ASPIRATIONAL Make an aspirational islanded power system
%TODO refactor code so this is named make_island_base
arguments
    
    %% Name
    name string = "PNNL2019_2018"
    
    %% Demand inputs
    
    % Power profile
    nameValueArgs.d_profile_fName string ...
        = 'data/OI_darthrmwh_iso_4005_20190101_20191231'
    
    %  Avg US home uses ~10,649 kWh/yr
    %   https://www.eia.gov/tools/faqs/faq.php?id=97&t=3
    nameValueArgs.household_annual_kWh (1,1) {mustBePositive} ...
        = 10649        
    
    %  Block island has 429 households
    %   https://www.point2homes.com/US/Neighborhood/RI/New-Shoreham/Block-Island-Demographics.html
    nameValueArgs.households (1,1) {mustBePositive,mustBeInteger} ...
        = 429
    
    %% LIB inputs
    
    % Should the LIB be installed
    nameValueArgs.install_LIB (1,1) {mustBeNumericOrLogical} ...
        = true
    
    % Cost per stored energy ($/kWh)
    %   Aspirational estimate from 'Model numbers for Mike.docx'
    nameValueArgs.LIB_cost_E (1,1) {mustBePositive} ...
        = 220
    
    % Cost per rated power ($/kW)
    %   Aspirational estimate from 'Model numbers for Mike.docx'
    nameValueArgs.LIB_cost_P (1,1) {mustBeNonnegative} ...
        = 0

    % Lifetime cycle limit
    %   Aspirational estimate from 'Model numbers for Mike.docx'
    nameValueArgs.LIB_cycle_life (1,1) {mustBePositive,mustBeInteger} ...
        = 4000 % (total charges)
    
    % Lifetime year limit
    %TODO justify this
    nameValueArgs.LIB_max_years_life (1,1) {mustBePositive,mustBeInteger} ...
        = 20 % (Years)

    %% flow inputs
    
    % Should the flow battery be installed
    nameValueArgs.install_flow (1,1) {mustBeNumericOrLogical} = true
    
    % Cost per stored energy ($/kWh)
    %   Aspirational estimate from 'Model numbers for Mike.docx'
    nameValueArgs.flow_cost_E ... %TODO (1,1) {mustBeNonnegative} account for functional
        = 30
    
    % Cost per rated power ($/kW)
    %   Aspirational estimate from 'Model numbers for Mike.docx'
    nameValueArgs.flow_cost_P ... %TODO (1,1) {mustBeNonnegative} account for functional
        = 1000
    
    % Lifetime cycle limit
    %   Aspirational estimate from 'Model numbers for Mike.docx'
    nameValueArgs.flow_cycle_life (1,1) {mustBePositive,mustBeInteger} ...
        = 12000 % (charge and discharge switches)
    
    % Lifetime year limit
    %TODO justify this
    nameValueArgs.flow_max_years_life (1,1) {mustBePositive,mustBeInteger} ...
        = 20 % (Years)
    
    %% tidal inputs
    
    % Should tidal generation be installed
    nameValueArgs.install_tidal (1,1) {mustBeNumericOrLogical} = true
    
    % Cost per rated power ($/kW)
    %   From doi:10.1016/j.energy.2016.03.123
    nameValueArgs.tidal_cost_P (1,1) {mustBePositive} ...
        = 4300
    
    % Lifetime of generator in years
    %   default from doi:10.1016/j.energy.2016.03.123
    nameValueArgs.tidal_lifetime (1,1) {mustBePositive,mustBeInteger} ...
        = 20   
    
    %% solar inputs
    
    % Should solar generation be installed
    nameValueArgs.install_solar (1,1) {mustBeNumericOrLogical} = true
    
    % Cost per rated power ($/kW)
    %   From doi:10.1016/j.energy.2016.03.123
    nameValueArgs.solar_cost_P (1,1) {mustBePositive} ...
        = 2800
    
    % Lifetime of generator in years
    %   default from doi:10.1016/j.energy.2016.03.123
    nameValueArgs.solar_lifetime (1,1) {mustBePositive,mustBeInteger} ...
        = 30    
    
    %% Other inputs
    
    % Price of electricity from the grid ($/kWh)
    nameValueArgs.grid_costs (1,1) {mustBePositive} ...
        = 5E5
    
    % Base island to fill in missing parameters
    nameValueArgs.base_islands %TODO make sure this is empty
    
end


%% System properties 

% Device arrays
batts = {};
gens = {};

%% Demand

% Load demand profile data
d_profile = load(nameValueArgs.d_profile_fName, ...
    'data','t');
t = d_profile.t;
d_profile = d_profile.data;

% Scale total load to households
%   Yearly energy consumption (kWh/yr)
d_yr_tot = nameValueArgs.household_annual_kWh * nameValueArgs.households; 
% Hourly demand (kWh/hr)
d_profile = d_profile * d_yr_tot / sum(d_profile);

% Specify time vector
k = (0:length(d_profile)-1)';

% Create demand object
demand = IslandDemand('ISO NE scaled', ...
    k, ...
    d_profile);

fprintf('Total demand: %.0f (kWh/yr)\n', d_yr_tot)
fprintf('Peak demand: %.0f (kW)\n', max(d_profile))

%% LIB
if nameValueArgs.install_LIB
    
    % Construct battery
    batts{end+1} = IslandBatteryLIB('LIB', ...
        nameValueArgs.LIB_cost_E, ...
        nameValueArgs.LIB_cost_P, ...
        nameValueArgs.LIB_cycle_life, ...
        nameValueArgs.LIB_max_years_life, ...
        k);
    
end

%% Flow battery
if nameValueArgs.install_flow

    % Construct battery
    batts{end+1} = IslandBatteryFlow('flow', ...
        nameValueArgs.flow_cost_E, ...
        nameValueArgs.flow_cost_P, ...
        nameValueArgs.flow_cycle_life, ...
        nameValueArgs.flow_max_years_life, ...
        k);
    
end
%% Generator TIDAL
if nameValueArgs.install_tidal

    % Generation profile
    %   Multipy short and long time-scale sine waves
    %   long time-scale: 360 hour wavelength
    %   short time-scale: 6.2 hour wavelength
    %   from 'Model numbers for Mike.docx'
    %TODO add argument to load custom profile
    tidal_P_profile = (sin(k/6.2*2*pi)+1)/2 ... short time-scale
        .* (sin(k/360*2*pi)+1)/2; % long time-scale

    % Construct generator
    gens{end+1} = IslandGenRenewable('tidal', ...
        nameValueArgs.tidal_cost_P, ...
        nameValueArgs.tidal_lifetime, ...
        k, ...
        tidal_P_profile);
    
end
%% Generator SOLAR
if nameValueArgs.install_solar

    % Generation profile
    pvwattshourly = import_pvwatts_hourly("data/pvwatts_hourly.csv", ...
        [19, 19+8760-1]);
    % Convert for Watts to kW
    solar_P_profile = pvwattshourly.ACSystemOutputW/1000;

    % Construct generator
    solar_gen = IslandGenRenewable('solar', ...
        nameValueArgs.solar_cost_P, ...
        nameValueArgs.solar_lifetime, ...
        k, ...
        solar_P_profile);
    gens{end+1} = solar_gen;
    
end
%% Island system

sys = IslandSys(name, t, ...
    gens, ... Generators
    batts, ... Batteries
    {demand}, ... Demand
    nameValueArgs.grid_costs); % Costs

end

