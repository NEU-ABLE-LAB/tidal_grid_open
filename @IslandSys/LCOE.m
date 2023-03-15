function [LCOE, LCOE_parts, LCOE_parts_names, summary] = LCOE(obj, do_plot)
%LCOE Calculate levelized cost of energy of the system
%


%% Simple LCOE calculation
%TODO allow for non-hourly sampling

n_years = ((obj.TIME(end) - obj.TIME(1)) / (365*24));

% inverse of system demand (yr / kWh)
demand_inv = ( n_years / sum(obj.demand) );

% Generator costs ($ / yr)
gens_cost = cellfun(@(x)(x.cost_power) / ...
    (x.LIFETIME / n_years), obj.gens);
    
% Battery costs ($ / yr)
batts_cost_energy = cellfun(@(x)(x.cost_energy) * ...
    x.cycle_life_used , obj.batts);
batts_cost_power = cellfun(@(x)(x.cost_power) * ...
    x.cycle_life_used, obj.batts);
batts_cost_error = cellfun(@(x)x.cost_error, obj.batts);

% Costs from the grid ($)
grid_cost = -sum(obj.curtailed(obj.curtailed<0)) / ...
     n_years * obj.GRID_COSTS;

% Calculate LCOE
LCOE_parts = [ (demand_inv)*[...
        (gens_cost) ...
        (batts_cost_energy) ...
        (batts_cost_power) ...
        (batts_cost_error) ] ...
    grid_cost ];
LCOE_parts_names = [cellfun(@(x)sprintf('%s',x.NAME), obj.gens, ...
        'UniformOutput',false) ...
    cellfun(@(x)sprintf('%s:Energy',x.NAME), obj.batts, ...
        'UniformOutput',false) ...
    cellfun(@(x)sprintf('%s:Power',x.NAME), obj.batts, ...
        'UniformOutput',false) ...
    cellfun(@(x)sprintf('%s:error',x.NAME), obj.batts, ...
        'UniformOutput',false), ...
    {'grid'}];
LCOE = sum(LCOE_parts);

% Reorder LCOE battery parts so batteries are in order
idx_part2bat = [...
    (1:obj.N_GENS) ...
    (obj.N_GENS + ...
        cell2mat(...
            arrayfun(@(x)(x-1+1:obj.N_BATTS:(obj.N_BATTS*3)), ...
            1:obj.N_BATTS, ...
            'UniformOutput', false)))...
    ((obj.N_GENS + 3*obj.N_BATTS + 1):length(LCOE_parts))...
];
LCOE_parts = LCOE_parts(idx_part2bat);
LCOE_parts_names = LCOE_parts_names(idx_part2bat);

%% Table summary

summary = struct();

% Title
summary.title = sprintf('%s', ...
    obj.NAME ...
);

% Summary
%%%%%%%%
summary.total_energy_delivered = sum(obj.demand)/1E6;
summary.peak_power_delivered = max(abs(diff(obj.demand)));
summary.total_cost = (sum(cellfun(...
        @(x)(x.cost_power + x.cost_energy),obj.batts)) ...
    + sum(cellfun(@(x)(x.cost_power),obj.gens))) / 1E6;

txt = [...
    summary.title '\n' ...
    repmat('=',1,length(summary.title)) '\n' ...
    sprintf('Total energy delivered: %0.0f GWh/yr\n', ...
        summary.total_energy_delivered ) ...
    sprintf('Peak power delivered: %0.0f kW\n', ...
        summary.peak_power_delivered ) ...
    sprintf('Total cost: $%0.0fM\n', ...
         summary.total_cost)...
    '\n' ...
];

% LCOE
%%%%%%

% Total levelized cost of energy ($/MWh)
summary.lcoe.total = sum(LCOE_parts)*1000;
    
txt = [txt ...
    sprintf('%-12s  $%6.1f/MWh\n', ...
        'LCOE: ', ...
         summary.lcoe.total...
    )...
    '=========================\n' ...
];

