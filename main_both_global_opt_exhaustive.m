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
       'OutputFcn',@stopfn,'StepTolerance',1e-6);

   
 
%x = NaN(100,3);
%fval = NaN(100,1);
threads = 100;

for i = 1:100
    ObjectiveFunction = @cost_fun;
    nvars = 2;
    lb = [1,1,1];
    ub = [1000000,8760/4,100];
        parfor ii = 1:threads
            x0a = randi(round([lb(1)*ii/threads,ub(1)*ii/threads]));
            x0b = randi(round([lb(2)*ii/threads,ub(2)*ii/threads]));
%             x0c = randi(round([lb(3)*ii/threads,ub(3)*ii/threads]));
            x0c = randi(round([0,100]));

            x0 = [x0a,x0b,x0c]
            
            [x(ii,:),fval(ii,:)] = patternsearch(@(x) cost_fun(sys, ...
                 x(1)...
                ,x(2)...
                ,x(3))...
                ,x0,[],[],[],[],lb,ub);
        end
%        x((i*10)+1:(i+1)*10,:) = tmp_x;
%         lb = min(x(:,1));
%         ub = max(x(:,:));
        
        [~,idx(i)]=min(fval);
end



fval_tmp = fval;
max(x(:,:))
min(x(:,:))
for i = 1:threads
    [min_fval(i,1),min_index(i,1)] = min(fval_tmp);
    fval_tmp(min_index(i,1))=[];
    clear fval_temp;
end

cost_fun(sys,x(min_index(1),1),x(min_index(1),2),x(min_index(1),3));
[LCOE, LCOE_parts, LCOE_parts_names] = sys.LCOE(true);
sys.plot(sprintf('LCOE: %.1f %s/kWh', LCOE*100,  char(0162)));