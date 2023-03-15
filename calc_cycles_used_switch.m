function cycles_used = calc_cycles_used_switch(battery)
%CALC_CYCLES_USED_SWITCH Calculate cycles used as number of switches
%   Count one cycle every time the charge_rate changes sign.
%
%   INPUT: battery (IslandBattery)

% Calculate the total cycles used
cycles_used = sum( diff( battery.charge_rate > 0 ) > 0 );

end

