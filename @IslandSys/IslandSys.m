classdef IslandSys < IslandPart
    %ISLANDSYS An islanded power system object
       
    properties (SetAccess = immutable)

        % Island name
        NAME
        
        % Time horizon vector (hrs)
        TIME {mustBeNonnegative}
        
        % The time vector in datetime format
        DATETIME
        
        % Grid costs ($/kWh)
        %   Used only for calculating LCOE with deficit
        GRID_COSTS
        
        % (COMPUTED) Number of steps in time horizon
        NUM_STEPS {mustBePositive}
        
        % (COMPUTED) Number of generators
        N_GENS
        
        % (COMPUTED) Number of batteries
        N_BATTS
        
        % (COMPUTED) Number of demand sources
        N_DEMANDS
        
        % (COMPUTED) Number of parts (gens, batts, & demands)
        N_PARTS
        
    end
    
    properties (SetAccess = private)
        
        % Cell array of generators
        gens %TODO-validate {mustBeArrayFromClass(gens, 'IslandGenRenewable')}
        
        % Cell array of batteries
        batts %TODO-validate {mustBeArrayFromClass(batts, 'IslandBattery')}
        
        % Cell array of demands
        demands %TODO-validate {mustBeArrayFromClass(demands, 'IslandDemand')}
        
    end
        
    properties (Dependent)
        
        % All the system parts in the order of `gens`, `batts`, `demands`
        parts
        
        % Return total demand profile
        demand
        
        % Return total generation supply
        supply
        
        % Net charge rate from all batteries
        net_charge_rate
        
        % Curtailed power
        curtailed
        
    end
    
    properties
        
        % Battery controller model
        %TODO make this a IslandPart instead of split between
        %`cost_fun_design` and `IslandSys.LCOE`
        battery_filter_span
        
    end
    
    methods
        function obj = IslandSys(name, t, gens, batts, demands, grid_costs)
            %ISLAND_SYS Construct an islanded power system
            %   Construct an islanded power system with a cell array of
            %   generators `gens` which can store energy in the cell array
            %   of batteries `batts` to meet the cell array of `demands`.
            
            %TODO Input type checking
            obj.NAME = name;
            obj.GRID_COSTS = grid_costs;
            
            % Add generators
            obj.gens = gens;
            obj.N_GENS = length(gens);
            
            % Add batteries
            obj.batts = batts;
            obj.N_BATTS = length(batts);
            
            % Add demand sources
            obj.demands = demands;
            obj.N_DEMANDS = length(demands);
            
            % Total number of parts
            obj.N_PARTS = length(obj.parts);
            
            % Validate for consistient sampling
            obj.DATETIME = t;
            obj.TIME = obj.demands{:}.TIME;
            assert( all( cellfun( @(part)( isequal( ...
                    part.TIME, obj.TIME) ), ...
                    [obj.gens, obj.batts, obj.demands] ) ), ...
                'MATLAB:ISLANDSYS:SAMPLING', ...
                'All components must be sampled with the same time vector')           
            
            % Initialize the optimization problem with the charge_rate as
            % the dependent variable.
            
            % Total number of optimization variables
            nvars_parts = cellfun(@(x)(x.opt('nvars')), obj.parts);
            nvars = sum(nvars_parts);
            
            % Extract optimization constraints
            % TODO add constraints besides upper and lower bounds. 
            lb = -inf*ones(nvars,1);
            ub = inf*ones(nvars,1);
            for part_n = 1:length(obj.parts)
                part = obj.parts{part_n};
                
                % Lower bound
                if isfield(part.opt, 'lb')
                    lb( sum(nvars_parts(1:part_n-1)) + ...
                            (1:nvars_parts(part_n)) ) = ...
                        part.opt.lb(:);
                end
                
                % Upper bound
                if isfield(part.opt, 'ub')
                    ub( sum(nvars_parts(1:part_n-1)) + ...
                            (1:nvars_parts(part_n)) ) = ...
                        part.opt.ub(:);
                end
                
            end
            
            % Initialize the optimization problem with the charge_rate as
            % the dependent variable. 
            obj.opt_prop = struct( ...
                'nvars', nvars, ...
                'nvars_parts', nvars_parts, ...
                'lb', lb, ...
                'ub', ub );
            
        end
        
        function parts = get.parts(obj)
            %GET.PARTS Gets all the system parts
            %   Returns all the system parts
            
            parts = [obj.gens, obj.batts, obj.demands];
            
        end
        
        function demand = get.demand(obj)
            %GET.DEMAND Returns total demand profile
            demand = sum(cell2mat(cellfun(...
                @(x)(x.LOAD(:)),obj.demands(:)', ...
                'UniformOutput',false)),2);
        end
        
        function supply = get.supply(obj)
            %GET.SUPPLY Returns total supply profile
            supply = sum(cell2mat(cellfun(...
                @(x)(x.P_generated(:)),obj.gens(:)', ...
                'UniformOutput',false)),2);
        end
        
        function net_charge_rate = get.net_charge_rate(obj)
            %GET.NET_CHARGE_RATE Return net charge rate
            net_charge_rate = sum(cell2mat(cellfun(...
                @(x)(x.charge_rate(:)),obj.batts(:)', ...
                'UniformOutput',false)),2);
        end
        
        function curtailed = get.curtailed(obj)
            %GET.CURTAILED Returned curtailed generation
            curtailed = [obj.supply(1:end-1) - ...
                obj.demand(1:end-1) - ...
                obj.net_charge_rate; 0];
        end
        
    end
    
    methods (Access = protected)
        
        function set_x(obj, x)
            %SET_X Set optimization paramter x
            
            % Set the corresponding x for each part
            for part_n = 1:length(obj.parts)
                part = obj.parts{part_n};
                
                if obj.opt.nvars_parts(part_n)
                    part.opt('x', x( ...
                        sum(obj.opt.nvars_parts(1:part_n-1)) + ...
                        (1:obj.opt.nvars_parts(part_n)) ));
                end
            end
            
        end
        
        function x = get_x(obj)
            %GET_X Get optimization parameter x
            x(:) = obj.rated_power;
        end
    end
    
    % Methods in other files
    methods
        
        % Calculate the LCOE of the islanded power system
        [LCOE, LCOE_parts, LCOE_parts_names, summary] = LCOE(obj, doPlot) 
        
        % Plot the system
        sys_plot(obj)
        
    end
end
