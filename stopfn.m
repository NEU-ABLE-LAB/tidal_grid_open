function [stop,options,optchanged] = stopfn(optimvalues,options,flag)
stop=false;
optchanged=false;
if optimvalues.fval <= 1e-9
stop=true;
end
end