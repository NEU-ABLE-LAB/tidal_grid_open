%Test script to confirm battieries can be combined

t = (0:24*7)'; % 7 days

%% LIB
LIB_cost_E = 600; % ($/kWh) Battery energy capacity cost
LIB_cost_P = 100; % ($/kW) Battery power capacity cost
LIB_cycle_life = 8; % (cycles) battery cycle life

% Construct battery
bat_LIB = IslandBatteryLIB('LIB', LIB_cost_E, LIB_cost_P, LIB_cycle_life, t);

%% Flow
flow_cost_E = 600; % ($/kWh) Battery energy capacity cost
flow_cost_P = 100; % ($/kW) Battery power capacity cost
flow_cycle_life = 8; % (cycles) battery cycle life

t = (0:24*7)'; % One day

% Construct battery
bat_flow = IslandBatteryFlow('flow', flow_cost_E, flow_cost_P, flow_cycle_life, t);
