%MAIN_BOTH_SIMPLE Simulate a simple island
%   Size a single LIB and a single flow battery and generator to meet
%   demand using a simple charge law of charge when supply>demand, and
%   discharge otherwise.

%% Parameters
% Generator
sys = make_island_aspirational('global optimized tidal/solar & LIB/flow','grid_costs',5);
load data/gen_rated_power;

%% Pattern search options
options = optimoptions('patternsearch','Display','iter',...
       'MeshTolerance',1e-20, 'ScaleMesh', false,...
       'PlotFcn',{@psplotbestf,@psplotfuncount},...
       'UseCompletePoll',true,'ConstraintTolerance',0.1,...
       'OutputFcn',@stopfn,'StepTolerance',1e-6);

   
   
ObjectiveFunction = @cost_fun;
nvars = 2;
lb = [1,0];
ub = [8760,100];
x0 = [863,96];
[x,fval] = patternsearch(@(x) cost_fun(sys, ...
    gen_rated_power(floor(x(2)+1)),x(1),x(2)),x0,[],[],[],[],lb,ub);
    
cost_fun(sys,gen_rated_power(floor(x(2)+1)),x(1),x(2));
[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
sys.plot(sprintf('LCOE: %.1f %s/kWh', LCOE*100,  char(0162)));