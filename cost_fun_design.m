%% cost_fun Calculate LCOE of system given design parameters
function cost = cost_fun_design(...
        ... System object
        sys, ... 
        ... Total rated generator power
        gen_rated_power_total, ...
        ... Span (in hours) of the battery moving average filter
        battery_filter_span, ...
        ... [0-100] Percent of rated power of the second generator
        gen_rated_power_split ... 
    )

    % Assign the generated rated power 
    %   Which updates the power generated profiles
    sys.gens{1}.rated_power = ((100-gen_rated_power_split)/100) * ...
        gen_rated_power_total;
    sys.gens{2}.rated_power = (gen_rated_power_split/100) * ...
        gen_rated_power_total;
    
    % Calculate the deficit at each hour, assuming no battery
    deficit = sys.demand - sys.supply;
    deficit = deficit(1:end-1);
   
    % Smart flow battery charge and discharge rule that minimizes the
    % number of times the battery switches from charging to dischargin
    charge_flow = smooth(-deficit, battery_filter_span);
        
    % Have the LIB pick up the slack of when the flow battery wasn't able
    % to charge or discharge to meet over supply or over demand    
    charge_lib = -(sys.demand(1:end-1) + charge_flow - sys.supply(1:end-1));
    
    % Assign the independent variables to the model
    %   sys.gens{1}.rated_power - scalar rated power of first generator
    %   sys.gens{2}.rated_power - scalar rated power of second generator
    %   bat(%LIB%).charge_rate  - charge rate of LIB at each hour
    %   bat(%flow%).charge_rate - charge rate of flow batt at each hour
    sys.opt('x', ...
        [   sys.gens{1}.rated_power; ...
            sys.gens{2}.rated_power; ...
            charge_lib; ...
            charge_flow; ...
        ])
    
    % Calculate the LCOE
    cost = sys.LCOE();
    
end
