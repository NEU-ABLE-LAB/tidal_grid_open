classdef IslandBatteryLIB < IslandBattery
    %ISLANDBATTERYLIB Lithium-ion Battery object
    %   A subclass of the IslandBattery with methods specific to LIBs
    
    methods
        function obj = IslandBatteryLIB(name, cost_E, cost_P, life, t)
            %ISLANDBATTERYLIB Construct a LIB object
            
            % Call superclass constructor
            obj = obj@IslandBattery(name, cost_E, cost_P, life, t);
        end
    end
    
    methods (Access = protected)
        
        function calc_cycles_used(obj)
            % Calculate the cycles used 
                        
            obj.cycle_life_used = calc_cycles_used_discharge_sum(obj) ...
                / obj.CYCLE_LIFE;
        end
        
    end
end

