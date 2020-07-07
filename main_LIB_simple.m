%MAIN_LIB_SIMPLE Simulate a simple island
%   Size a single LIB and generator to meet demand using a simple charge
%   law of charge when supply>demand, and discharge otherwise.

%% Parameters
% Generator
i=0;% iterator value
stage=100000000;% difference value at various stages
while 1
    gen_rated_power = i; % kW

%% Make island

    sys = make_island_aspirational('Simple LIB','households',449);

%% Size simple LIB system
%   Have the LIB supply any deficit, and size the generator to reduce LCOE

    cost_fun(sys, gen_rated_power);

    if (sys.batts{1}.charge(1) - sys.batts{1}.charge(end) <= stage)% if the difference between start and end charge is less then the current stage...
        if (stage == 1)% if on the lowest stage...
            break% ...leave the loop
        end
        i=i-stage;% ...remove 1 previous stage
        stage = stage/10;% ...reduce the stage on level
    end
    i=i+stage;% increase i by stage
end
[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
sys.plot(sprintf('LCOE: %.1f %s/kWh', LCOE*100,  char(0162)))

function cost = cost_fun(sys, gen_rated_power)
    sys.gens{1}.rated_power = gen_rated_power;
    deficit = sys.demand - sys.supply;
    deficit = deficit(1:end-1);
    sys.opt('x',[gen_rated_power; -deficit; 0*deficit])
    cost = sys.LCOE();
end



