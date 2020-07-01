%MAIN_LIB_SIMPLE Simulate a simple island
%   Size a single LIB and generator to meet demand using a simple charge
%   law of charge when supply>demand, and discharge otherwise.

%% Parameters
%Jonathan rules, kriss stinks!
% Generator
gen_rated_power = (10^5)*1.9; % kW

%% Make island

sys = make_island_aspirational('Simple LIB');

%% Size simple LIB system
%   Have the LIB supply any deficit, and size the generator to reduce LCOE

cost_fun(sys, gen_rated_power)

[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
sys.plot(sprintf('LCOE: %.1f %s/kWh', LCOE*100,  char(0162)))

function cost = cost_fun(sys, gen_rated_power)
    sys.gens{1}.rated_power = gen_rated_power;
    deficit = sys.demand - sys.supply;
    deficit = deficit(1:end-1);
    sys.opt('x',[gen_rated_power; -deficit; 0*deficit])
    cost = sys.LCOE();
end



