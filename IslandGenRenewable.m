classdef IslandGenRenewable < IslandPart
    %ISLANDGENRENEWABLE Renewable generator object
    %   A single generator on an islanded power system. 
    
    % Generator model parameters
    properties (SetAccess = immutable)
        
        % Device name
        NAME
        
        % Rated power capacity CAPEX ($/kW)
        COST_P {mustBeNonnegative}
        
        % Lifetime (years)
        LIFETIME {mustBePositive}
        
        % Time horizon vector (hrs)
        TIME {mustBeNonnegative}
        
        % Power profile of mean kW produced each timestep per kW of rated
        % capacity
        P_PROFILE {mustBeNonnegative}
        
        % (COMPUTED) Number of steps in time horizon
        NUM_STEPS {mustBePositive}
        
        % Maximum rated power (kW)
        %   (default) 1GW
        MAX_RATED_POWER = 1E6;
        
    end
    
    % Design optimization parameters
    properties 
        
        % Rated capacity (kW)
        rated_power {mustBeNonnegative}
        
    end
    
    % Computed design paramters
    properties (SetAccess = protected)
        
        % CAPEX
        cost_power % Generator rated power CAPEX cost
        
        P_generated % Mean power generated each timestep
        
    end
    
    methods
        function obj = IslandGenRenewable(name, cost_P, lifetime, t, P_profile)
            %ISLANDGENRENEWABLE Construct an renewable generator
            %   Construct a renewable generator with CAPEX rated power
            %   costs per kW `cost_P`, `lifetime` in years, a power profile
            %   `P_profile` over a time horizon `t`
            
            obj.NAME = name;
            obj.COST_P = cost_P;
            obj.LIFETIME = lifetime;
            obj.TIME = t;
            obj.P_PROFILE = P_profile;
            
            obj.NUM_STEPS = length(obj.TIME);
            
            % Initialize rated_power
            obj.rated_power = 0;
            
            % Initialize the optimization problem with the charge_rate as
            % the dependent variable. 
            obj.opt_prop = struct( ...
                'nvars', 1, ...
                'lb', 0, ...
                'ub', obj.MAX_RATED_POWER );
            
        end
        
        function set.rated_power(obj, rated_power)
            %RATED_POWER Set rated power
            
            % Set rated power
            obj.rated_power = rated_power;
            
            % Update computed design parameters
            obj.update_design()
            
        end
    end
    
    methods (Access = protected)
       
        function update_design(obj)
            %UPDATE_DESIGN Update computed design paramters
           
            % Generator rated power CAPEX cost 
            obj.cost_power = obj.COST_P * obj.rated_power;
            
            % Mean power generated each timestep
            obj.P_generated = obj.P_PROFILE * obj.rated_power;
            
        end
        
        function set_x(obj, x)
            %SET_X Set optimization paramter x
            obj.rated_power = x;
        end
        
        function get_x(obj)
            %GET_X Get optimization parameter x
            x(:) = obj.rated_power;
        end
        
    end
end

