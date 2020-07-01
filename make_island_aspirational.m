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
addParameter(p,'households',449)

% LIB inputs
addParameter(p,'LIB_cost_E',220);

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

households = p.Results.households; 
disp(households)

% Scale total demand to 8 GWh
%  Avg US home uses ~914 kWh/mo
%   https://www.eia.gov/tools/faqs/faq.php?id=97&t=3
%  Block island has 449 households
%   https://www.point2homes.com/US/Neighborhood/RI/New-Shoreham/Block-Island-Demographics.html
d_US_household = 914E3;% 914kWh
d_yr_tot = d_US_household * households; % Yearly energy consumption (Wh)
d_profile = d_profile * d_yr_tot / sum(d_profile);

% Specify time vector
k = (0:length(d_profile)-1)';

% Create demand object
demand = IslandDemand('8GWh ISO NE', k, d_profile);


%% LIB

% Battery energy capacity cost ($/kWh)
%   Aspirational estimate from 'Model numbers for Mike.docx'
LIB_cost_E = p.Results.LIB_cost_E; 
disp(LIB_cost_E)

% Battery power capacity cost ($/kW) 
%   Aspirational estimate from 'Model numbers for Mike.docx'
LIB_cost_P = 0; 

% Battery cycle life (cycles) 
%   Aspirational estimate from 'Model numbers for Mike.docx'
LIB_cycle_life = 4000;

% Construct battery
bat_LIB = IslandBatteryLIB('LIB', LIB_cost_E, LIB_cost_P, LIB_cycle_life, k);


%% Flow battery

% Battery energy capacity cost ($/kWh)
%   Aspirational estimate from 'Model numbers for Mike.docx'
flow_cost_E = 30; 

% Battery power capacity cost ($/kW)
%   Aspirational estimate from 'Model numbers for Mike.docx'
flow_cost_P = 1000; 

% battery cycle life (cycles)
%   Aspirational estimate from 'Model numbers for Mike.docx'
flow_cycle_life = 12000; 

% Construct battery
bat_flow = IslandBatteryFlow('flow', flow_cost_E, flow_cost_P, flow_cycle_life, k);


%% Generator

% Cost per rated kW
%   From doi:10.1016/j.energy.2016.03.123
gen_cost_p = 4300; % ($/kW)

% Lifetime in years 
%   From doi:10.1016/j.energy.2016.03.123
gen_lifetime = 20;

% Generation profile
%   Multipy short and long time-scale sine waves
%   long time-scale: 360 hour wavelength
%   short time-scale: 6.2 hour wavelength
%   from 'Model numbers for Mike.docx'
P_profile = (sin(k/6.2*2*pi)+1)/2 ... short time-scale
    .* (sin(k/360*2*pi)+1)/2; % long time-scale

% Construct generator
gen = IslandGenRenewable('tidal', gen_cost_p, gen_lifetime, k, P_profile);


%% Island system

grid_costs = 5; % ($/kWh)

sys = IslandSys(name, t, {gen}, {bat_LIB, bat_flow}, {demand}, ...
    grid_costs);

end

