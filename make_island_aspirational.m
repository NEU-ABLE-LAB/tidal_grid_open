function sys = make_island_aspirational(name,varargin)
%MAKE_ISLAND_ASPIRATIONAL Make an aspirational islanded power system

%% Parse inputs
p = inputParser;

% System inputs
addOptional(p,'name','Aspirational',@isstr);

% Demand inputs
addParameter(p,'d_profile_fName',...
    'data/OI_darthrmwh_iso_4005_20190101_20191231',...
    @isstr)
%  Avg US home uses ~10,649 kWh/yr
%   https://www.eia.gov/tools/faqs/faq.php?id=97&t=3
addParameter(p,'household_annual_kWh', 10649)
%  Block island has 429 households
%   https://www.point2homes.com/US/Neighborhood/RI/New-Shoreham/Block-Island-Demographics.html
addParameter(p,'households',429)

% LIB inputs
addParameter(p,'LIB_cost_E',220); % ($/kWh)
addParameter(p,'LIB_cost_P',0);   % ($/kW)
addParameter(p,'LIB_cycle_life',4000); % (total charges)

% flow inputs
addParameter(p,'flow_cost_E',30);   % ($/kWh)
addParameter(p,'flow_cost_P',1000); % ($/kW)
addParameter(p,'flow_cycle_life',12000); % (charge and discharge switches)

% SC inputs
addParameter(p,'SC_cost_E',2400); % ($/kWh) https://tinyurl.com/yavcuy3p 
addParameter(p,'SC_cost_P',300);  % ($/kW)
addParameter(p,'SC_cycle_life',20000);% https://tinyurl.com/ybol85ml

% tidal inputs
addParameter(p,'tidal_cost_P',4300); % ($/kW)
addParameter(p,'tidal_lifetime',20); % (yrs)

% solar inputs
addParameter(p,'solar_cost_P',2800); % ($/kW)
addParameter(p,'solar_lifetime',30)  % (yrs)

% island inputs
addParameter(p,'grid_costs',5); % ($/kWh)

% Parse inputs
parse(p,name,varargin{:})

%% System properties 

% Island name
name = p.Results.name;

%% Demand

% Load demand profile data
d_profile = load(p.Results.d_profile_fName, ...
    'data','t');
t = d_profile.t;
d_profile = d_profile.data;

% Scale total load to households
%   Yearly energy consumption (kWh/yr)
d_yr_tot = p.Results.household_annual_kWh * p.Results.households; 
% Hourly demand (kWh/hr)
d_profile = d_profile * d_yr_tot / sum(d_profile);

% Specify time vector
k = (0:length(d_profile)-1)';

% Create demand object
demand = IslandDemand('ISO NE scaled', k, d_profile);

fprintf('Total demand: %.0f (kWh/yr)\n', d_yr_tot)
fprintf('Peak demand: %.0f (kW)\n', max(d_profile))

%% LIB

% Battery energy capacity cost ($/kWh)
%   Aspirational estimate from 'Model numbers for Mike.docx'
LIB_cost_E = p.Results.LIB_cost_E;% ($/kWh)

% Battery power capacity cost ($/kW) 
%   Aspirational estimate from 'Model numbers for Mike.docx'
LIB_cost_P = p.Results.LIB_cost_P;% ($/kW)

% Battery cycle life (cycles) 
%   Aspirational estimate from 'Model numbers for Mike.docx'
LIB_cycle_life = p.Results.LIB_cycle_life;% cycles

% Construct battery
bat_LIB = IslandBatteryLIB('LIB', LIB_cost_E, LIB_cost_P, LIB_cycle_life, k);


%% Flow battery

% Battery energy capacity cost ($/kWh)
%   Aspirational estimate from 'Model numbers for Mike.docx'
flow_cost_E = p.Results.flow_cost_E;% ($/kWh)

% Battery power capacity cost ($/kW)
%   Aspirational estimate from 'Model numbers for Mike.docx'
flow_cost_P = p.Results.flow_cost_P;% ($/kW)

% battery cycle life (cycles)
%   Aspirational estimate from 'Model numbers for Mike.docx'
flow_cycle_life = p.Results.flow_cycle_life;% cycles

% Construct battery
bat_flow = IslandBatteryFlow('flow', flow_cost_E, flow_cost_P, flow_cycle_life, k);

%% Generator TIDAL

% Cost per rated kW
%   From doi:10.1016/j.energy.2016.03.123
tidal_cost_P = p.Results.tidal_cost_P;% ($/kW)

% Lifetime in years 
%   default from doi:10.1016/j.energy.2016.03.123
tidal_lifetime = p.Results.tidal_lifetime;% (years)

% Generation profile
%   Multipy short and long time-scale sine waves
%   long time-scale: 360 hour wavelength
%   short time-scale: 6.2 hour wavelength
%   from 'Model numbers for Mike.docx'
P_tidal_profile = (sin(k/6.2*2*pi)+1)/2 ... short time-scale
    .* (sin(k/360*2*pi)+1)/2; % long time-scale

% Construct generator
tidal_gen = IslandGenRenewable('tidal', tidal_cost_P, tidal_lifetime, k, P_tidal_profile);

%% Generator SOLAR

% Cost per rated kW
%   From doi:10.1016/j.energy.2016.03.123
solar_cost_P = p.Results.solar_cost_P;% ($/kW)

% Lifetime in years 
%   default from doi:10.1016/j.energy.2016.03.123
solar_lifetime = p.Results.solar_lifetime;% (years)

% Generation profile
DC_solar_hourly = load('data/DC_solar_hourly.mat');
DC_solar_hourly = DC_solar_hourly.DC_solar_hourly;
% Convert for Watts to kW
P_solar_profile = DC_solar_hourly/1000;

% Construct generator
solar_gen = IslandGenRenewable('solar', solar_cost_P, solar_lifetime, k, P_solar_profile);

%% Island system

grid_costs = p.Results.grid_costs; % ($/kWh)

sys = IslandSys(name, t, ...
    {tidal_gen,solar_gen}, ... Generators
    {bat_LIB, bat_flow}, ... Batteries
    {demand}, ... Demand
    grid_costs); % Costs

end

