% Test script for the IslandBatteryFlow class

cost_E = 600; % ($/kWh) Battery energy capacity cost
cost_P = 100; % ($/kW) Battery power capacity cost
cycle_life = 8; % (cycles) battery cycle life

t = (0:24*7)'; % One day

% Construct battery
bat = IslandBatteryFlow('flow', cost_E, cost_P, cycle_life, t);

%% Charge battery with a discharge-charge one-period square wave
bat.charge_rate = sin(t(1:end-1)/t(end-1)*2*pi);
plot_battery(bat, 'discharge-charge one-period square wave')

fprintf('Cycles used: %0.2f\n', ...
    bat.cycle_life_used * bat.CYCLE_LIFE)

%% Charge battery with a discharge-charge 4-period sine wave
bat.charge_rate = sin(t(1:end-1)/t(end-1)*2*pi*4);
plot_battery(bat, 'discharge-charge 4-period square wave')

fprintf('Cycles used: %0.2f\n', ...
    bat.cycle_life_used * bat.CYCLE_LIFE)
fprintf('Percent life used: %0.2f %%\n', ...
    bat.cycle_life_used * 100)

%% Charge battery with a discharge-charge multiple sine wave
bat.charge_rate = sin(t(1:end-1)/t(end-1)*2*pi) + ...
    0.5*sin(t(1:end-1)/t(end-1)*2*pi*4);
plot_battery(bat, 'discharge-charge 4-period square wave')

fprintf('Cycles used: %0.2f\n', ...
    bat.cycle_life_used * bat.CYCLE_LIFE)
fprintf('Percent life used: %0.2f %%\n', ...
    bat.cycle_life_used * 100)

%% Charge battery with a discharge-charge multiple sine wave
bat.charge_rate = sin(t(1:end-1)/t(end-1)*2*pi) + ...
    2*sin(t(1:end-1)/t(end-1)*2*pi*4);
plot_battery(bat, 'discharge-charge 4-period square wave')

fprintf('Cycles used: %0.2f\n', ...
    bat.cycle_life_used * bat.CYCLE_LIFE)
fprintf('Percent life used: %0.2f %%\n', ...
    bat.cycle_life_used * 100)