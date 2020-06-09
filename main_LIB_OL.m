%MAIN_LIB_SIMPLE Optimize a simple island
%   Size a single LIB and generator to meet demand using a simple charge
%   law of charge when supply>demand, and discharge otherwise.

%% Make island

sys = make_island_aspirational('Simple LIB');

%% Size simple LIB system
%   Have the LIB supply any deficit, and size the generator to reduce LCOE

% ga_options = optimoptions(@ga, ...
%     'Display','iter', ...
%     'PlotFcn', {@gaplotdistance,@gaplotrange});

fmincon_options = optimoptions(@fmincon, ...
    'Display','iter', ...
    'PlotFcn', {@optimplotfval,@optimplotstepsize});
    

[gen_rated_power,fval,exitflag,output,population,scores] = fmincon( ...
    @(x)(cost_fun(sys,x)), ...
    [1E3; zeros(sys.batts{1}.opt.nvars, 1)], ... x0
    [],[],[],[], ... A, b, Aeq, beq
    [sys.gens{1}.opt.lb; sys.batts{1}.opt.lb], ... lb
    [sys.gens{1}.opt.ub; sys.batts{1}.opt.ub], ... ub
    [], ... nonlcon
    fmincon_options);

[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
sys.plot(sprintf('LCOE: %.1f %s/kW', LCOE*100,  char(0162)))


function cost = cost_fun(sys, x)
    sys.opt('x',[x(:); zeros(sys.batts{2}.opt.nvars,1)])
    cost = sys.LCOE();
end



