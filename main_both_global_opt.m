%MAIN_BOTH_SIMPLE Simulate a simple island
%   Size a single LIB and a single flow battery and generator to meet
%   demand using a simple charge law of charge when supply>demand, and
%   discharge otherwise.

%% Parameters

% Battery balance
%   Percent of power that goes to the LIB battery

% Generator
iter=0;% iterator value
stage=1000000;% difference value at various stages
lag = 1;
while 1
    gen_rated_power = iter; % kW

%% Make island
    sys = make_island_aspirational('simple flow','grid_costs',5);

%% Size simple LIB system
%   Have the LIB supply any deficit, and size the generator to reduce LCOE

    cost_fun(sys, gen_rated_power,lag,0);

    if (sys.batts{1,2}.charge(1) - sys.batts{1,2}.charge(end) <= stage)% if the difference between start and end charge is less then the current stage...
        if (stage == 1)% if on the lowest stage...
            break% ...leave the loop
        end
        iter=iter-stage;% ...remove 1 previous stage
        stage = stage/10;% ...reduce the stage on level
    end
    iter=iter+stage;% increase iter by stage
end

options = optimoptions(@ga,'FunctionTolerance',1e-18);
%options.InitialPopulationRange = [0 0; 8760 100];
options.InitialPopulationMatrix = [0,100];


ObjectiveFunction = @cost_fun;
nvars = 2;
x0 = [23,0];
lb = [1,0];
ub = [8760,100];

%[x,fval] = ga(@(x) cost_fun(sys,gen_rated_power,x(1),x(2)),nvars,[],[],[],[],lb,ub);
[x,fval] = patternsearch(@(x) cost_fun(sys,gen_rated_power,x(1),x(2)),x0,[],[],[],[],lb,ub);

cost_fun(sys,gen_rated_power,x(1),x(2));
[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(false);
sys.plot(sprintf('LCOE: %.1f %s/kWh', LCOE*100,  char(0162)));


%% calcChargeError
function chargeError = calcChargeError(sys, gen_rated_power, lag)

    cost_fun(sys, gen_rated_power,lag);

    chargeError = sqrt(sum(cellfun(@(x)(x.charge(1) - x.charge(end)), ...
        sys.batts(2) ).^2));
    
end

%% cost_fun
function cost = cost_fun(sys, gen_rated_power,lag,splt)

    % Assign the generated rated power 
    %   Which updates the power generated profiles
    sys.gens{1}.rated_power = ((100-splt)/100)*gen_rated_power;
    sys.gens{2}.rated_power = (splt/100)*gen_rated_power;
    
    % Calculate the deficit at each hour, assuming no battery
    deficit = sys.demand - sys.supply;
    deficit = deficit(1:end-1);
   
    % Smart flow battery charge and discharge rule that minimizes the
    % number of times the battery switches from charging to dischargin
    charge_flow = smooth(-deficit, lag);
    %%
    
    % Have the LIB pick up the slack of when the flow battery wasn't able
    % to charge or discharge to meet over supply or over demand    
    charge_lib = -(sys.demand(1:end-1) + charge_flow - sys.supply(1:end-1));


   %% 
    
    % Assign the independent variables to the model
    %   gen.rated_power - scalar rated power of generator
    %   bat(%LIB%).charge_rate  - charge rate of LIB at each hour
    %   bat(%flow%).charge_rate - charge rate of flow batt at each hour
    sys.opt('x',[((100-splt)/100)*gen_rated_power; (splt/100)*gen_rated_power; charge_lib; charge_flow; 0*charge_flow])
    
    % Calculate the LCOE
    cost = sys.LCOE();
    
end



