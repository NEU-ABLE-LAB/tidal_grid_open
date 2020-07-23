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