for k = 1:length(LCOE_parts)
    
    LCOE_part_name = matlab.lang.makeValidName(LCOE_parts_names{k});
    summary.lcoe.(LCOE_part_name) = struct( ...
        'cost', LCOE_parts(k)*1000, ... $/kWh to $/MWh
        'percent', LCOE_parts(k)/sum(LCOE_parts)*100 ... percent of total LCOE
    );
    
    txt = [txt ...
        sprintf('%-12s: $%6.1f/MWh  (%2.0f%s)\n', ...
            LCOE_parts_names{k}, ...
            summary.lcoe.(LCOE_part_name).cost, .... 
            summary.lcoe.(LCOE_part_name).percent, ... 
            '%%' ...
        ) ...
    ];

end

txt = [txt '\n'];

% Batteries
%%%%%%%%%%%
txt = [txt ...
    'BATTERIES\n'...
    '=========\n'...
];

% Battery controller paramter
summary.batteries.controller = obj.battery_filter_span;

txt = [txt ...
    sprintf('Charge controller filter span: %0.0e hours\n\n', ...
        summary.batteries.controller) ...
];

for battN = 1:obj.N_BATTS

    % Storage capacity (MWh)
    summary.batteries.(obj.batts{battN}.NAME).energy_storage_capacity = ...
        obj.batts{battN}.capacity_energy/1E3;
    % Cost ($M) of the rated storage capacity
    summary.batteries.(obj.batts{battN}.NAME).energy_storage_cost = ...
        obj.batts{battN}.cost_energy/1E6;
    % Cost per unit of energy storage ($/kWh)
    summary.batteries.(obj.batts{battN}.NAME).cost_per_energy_stored = ...
        obj.batts{battN}.COST_E;
    % Rated power (MW)
    summary.batteries.(obj.batts{battN}.NAME).rated_power = ...
        obj.batts{battN}.capacity_power/1E3;
    % Cost ($M) of rated power
    summary.batteries.(obj.batts{battN}.NAME).rated_power_cost = ...
        obj.batts{battN}.cost_power/1E6;
    % Cost per unit of rated power ($/kW)
    if isnumeric(obj.batts{battN}.COST_P)
        summary.batteries.(obj.batts{battN}.NAME).cost_per_rated_power = ...
            obj.batts{battN}.COST_P;
    elseif isa(obj.batts{battN}.COST_P, 'function_handle')
        summary.batteries.(obj.batts{battN}.NAME).cost_per_rated_power = ...
            obj.batts{battN}.COST_P(obj.batts{battN});        
    end
    % Max cycle life (cycles)
    summary.batteries.(obj.batts{battN}.NAME).life_cycles = ...
        obj.batts{battN}.CYCLE_LIFE;
    % Realized life span (years)
    summary.batteries.(obj.batts{battN}.NAME).life_realized_years = ...
        1/obj.batts{battN}.cycle_life_used;   
    % Energy to power ratio
    summary.batteries.(obj.batts{battN}.NAME).E_P_ratio = ...
        summary.batteries.(obj.batts{battN}.NAME).energy_storage_capacity ...
        / summary.batteries.(obj.batts{battN}.NAME).rated_power;

    txt = [txt ...
        obj.batts{battN}.NAME '\n'...
        repmat('-', 1, length(obj.batts{battN}.NAME)) '\n'...
        sprintf('Energy storage capacity: %0.0f MWh ($%0.1fM @ $%0.0f/kWh)\n', ...
            summary.batteries.(obj.batts{battN}.NAME).energy_storage_capacity,...
            summary.batteries.(obj.batts{battN}.NAME).energy_storage_cost, ...
            summary.batteries.(obj.batts{battN}.NAME).cost_per_energy_stored)...
        sprintf('Rated power: %0.1f MW ($%0.1fM @ $%0.0f/kW)\n', ...
            summary.batteries.(obj.batts{battN}.NAME).rated_power, ...
            summary.batteries.(obj.batts{battN}.NAME).rated_power_cost, ...
            summary.batteries.(obj.batts{battN}.NAME).cost_per_rated_power) ...
        sprintf('Life span: %0.1f years\n', ...
            summary.batteries.(obj.batts{battN}.NAME).life_realized_years) ...
        sprintf('E/P ratio: %0.1f\n', ...
            summary.batteries.(obj.batts{battN}.NAME).E_P_ratio) ...
        '\n' ...
    ];

