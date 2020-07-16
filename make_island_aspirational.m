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
addParameter(p,'LIB_cost_E',220);% ($/kWh)
addParameter(p,'LIB_cost_P',0); % ($/kW)
addParameter(p,'LIB_cycle_life',4000); % (total charges)

% flow inputs
addParameter(p,'flow_cost_E',30); % ($/kWh)
addParameter(p,'flow_cost_P',1000); % ($/kW)
addParameter(p,'flow_cycle_life',12000); % (charge and discharge switches)

% SC inputs
addParameter(p,'SC_cost_E',2400); % ($/kWh) https://tinyurl.com/yavcuy3p 
addParameter(p,'SC_cost_P',300); % ($/kW)
addParameter(p,'SC_cycle_life',20000);% https://tinyurl.com/ybol85ml

% tidal inputs
addParameter(p,'tidal_cost_P',4300); % ($/kWh)
addParameter(p,'tidal_lifetime',20);

% solar inputs
addParameter(p,'solar_cost_P',2800);
addParameter(p,'solar_lifetime',30)

% island inputs
addParameter(p,'grid_costs',5);

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


%% Flow battery

% Super capacitor energy capacity cost ($/kWh)
SC_cost_E = p.Results.SC_cost_E;% ($/kWh)

% Super capacitor power capacity cost ($/kW)
SC_cost_P = p.Results.SC_cost_P;% ($/kW)

% Seuper capacitor cycle life (cycles)
SC_cycle_life = p.Results.SC_cycle_life;% cycles

% Construct battery
bat_SC = IslandBatterySC('SC', SC_cost_E, SC_cost_P, SC_cycle_life, k);

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
load('data/DC_solar_hourly.mat');
x=DC_solar_hourly/1000;
P_solar_profile = x;

% Construct generator
solar_gen = IslandGenRenewable('tidal', solar_cost_P, solar_lifetime, k, P_solar_profile);



%% Island system

grid_costs = p.Results.grid_costs; % ($/kWh)

sys = IslandSys(name, t, {tidal_gen, solar_gen}, {bat_LIB, bat_flow, bat_SC}, {demand}, ...
    grid_costs);

end

