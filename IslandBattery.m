classdef IslandBattery < IslandPart
    %ISLANDBATTERY Battery object
    %   A single battery object on an islanded power system. This should
    %   not be called as its own class, but as a superclas to a subclass
    %   that has a `calc_cycles_used` method
    
    
    % Battery model parameters
    properties (SetAccess = immutable)
        
        % Device name
        NAME
        
        % Energy capacity CAPEX ($/kWh) 
        COST_E {mustBeNonnegative} 
                
        % Power capacity CAPEX ($/kW)
        COST_P {mustBeNonnegative}
        
        % Battery cycle life
        CYCLE_LIFE
        
        % Time horizon vector (hrs)
        TIME {mustBeNonnegative}
        
        % (COMPUTED) Number of steps in time horizon
        NUM_STEPS {mustBePositive}
        
        % Cost of the battery not being charged the same as it was at the
        % beginning of the simulation ($/kWh)
        COST_FINAL_CHARGE_ERROR = 5;
        
        % Maximum power output of any design (kW)
        %   (default) 1GW
        MAX_POWER = 1E6;
        
    end
    
    
    % Battery design parameters
    properties
        
        % Mean charge rate (kW) at each hour 1:(end-1).
        %
        %   Postive value is charging
        %
        %   Negative value is discharging
        %
        %   Update private battery properties when set
        %
        charge_rate {mustBeFinite} 
        
    end
        
    % Battery computed design parameters
    properties (SetAccess = protected)
        
        % Battery design parameters
        capacity_energy % Battery energy capacity (kWh)
        capacity_power % Battery power capacity (kW)
        
        % Battery costs
        cost_energy % Battery rated energy CAPEX cost
        cost_power % Battery rated power CAPEX cost
        cost_error % Cost for a partially charged battery at end of year
        
        % Battery states and outputs
        charge % Battery charge at the beginning of each step (kWh)
        SOC % Battery state of charge at the beginning of each step (0-1)
                
        cycle_life_used % Percent of total cycle life used
        
    end
        
    
    methods
        function obj = IslandBattery(name, cost_E, cost_P, cycle_life, t)
            %ISLAND_BATTERY Construct a battery
            %   Construct a battery with energy storage cost per kWh
            %   `cost_E` ($/kWh), storage power costs per kW `cost_P`,
            %   cycle life `cycle_life`, used over a time horizon defined
            %   by a vector `t`.
            
            obj.NAME = name;
            obj.COST_E = cost_E;
            obj.COST_P = cost_P;
            obj.CYCLE_LIFE = cycle_life;
            obj.TIME = t(:); % Convert to vertical vector
            
            obj.NUM_STEPS = length(obj.TIME);
            
            % Initialize with zero charge
            obj.charge = zeros(size(obj.TIME));
            
            % Initialize charge rate
            obj.charge_rate = zeros(obj.NUM_STEPS-1, 1);
            
            % Initialize the optimization problem with the charge_rate as
            % the dependent variable. 
            obj.opt_prop = struct( ...
                'nvars', obj.NUM_STEPS-1, ...
                'lb', -obj.MAX_POWER*ones(obj.NUM_STEPS-1,1), ...
                'ub', obj.MAX_POWER*ones(obj.NUM_STEPS-1,1) );
            
        end
        
        function set.charge_rate(obj, charge_rate)
                       
            % Set charge rate with specified value.
            %   Convert to vertical vector
            obj.charge_rate = charge_rate(:);
            
            % Update design
            obj.update_design()
            
        end
        
    end
    
    methods (Access = protected)
        
        function update_design(obj)
            %UPDATE_DESIGN Update battery design based on charge rate

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
            
            % Update battery energy and power costs
            obj.cost_energy = obj.COST_E * obj.capacity_energy;
            obj.cost_power = obj.COST_P * obj.capacity_power;
            if obj.charge(end) >= obj.charge(1)
                obj.cost_error = 0;
            else
                obj.cost_error = obj.COST_FINAL_CHARGE_ERROR * ...
                    (obj.charge(1) - obj.charge(end));
            end
            
            % Calculate cycles used
            obj.calc_cycles_used();
            
        end
        
        function calc_cycles_used(obj) %#ok<MANU>
            warning('MATLAB:ISLANDBATTERY:NO_CALC_CYCLES', ...
                ['This method should be overriden by ' ...
                    'a battery chemistry specific subclass']);
        end
    
        function set_x(obj, x)
            %SET_X Set the optimization paramter x
            obj.charge_rate(:) = x(:);
        end
        
        function x = get_x(obj)
            %GET_X Get the optimization paramter x
            x(:) = obj.charge_rate(:);
        end
        
    end
end

