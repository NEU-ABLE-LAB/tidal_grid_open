clear
clc
%MAIN_BOTH_global_opt_testbench
%   Compare the accuracy and percision of various global optimization
%   functions for our specific use case

%% Parameters
% Generator
sys = make_island_aspirational('global optimized tidal/solar & LIB/flow','grid_costs',5);
%load data/gen_rated_power;

%% Search options
options = optimoptions('patternsearch','Display','iter',...
    'MeshTolerance',1e-20, 'ScaleMesh', false,...
    'PlotFcn',{@psplotbestf,@psplotfuncount},...
    'UseCompletePoll',true,'ConstraintTolerance',0.1,...
    'OutputFcn',@stopfn,'StepTolerance',1e-9);

testSize = 100
tmp = [];
rownames = {'fminunc';'patternSearch';'genericAlgorithim';'particleSwarm'};
gen_rated_power = {tmp;tmp;tmp;tmp};
lag = {tmp;tmp;tmp;tmp};
splt = {tmp;tmp;tmp;tmp};
LCOE = {tmp;tmp;tmp;tmp};
runtime = {tmp;tmp;tmp;tmp};

tb = table(gen_rated_power, lag, splt, LCOE, runtime,'RowNames',rownames);
ObjectiveFunction = @cost_fun;
nvars = 3;
lb = [1,1,1]; %lowest possible value for pattern search
ub = [6,8760/4,95]; %highest possible value for pattern search


parfor itr = 1:testSize
    x0a = randi(round([lb(1),ub(1)])); %generate a random number between 1st fraction of the lb and ub for gen_rated_power
    x0b = randi(round([lb(2),ub(2)])); %Same as above but with the lag value
    x0c = randi(round([lb(3),ub(3)])); %same as above but with the split value
    x0(itr,:) = [x0a,x0b,x0c];
end
parfor itr = 1:testSize
    
    tic;
    [x(itr,:),fval(itr,1)] = fminunc(@(x) cost_fun(sys, ...
        10^x(1)...
        ,x(2)...
        ,x(3))...
        ,x0(itr,:));
    rt(itr,1) = toc;
end
tb({'fminunc'},:) = [{x(:,1)},{x(:,2)},{x(:,3)},{fval},{rt}];

parfor itr = 1:testSize
    tic;
    [x(itr,:),fval(itr,1)] = patternsearch(@(x) cost_fun(sys, ...
        10^x(1)...
        ,x(2)...
        ,x(3))...
        ,x0(itr,:),[],[],[],[],lb,ub);
    rt(itr,1) = toc;
end
tb({'patternSearch'},:) = [{x(:,1)},{x(:,2)},{x(:,3)},{fval},{rt}];

parfor itr = 1:testSize    
    tic;
    [x(itr,:),fval(itr)] = ga(@(x) cost_fun(sys,10^x(1),x(2),x(3))...
    ,nvars...        
    ,[],[],[],[]...
    ,lb,ub);
    rt(itr) = toc;
end
tb({'genericAlgorithim'},:) = [{x(:,1)},{x(:,2)},{x(:,3)},{fval},{rt}]; 

parfor itr = 1:testSize
    tic;
    [x(itr,:),fval(itr)] = particleswarm(@(x) cost_fun(sys, ...
    10^x(1)...
    ,x(2)...
    ,x(3))...
    ,nvars...
    ,lb...
    ,ub);
    rt(itr) = toc;
end
tb({'particleSwarm'},:) = [{x(:,1)},{x(:,2)},{x(:,3)},{fval},{rt}]; 

fmin_LCOE_avg = mean(tb{{'fminunc'},:}{4});
fmin_runtime_avg = mean(tb{{'fminunc'},:}{5});
pattern_LCOE_avg = mean(tb{{'patternSearch'},:}{4});
pattern_runtime_avg = mean(tb{{'patternSearch'},:}{5});
ga_LCOE_avg = mean(tb{{'genericAlgorithim'},:}{4});
ga_runtime_avg = mean(tb{{'genericAlgorithim'},:}{5});
particle_LCOE_avg = mean(tb{{'particleSwarm'},:}{4});
particle_runtime_avg = mean(tb{{'particleSwarm'},:}{5});

X = categorical({'fminunc','pattern','ga','particle'});
X = reordercats(X,{'fminunc','pattern','ga','particle'});
figure()
hold on
bar(X,[fmin_LCOE_avg pattern_LCOE_avg ga_LCOE_avg particle_LCOE_avg])
title('Average LCOE')
hold off
figure()
hold on
title('Average Runtime')
bar(X,[fmin_runtime_avg pattern_runtime_avg ga_runtime_avg particle_runtime_avg])
hold off

% fval_tmp = fval;
% for i = 1:1
%     [min_fval(i,1),min_index(i,1)] = min(fval_tmp);
%     fval_tmp(min_index(i,1))=[];
%     clear fval_temp;
% end
% 
% 
% 
% cost_fun(sys,10^x(min_index(1),1),x(min_index(1),2),x(min_index(1),3));
% [LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
% sys.plot(sprintf('LCOE: %.1f %s/kWh', LCOE*100,  char(0162)));