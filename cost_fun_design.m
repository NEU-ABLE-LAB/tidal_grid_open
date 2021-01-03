%% cost_fun Calculate LCOE of system given design parameters
function [LCOE, LCOE_parts, LCOE_parts_names, summary] = cost_fun_design(...
        ... System object
        sys, ... 
        ... Rated power of each generator 
        gens_rated_power, ...
        ... Span (in hours) of the battery moving average filter
        battery_filter_span ...
    )

    % Assign the generated rated power 
    %   Which updates the power generated profiles
    assert(sys.N_GENS == length(gens_rated_power), ...
        'Number of generators with rated power does not equal number of generators');
    for genN = 1:sys.N_GENS
        sys.gens{genN}.rated_power = gens_rated_power(genN);
    end
    
    % Calculate the deficit at each hour, assuming no battery
    deficit = sys.demand - sys.supply;
    deficit = deficit(1:end-1);
        
    % Initialize battery controller parameter
    % No battery controller needed if there are not two batteries
    sys.battery_filter_span = [];
    
    % Assign battery charging
    if sys.N_BATTS == 1
        
        % Charge the battery with any surplus and discharge the battery to
        % meet any deficit.
        charge_rate = -deficit;
                
    elseif sys.N_BATTS == 2
        
        % Save battery controller parameter
        sys.battery_filter_span = battery_filter_span;
        
        % Smart flow battery charge and discharge rule that minimizes the
        % number of times the battery switches from charging to dischargin
        charge_flow = smooth(-deficit, battery_filter_span);

        % Have the LIB pick up the slack of when the flow battery wasn't
        % able to charge or discharge to meet over supply or over demand
        charge_lib = -(sys.demand(1:end-1) + charge_flow ...
            - sys.supply(1:end-1));
        
        % Identify order of batteries
        battNLIB = cellfun(@(x)(isa(x,'IslandBatteryLIB')), sys.batts);
        assert(sum(battNLIB)==1, 'Exactly one LIB not found');
        battNFlow= cellfun(@(x)(isa(x,'IslandBatteryFlow')), sys.batts);
        assert(sum(battNFlow)==1, 'Exactly one flow battery not found');        
        
        % Assign charge rates to batteries
        charge_rate = zeros(length(deficit), 2);
        charge_rate(:,battNLIB)  = charge_lib;
        charge_rate(:,battNFlow) = charge_flow;
        
    end
    
    % Assign the independent variables to the model
    %   sys.gens{1}.rated_power - scalar rated power of first generator
    %   sys.gens{2}.rated_power - scalar rated power of second generator
    %   bat(%LIB%).charge_rate  - charge rate of LIB at each hour
    %   bat(%flow%).charge_rate - charge rate of flow batt at each hour
    sys.opt('x', ...
        [   ... List of rated power of generators
            cellfun(@(x)(x.rated_power),sys.gens)'; ...
            ... Stacked vectors of battery charge rates
            charge_rate(:) ...
        ])
    
    % Calculate the LCOE
    [LCOE, LCOE_parts, LCOE_parts_names, summary] = sys.LCOE();
    
end
