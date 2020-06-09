% Test script for the IslandBattery class

cost_E = 600; % ($/kWh) Battery energy capacity cost
cost_P = 100; % ($/kW) Battery power capacity cost
cycle_life = 12000; % (cycles) battery cycle life

t = (0:24)'; % One day

% Construct battery
bat = IslandBattery('battery', cost_E, cost_P, cycle_life, t);

% Suppress known warnings
warning('off', 'MATLAB:ISLANDBATTERY:NO_CALC_CYCLES');

%% Charge battery with a charge-discharge one-period square wave
charge_rate = zeros(length(t)-1,1);
charge_rate(1:12) = 1;
charge_rate(13:24) = -1;
bat.charge_rate = charge_rate;
plot_battery(bat, 'charge-discharge one-period step wave')

%% Charge battery with a discharge-charge one-period square wave
charge_rate = zeros(length(t)-1,1);
charge_rate(1:12) = -1;
charge_rate(13:24) = 1;
bat.charge_rate = charge_rate;
plot_battery(bat, 'discharge-charge one-period step wave')

%% Charge battery with discharge-charge one-period 25% DC wave
try
    charge_rate = zeros(length(t)-1,1);
    charge_rate((1:3)) = -1;
    charge_rate(3+(1:18)) = 1;
    charge_rate(3+18+(1:3)) = -1;
    bat.charge_rate = charge_rate;
    plot_battery(bat, 'discharge-charge one-period 25DC square wave')
catch ME
    if ~(strcmp(ME.identifier,'MATLAB:ISLANDBATTERY:FINAL_CHARGE_ERROR'))
        rethrow(ME)
    end
    disp('PASSED: test MATLAB:ISLANDBATTERY:FINAL_CHARGE_ERROR')
end

%% Charge battery with a discharge-charge one-period 25% DC wave
    charge_rate = zeros(length(t)-1,1);
    charge_rate((1:3)) = -2/6;
    charge_rate(3+(1:18)) = 2/18;
    charge_rate(3+18+(1:3)) = -2/6;
    bat.charge_rate = charge_rate;
    plot_battery(bat, 'discharge-charge one-period 25DC square wave')

% Unsuppress known warnings
warning('on', 'MATLAB:ISLANDBATTERY:NO_CALC_CYCLES');