classdef IslandBatteryFlow < IslandBattery
    %ISLANDBATTERYLIB Lithium-ion Battery object
    %   A subclass of the IslandBattery with methods specific to LIBs
    
    methods
        function obj = IslandBatteryFlow(name, cost_E, cost_P, ...
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
                calc_cycles_used_switch(obj) / obj.CYCLE_LIFE );
        end
        
        function update_design(obj)
            %UPDATE_DESIGN Update battery design based on charge rate
            % Based on the default method from IslandBattery, but with a
            % custom power cost calculation.

            % Validate input size
            assert( length(obj.charge_rate) == obj.NUM_STEPS-1, ...
                'charge_rate same number of elements as TIME');
            
            % Calculate charge trajectory by integrating charge rate
            tmp_charge = [0; cumsum(obj.charge_rate) ...
                .* diff(obj.TIME)];
            obj.charge = tmp_charge - min(tmp_charge); % Ensure nonnegative charge
            
            % Battery energy capacity
            obj.capacity_energy = max(obj.charge);
                                    
            % Calculate state of charge
            obj.SOC = obj.charge / obj.capacity_energy;
            
            % Update battery power capacity
            obj.capacity_power = max(abs(obj.charge_rate(2:end)));
            
            % Update battery energy capacity cost
            obj.cost_energy = obj.COST_E * obj.capacity_energy;
            
            % Update battery rated power cost
            if isnumeric(obj.COST_P)
                
                % Summative power cost calculation
                obj.cost_power = obj.COST_P * obj.capacity_power;
                
            elseif isa(obj.COST_P, 'function_handle')
                
                % Funcational power cost calculation
                obj.cost_power = obj.COST_P(obj) * obj.capacity_power;
                
            else
                error('Unknown object type of COST_P');
            end
            
            % Update battery cost due to deficit at end of year
            if obj.charge(end) >= obj.charge(1)
                obj.cost_error = 0;
            else
                obj.cost_error = obj.COST_FINAL_CHARGE_ERROR * ...
                    (obj.charge(1) - obj.charge(end));
            end
            
            % Calculate cycles used
            obj.calc_cycles_used();
            
        end
        
    end
end

