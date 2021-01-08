classdef IslandBatteryLIB < IslandBattery
    %ISLANDBATTERYLIB Lithium-ion Battery object
    %   A subclass of the IslandBattery with methods specific to LIBs
    
    methods
        function obj = IslandBatteryLIB(name, cost_E, cost_P, ...
                cycle_life, max_years_life, t)
            %ISLANDBATTERYLIB Construct a LIB object
            
            % Call superclass constructor
            obj = obj@IslandBattery(name, cost_E, cost_P, ...
                cycle_life, max_years_life, t);
        end
    end
    
    methods (Access = protected)
        
        function calc_cycles_used(obj)
            % Calculate the cycles used 
                        
            obj.cycle_life_used = max( 1 / obj.MAX_YEARS_LIFE, ...
                calc_cycles_used_discharge_sum(obj) / obj.CYCLE_LIFE );
        end
        
    end
end