end    

% Generators
%%%%%%%%%%%%
txt = [txt ...
    'GENERATORS\n'...
    '==========\n'...
    '\n'...
];
for genN = 1:obj.N_GENS

    % Rated power (MW)
    summary.generators.(obj.gens{genN}.NAME).rated_power = ...
        obj.gens{genN}.rated_power/1E3;
    % Cost ($M)
    summary.generators.(obj.gens{genN}.NAME).cost = ...
        obj.gens{genN}.cost_power/1E6;
    % Cost per rated power ($/MW)
    summary.generators.(obj.gens{genN}.NAME).cost_per_power = ...
        obj.gens{genN}.COST_P/1E3;
    % Energy delivered (GWh/yr)
    summary.generators.(obj.gens{genN}.NAME).energy_delivered = ...
        sum(obj.gens{genN}.P_generated)/1E6;
    % Capacity factor (%)
    summary.generators.(obj.gens{genN}.NAME).capacity_factor = ...
        100 * sum(obj.gens{genN}.P_generated) ...
            / (obj.gens{genN}.rated_power * 8760);
    % Life space (yr)
    summary.generators.(obj.gens{genN}.NAME).life = ...
        obj.gens{genN}.LIFETIME;

    txt = [txt ...
        obj.gens{genN}.NAME '\n'...
        repmat('-', 1, length(obj.gens{genN}.NAME)) '\n'...
        ...
        sprintf('Rated power: %0.1f MW ($%0.1fM @ $%0.1f/MW)\n', ...
            summary.generators.(obj.gens{genN}.NAME).rated_power, ...
            summary.generators.(obj.gens{genN}.NAME).cost, ...
            summary.generators.(obj.gens{genN}.NAME).cost_per_power)...
        sprintf('Energy delivered: %0.1f GWh/yr\n', ...
            summary.generators.(obj.gens{genN}.NAME).energy_delivered)...
        sprintf('Capacity factor: %0.0f%s \n', ...
            summary.generators.(obj.gens{genN}.NAME).capacity_factor, ...
            '%%')...
        sprintf('Life space: %0.0f years\n', ...
            summary.generators.(obj.gens{genN}.NAME).life)...
        '\n'...
    ];
end

% Save summary text
summary.txt = txt;

%% Plot results
if exist('do_plot','var') && do_plot
    figure('windowstyle','docked')
    
    % Plot a pie chart of LCOE breakdown
    subplot(1,2,1);
    
    % Labels of slices
    pie_labels = arrayfun( @(x,y)sprintf('%s: $%.0f/MWh',...
            y{1}, x ), ...
        LCOE_parts*1000, ... $/kWh to $/MWh
        LCOE_parts_names, ...
        'UniformOutput',false);
    h_p = pie( 100*LCOE_parts, ... % Multiply by 100 to get full pie chart
        ... Apply labels with each parts LCOE
        pie_labels);
    
    % Add title and legend
    title(summary.title);
    h_lgd = legend('Location','southoutside');
    h_lgd.NumColumns = 3;
    
    % Remove labels of small slices
    h_a = h_p.Parent;
    children = h_a.Children;
    labels = flipud(children(arrayfun(...
        @(x)(isa(x,'matlab.graphics.primitive.Text')),children)));
    labels_to_remove = labels(LCOE_parts*1000 < 1);
    for k = 1:length(labels_to_remove)
        labels_to_remove(k).String = '';
    end
      
    % Show summary text on plot    
    subplot(1,2,2);
    text(0,0.5,sprintf(txt),...
        'FontName','FixedWidth',...
        'FontSize',8, ...
        'Interpreter','none')
    axis off
        
end


end
