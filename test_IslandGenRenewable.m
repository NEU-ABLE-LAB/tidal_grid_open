% Test script for the IslandGenRenewable class

% Fixed paramters
cost_p = 1000; % Cost per rated kW
lifetime = 15; % Lifetime in years
t = (0:24*7)'; % Time horizon
P_profile = 1+sin(t/t(end)*2*pi*7); % Daily cycle

% Construct generator
gen = IslandGenRenewable('sine', cost_p, lifetime, t, P_profile);

% Set rated power
gen.rated_power = 10;

disp(gen)