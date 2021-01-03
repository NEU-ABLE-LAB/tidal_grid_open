function summary_table = summary2table(summaries)

%% All the output rows

rowNamesFuncs = { ...
    'title'                 @(x)(getFieldSafe(x,'title'))
    'E_delivered'           @(x)(getFieldSafe(x,'total_energy_delivered'))
    'P_peak'                @(x)(getFieldSafe(x,'peak_power_delivered'))
    'CAPEX'                 @(x)(getFieldSafe(x,'total_cost'))
    'LCOE'                  @(x)(getFieldSafe(x,'lcoe', 'total'))
    'LCOE_tidal_cost'       @(x)(getFieldSafe(x,'lcoe', 'tidal', 'cost'))
    'LCOE_tidal_pct'        @(x)(getFieldSafe(x,'lcoe', 'tidal', 'percent'))
    'LCOE_solar_cost'       @(x)(getFieldSafe(x,'lcoe', 'solar', 'cost'))
    'LCOE_solar_pct'        @(x)(getFieldSafe(x,'lcoe', 'solar', 'percent'))
    'LCOE_grid_cost'        @(x)(getFieldSafe(x,'lcoe', 'grid', 'cost'))
    'LCOE_grid_pct'         @(x)(getFieldSafe(x,'lcoe', 'grid', 'percent'))
    'LCOE_LIB_cost'         @(x)(getFieldSafe(x,'lcoe', 'LIB_Energy', 'cost') + getFieldSafe(x,'lcoe', 'LIB_Power', 'cost') +getFieldSafe(x,'lcoe', 'LIB_error', 'cost'))
    'LCOE_LIB_pct'          @(x)(getFieldSafe(x,'lcoe', 'LIB_Energy', 'percent') + getFieldSafe(x,'lcoe', 'LIB_Power', 'percent') +getFieldSafe(x,'lcoe', 'LIB_error', 'percent'))
    'LCOE_flow_cost'        @(x)(getFieldSafe(x,'lcoe', 'flow_Energy', 'cost') + getFieldSafe(x,'lcoe', 'flow_Power', 'cost') +getFieldSafe(x,'lcoe', 'flow_error', 'cost'))
    'LCOE_flow_pct'         @(x)(getFieldSafe(x,'lcoe', 'flow_Energy', 'percent') + getFieldSafe(x,'lcoe', 'flow_Power', 'percent') +getFieldSafe(x,'lcoe', 'flow_error', 'percent'))
    'controller'            @(x)(getFieldSafe(x,'batteries','controller'))
    'bat_cost_total_LIB'    @(x)(getFieldSafe(x,'batteries','LIB', 'energy_storage_cost') + getFieldSafe(x,'batteries','LIB', 'rated_power_cost'))
    'bat_cost_total_flow'   @(x)(getFieldSafe(x,'batteries','flow','energy_storage_cost') + getFieldSafe(x,'batteries','flow','rated_power_cost'))
    'bat_cost_E_LIB'        @(x)(getFieldSafe(x,'batteries','LIB', 'energy_storage_cost'))
    'bat_cost_E_flow'       @(x)(getFieldSafe(x,'batteries','flow','energy_storage_cost'))
    'bat_cost_P_LIB'        @(x)(getFieldSafe(x,'batteries','LIB', 'rated_power_cost'))
    'bat_cost_P_flow'       @(x)(getFieldSafe(x,'batteries','flow','rated_power_cost'))
    'bat_cap_E_LIB'         @(x)(getFieldSafe(x,'batteries','LIB', 'energy_storage_capacity'))
    'bat_cap_E_flow'        @(x)(getFieldSafe(x,'batteries','flow','energy_storage_capacity'))
    'bat_rated_P_LIB'       @(x)(getFieldSafe(x,'batteries','LIB', 'rated_power'))
    'bat_rated_P_flow'      @(x)(getFieldSafe(x,'batteries','flow','rated_power'))
    'bat_cost_cap_LIB'      @(x)(getFieldSafe(x,'batteries','LIB', 'cost_per_energy_stored'))
    'bat_cost_cap_flow'     @(x)(getFieldSafe(x,'batteries','flow','cost_per_energy_stored'))
    'bat_cost_rated_LIB'    @(x)(getFieldSafe(x,'batteries','LIB', 'cost_per_rated_power'))
    'bat_cost_rated_flow'   @(x)(getFieldSafe(x,'batteries','flow','cost_per_rated_power'))
    'bat_max_cycles_LIB'    @(x)(getFieldSafe(x,'batteries','LIB', 'life_cycles'))
    'bat_max_cycles_flow'   @(x)(getFieldSafe(x,'batteries','flow','life_cycles'))
    'bat_life_LIB'          @(x)(getFieldSafe(x,'batteries','LIB', 'life_realized_years'))
    'bat_life_flow'         @(x)(getFieldSafe(x,'batteries','flow','life_realized_years'))
    'bat_E_P_LIB'           @(x)(getFieldSafe(x,'batteries','LIB', 'E_P_ratio'))
    'bat_E_P_flow'          @(x)(getFieldSafe(x,'batteries','flow','E_P_ratio'))
    'gen_cost_total_solar'  @(x)(getFieldSafe(x,'generators','solar','cost'))
    'gen_cost_total_tidal'  @(x)(getFieldSafe(x,'generators','tidal','cost'))
    'gen_rated_power_solar' @(x)(getFieldSafe(x,'generators','solar','rated_power'))
    'gen_rated_power_tidal' @(x)(getFieldSafe(x,'generators','tidal','rated_power'))
    'gen_power_cost_solar'  @(x)(getFieldSafe(x,'generators','solar','cost_per_power'))
    'gen_power_cost_tidal'  @(x)(getFieldSafe(x,'generators','tidal','cost_per_power'))
    'gen_life_solar'        @(x)(getFieldSafe(x,'generators','solar','life'))
    'gen_life_tidal'        @(x)(getFieldSafe(x,'generators','tidal','life'))
    'gen_CF_solar'          @(x)(getFieldSafe(x,'generators','solar','capacity_factor'))
    'gen_CF_tidal'          @(x)(getFieldSafe(x,'generators','tidal','capacity_factor'))
};

summary_table = cellfun(...
    @(y)(cellfun(@(x)x(y),...
        rowNamesFuncs(:,2),...
        'UniformOutput',false)),...
    summaries,...
    'UniformOutput',false...
);
summary_table = [summary_table{:}];
summary_table = [rowNamesFuncs(:,1) summary_table];


function value = getFieldSafe(varargin)
% getFieldSafe Field of structure array. Returns empty array if nonexistent
% See also getfield

try
    
    value = getfield(varargin{:});
    
catch ME
    if (strcmp(ME.identifier,'MATLAB:nonExistentField'))
        value = [];
        return
    end
    rethrow(ME)
end


































