xrng = [10^-1, 10^2];
yrng = [5*10^1 10^4];

% Duration E/P (hours)
EPs = logspace(log10(xrng(1)),log10(xrng(2)),20); 
% Cost ($kWh)
% a = 2E3;
% b = 10E-2;
% c = 200;
% cost = a*exp(b./(EPs))+(c-a);

clf
% Read base image to fit data to
img = imread('Brushett2020Fig5a.png');

image(xrng,yrng,img)
ax1 = gca;
%get rid of pixel ticklabels
set(ax1,'XTick', [], 'YTick', [])
%color=none to make the image visible
ax2 = axes('Position',get(ax1,'Position'),...
    'Color','none',...
    'XScale', 'log', ...
    'YScale', 'log');
ylim(yrng)
xlim(xrng)
xlabel('Duration E/P (hrs)')
ylabel('Cost ($/kWh)')

% Ask the user to select 6 points
[xPts, yPts] = ginput(6);

% Fit a curve to the data
fitOptions = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',[0 0 0],...
    'Upper',[Inf 1 Inf],...
    'Startpoint',[2E3 10E-2 200]);
aFittype = fittype('a*exp(b/x)+(c-a)',...
    'independent','x', ...
    'coefficients',{'a','b','c'}, ...
    'options',fitOptions);
[fitobject,gof] = fit(xPts,yPts,aFittype);

% Compute cost for fitted curve
cost = fitobject.a*exp(fitobject.b ./ EPs)+(fitobject.c - fitobject.a);

% Plot fitted curve
line(EPs,cost,...
    'Parent',ax2, ...
    'Color','#A2142F', ...
    'LineStyle','none', ...
    'LineWidth',1, ...
    'Marker','o')

%% RESULT
save('fitCostCuveResult', 'fitobject')