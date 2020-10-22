clear
clc
%MAIN_BOTH_SIMPLE Simulate a simple island
%   Size a single LIB and a single flow battery and generator to meet
%   demand using a simple charge law of charge when supply>demand, and
%   discharge otherwise.

%% Parameters
% Generator
sys = make_island_aspirational('global optimized tidal/solar & LIB/flow','grid_costs',5);
%load data/gen_rated_power;

%% Pattern search options
options = optimoptions('patternsearch','Display','iter',...
    'MeshTolerance',1e-20, 'ScaleMesh', false,...
    'PlotFcn',{@psplotbestf,@psplotfuncount},...
    'UseCompletePoll',true,'ConstraintTolerance',0.1,...
    'OutputFcn',@stopfn,'StepTolerance',1e-9);

ObjectiveFunction = @cost_fun;
lb = [1,1,1]; %lowest possible value for pattern search
ub = [6,8760/4,95]; %highest possible value for pattern search

x0a = randi(round([lb(1),ub(1)])); %generate a random number between 1st fraction of the lb and ub for gen_rated_power
x0b = randi(round([lb(2),ub(2)])); %Same as above but with the lag value
x0c = randi(round([lb(3),ub(3)])); %same as above but with the split value
x0 = [x0a,x0b,x0c];

[x,fval] = fminunc(@(x) cost_fun(sys, ...
    10^x(1)...
    ,x(2)...
    ,x(3))...
    ,x0);

fval_tmp = fval;
for i = 1:1
    [min_fval(i,1),min_index(i,1)] = min(fval_tmp);
    fval_tmp(min_index(i,1))=[];
    clear fval_temp;
end

cost_fun(sys,10^x(min_index(1),1),x(min_index(1),2),x(min_index(1),3));
[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
sys.plot(sprintf('LCOE: %.1f %s/kWh', LCOE*100,  char(0162)));