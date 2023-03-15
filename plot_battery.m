function plot_battery(battery, fig_title)
%PLOT_BATTERY Plots battery charge rate, charge, and SOC

figure('windowstyle','docked')

subplot(2,1,1)
stairs(battery.TIME(1:end-1), battery.charge_rate)
title('Charge Rate')
xlim([0 battery.TIME(end)])
xticks(0:6:battery.TIME(end))

subplot(2,1,2)

yyaxis left
plot(battery.TIME, battery.charge)
ylabel('Charge')
ylim([0 max(battery.charge)])

yyaxis right
plot(battery.TIME, battery.SOC, '--');
ylabel('SOC')

title('Charge & SOC')
xlim([0 battery.TIME(end)])
xticks(0:6:battery.TIME(end))

sgtitle(fig_title)

end

