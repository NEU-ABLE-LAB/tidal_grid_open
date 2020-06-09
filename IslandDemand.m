classdef IslandDemand < IslandPart
    %ISLANDDEMAND Power demand object
    %   Detailed explanation goes here
    
    properties (SetAccess = immutable)
        
        % Device name
        NAME
        
        % Time horizon vector (hrs)
        TIME {mustBeNonnegative}
        
        % Mean load at each time step (kW)
        LOAD {mustBeNonnegative}
        
    end
    
    methods
        function obj = IslandDemand(name, t, load)
            %ISLANDDEMAND Construct an demand object
            %   Construct an object that draws mean power of `load` at each
            %   time step in `t`.
            
            obj.NAME = name;
            obj.TIME = t;
            obj.LOAD = load;
            
            % Initialize the optimization problem with the charge_rate as
            % the dependent variable. 
            obj.opt_prop = struct( ...
                'nvars', 0);
            
        end
    end
end

