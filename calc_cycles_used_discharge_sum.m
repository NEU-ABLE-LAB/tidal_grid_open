function cycles_used = calc_cycles_used_discharge_sum(battery)
%CALC_CYCLES_USED_DISCHARGE_SUM Calculate cycles used as sum of discharges
%   For each time the battery discharges, add up the change in percent
%   charged. The battery reaches end of life when this sum reaches
%   battery.LIFE*100.
%
%   INPUT: battery (IslandBattery)

% Calculate the change in SOC at each step
dSOC = diff(battery.SOC);

% Consider only the discharges
dSOC_discharges = dSOC(dSOC<0);

% Calculate the total cycles discharged
cycles_used = -sum(dSOC_discharges);

end

