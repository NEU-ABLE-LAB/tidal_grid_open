classdef IslandPart < handle
    %ISLANDPART A part of an islanded power system
    %   This is the super class of all islanded power system parts, such as
    %   batteries, generators, and demand
    
    % Optimization problem properties
    properties (Access = protected)
        
        opt_prop % Optimization problem
        
    end
    
    methods
        
        function varargout = opt(obj, varargin)
            %OPT Set the optimization properties for a part
            %   Set the optimization properties for a islanded power system
            %   part, such as a battery or generator.
            %
            %   `set_part_opt(part,prob_struct)` sets the paramters of the
            %   optimization with the problem defined by the structure
            %   `prob_struct`.
            %
            %   `set_part_opt(name,value)` sets the paramter(s) `name` of
            %   the optimization with `value`.
            %
            %   `value = set_part_opt(name)` returns the value of the
            %   parameter (`name`)
            %
            %   Requires part to have methods `set_x` and `get_x`.

            % Input parsing
            if nargin==1 && nargout==1

                % Return optimization problem
                varargout{1} = obj.opt_prop;
                return

            elseif nargin==2 && isstruct(varargin{1})

                % Structure provided
                prob_struct = varargin{1};

            elseif nargin==2 && ischar(varargin{1})

                % Return value for name
                name = varargin{1};

                if strcmpi(name, 'x')
                    varargout{1} = obj.get_x();
                else
                    varargout{1} = obj.opt_prop.(name);
                end

                return

            else

                % Convert {name, value} into structure
                prob_struct = struct(varargin{:});

            end

            % Set x
            if isfield(prob_struct, 'x')
                assert(length(prob_struct.x) == obj.opt_prop.nvars, ...
                    'Input x should have nvars number of elements')
                obj.set_x(prob_struct.x);
                prob_struct = rmfield(prob_struct, 'x');
            end

            % Set field names of structure
            fields = fieldnames(prob_struct);
            for field_n = 1:length(fields)
                obj.opt_prop.(fields{field_n}) = ...
                    prob_struct(fields{field_n});
                %TODO do size checking of constraints
            end

            % Return optimization problem if requested
            if nargout>0
                varargout{1} = obj.opt_prop;
            end

        end
        
    end
        
    methods (Access = protected)
        
        function set_x(~,~)
            %SET_X Set the optimization paramter x
            warning('This method must be overriden by the subclass');
        end
        
        function x = get_x(~)
            %GET_X Get the optimization paramter x
            warning('This method must be overriden by the subclass');
        end
        
    end
end

