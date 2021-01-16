% This file retrieves the folder path for the S_Tidal figures.
% The figures are loaded, edited, and saved as the final figures for
% outputs as .fig and .pdf files
% These finalized files must still be edited in illustrator/inkscape.
%% Folder Path
% Ask user for folder path
prompt = 'Copy and paste the "figures" folder path for the S_Tidal project on your device\nExample: C:\\Users....\\figures\n';

% Save user input
folderPath = input(prompt,'s');

% Change folderpath slashes from \ to /
folderPath = strrep(folderPath,'\','/');

% Retrieve .fig file names from folder
info.figNames = strip(erase(string(ls(strcat(folderPath,'/*.fig'))),'.fig'));

% Specify the X and Y Dimensions for each figure in inches
info.XDim = [3.25;3.25;3.25;3.25;3.25;6.5;6.5;6.5];
info.YDim = [3.25;3.25;3.25;3.25;3.25;6.5;3.25;6.5];

%% Finalize Figures
% Iterate through each file
for iFile = 1:length(info.figNames)
    % Retrieve File Name
    figName = info.figNames{iFile};
    
    % Open figure
    a = openfig(strcat(folderPath,'/',figName,'.fig'));
    
    % Open figure in a new window (NOT docked)
    set(a, 'windowstyle','normal')
    
    % Set font size to 8
    set(gca,'FontSize',8)
    
    % Set Units of Figure to inches
    set(a,'Units','inches');
    
    % Drawnow, so you dont have to wait for the figure to render
    drawnow
    
    % Resize figure based on specified dimensions
    Pos = [1,1,info.XDim(iFile),info.YDim(iFile)];
    set(a, 'Position', Pos);
    
    % Drawnow, so you dont have to wait for the figure to render
    drawnow
    
    % This if statement specifies changes to be made for each figure
    if iFile == 1
        % Retrieve an array of the files 'children'
        child = a.Children;
        
        % Remove the image
        delete(child(2))
        
        % Change the linestyle to solid, color to black, and remove markers
        a.Children.Children.LineStyle = '-';
        a.Children.Children.Color = 'b';
        a.Children.Children.Marker = 'none';
        
        % Change FontSize to 8
        a.Children.FontSize = 8;
        a.Children.XLabel.FontSize = 8;
        a.Children.YLabel.FontSize = 8;
        
        a.Children.YLabel.String = "Capital Cost ($/kWh)";
        a.Children.XLabel.String = "E/P, duration (hrs)";
        
    elseif iFile == 2
        % Change the title and axis labels. Make sure the fontsize is 8
        title('Solar + Tidal + LIB','FontSize',8)
        xlabel('Tidal Rated Power (kW)','FontSize',8)
        ylabel('Solar Rated Power (kW)','FontSize',8)
        
        % Add the annotation
        t = text(90,590,'$1506/MWh','FontSize',8);
        t.Color = 'red';
        
        % Reformat the axis limits to be consistent
        max = 10*1.0e+04;
        caxis([0 max])
        
        % Turn off countour lines
        a.Children(2).Children(3).LineColor = 'none';
        
        % Add subfigure label
        sub = text(0,0,'(a)','Units','inches','FontSize',8);
        sub.Position = [-.25,2.75,0];
        
        % Adjust render & countour lines for printing quality
        levels = 0:10000:max;
        a.Children(2).Children(4).LevelList = levels;
        a.Renderer = 'painters';

    elseif iFile == 3
        % Change the title and axis labels. Make sure the fontsize is 8
        title('Solar + Tidal + VRFP','FontSize',8)
        xlabel('Tidal Rated Power (kW)','FontSize',8)
        ylabel('Solar Rated Power (kW)','FontSize',8)
        
        % Add the annotation
        t = text(40,1550,'$1914/MWh','FontSize',8);
        t.Color = 'red';
        
       % Reformat the axis limits to be consistent
        max = 10*1.0e+04;
        caxis([0 max])
        
        % Turn off countour lines
        a.Children(2).Children(3).LineColor = 'none';
        
        % Add subfigure label
        sub = text(0,0,'(b)','Units','inches','FontSize',8);
        sub.Position = [-.25,2.75,0];
        
        % Adjust render & countour lines for printing quality
        levels = 0:10000:max;
        a.Children(2).Children(4).LevelList = levels;
        a.Renderer = 'painters';
    elseif iFile == 4
        % Change the title and axis labels. Make sure the fontsize is 8
        title('Solar + LIB + VRFP','FontSize',8)
        ylabel('Controller Span (hr)','FontSize',8)
        xlabel('Solar Rated Power (kW)','FontSize',8)
        
        % Add the annotation
        t = text(200,15,'$2511/MWh','FontSize',8);
        t.Color = 'red';
        
        % Reformat the axis limits to be consistent
        max = 10*1.0e+04;
        caxis([0 max])
        
        % Turn off countour lines
        a.Children(2).Children(3).LineColor = 'none';
        
        % Add subfigure label
        sub = text(0,0,'(c)','Units','inches','FontSize',8);
        sub.Position = [-.25,2.75,0];
        
        % Adjust render & countour lines for printing quality
        levels = 0:10000:max;
        a.Children(2).Children(4).LevelList = levels;
        a.Renderer = 'painters';
    elseif iFile == 5
        % Change the title and axis labels. Make sure the fontsize is 8
        title('Tidal + LIB + VRFP','FontSize',8)
        ylabel('Controller Span (hr)','FontSize',8)
        xlabel('Tidal Rated Power (kW)','FontSize',8)
        
        % Add the annotation
        t = text(120,65,'$1285/MWh','FontSize',8);
        t.Color = 'red';
        
        % Reformat the axis limits to be consistent
        max = 10*1.0e+04;
        caxis([0 max])
        
        % Turn off countour lines
        a.Children(2).Children(3).LineColor = 'none';
        
        % Add subfigure label
        sub = text(0,0,'(d)','Units','inches','FontSize',8);
        sub.Position = [-.25,2.75,0];
        
        % Adjust render & countour lines for printing quality
        levels = 0:10000:max;
        a.Children(2).Children(4).LevelList = levels;
        a.Renderer = 'painters';
    elseif iFile == 6
        % Find the different Axes
        hAx = findobj('type', 'axes');
        
        % Iterate through each axes
        for iAx = 1:length(hAx)
            % We only want axes 2
            if iAx == 2
                % make a new figure
                aNew = figure;
                
                % Copy axis to new figure
                hNew = copyobj(hAx(iAx), aNew);
                
                % Change units to inches
                aNew.Units = 'inches';
                
                % Resize figure based on specified dimensions
                Pos = [1,1,info.XDim(iFile),info.YDim(iFile)];
                set(aNew, 'Position', Pos);
            end
        end
        
        % Set legend column to 3 and font size to 8
        lgd = legend;
        lgd.NumColumns = 3;
        lgd.FontSize = 8;
        
        % Edit the legend names as specified
        for iString = 1:length(lgd.String)
            if strfind(convertCharsToStrings(lgd.String{iString}),'flow')
                lgd.String{iString}= strrep(lgd.String{iString},'flow','VRFB');
            elseif strfind(convertCharsToStrings(lgd.String{iString}),'t')
                lgd.String{iString} = strrep(convertCharsToStrings(lgd.String{iString}),'t','T');
            elseif strfind(convertCharsToStrings(lgd.String{iString}),'s')
                lgd.String{iString} = strrep(convertCharsToStrings(lgd.String{iString}),'s','S');
            elseif strfind(convertCharsToStrings(lgd.String{iString}),'grid')
                lgd.String{iString}= strrep(convertCharsToStrings(lgd.String{iString}),'grid','Grid');
            end
        end
        
        % Set the units, resize, and position the legend
        lgd.Units = 'inches';
        lgd.Position = [info.XDim(iFile)*.25/2,info.YDim(iFile)/16,info.XDim(iFile)*.75,info.YDim(iFile)/8];
        
        % Set the units and resize the pie chart
        aNew.Children(2).Units = 'inches';
        aNew.Children(2).Position = [0,.25,info.XDim(iFile),info.XDim(iFile)];
        
        % Make new colormap based on colorbrewer 2, qualitative, 9
        hexMap = {'377eb8','ffff33','f781bf','984ea3','ff7f00','4daf4a','e41a1c','a65628','999999'};
        
        % Tidal, Solar, LIB: Energy, LIB: Power, LIB: Error, VRFB: Energy,
        % VRFB Power, VRFB: Error, Grid
        
        myColorMap = zeros(length(hexMap), 3); % Preallocate
        for k = 1 : length(hexMap)
            thisCell = hexMap{k};
            r = hex2dec(thisCell(1:2));
            g = hex2dec(thisCell(3:4));
            b = hex2dec(thisCell(5:6));
            myColorMap(k, :) = [r, g, b];
        end
        myColorMap = myColorMap / 255; % Normalize to range 0-1
        
        % Change the colormap to the new one
        colormap(myColorMap);
        
        % Edit pie chart labels as specified
        hText = findobj(aNew,'Type','text');
        for iText = 1:length(hText);
            hText(iText).FontSize = 8;
            if strfind(convertCharsToStrings(hText(iText).String),'flow')
                hText(iText).String = strrep(convertCharsToStrings(hText(iText).String),'flow','VRFB');
            elseif strfind(convertCharsToStrings(hText(iText).String),'t')
                hText(iText).String = strrep(convertCharsToStrings(hText(iText).String),'t','T');
            elseif strfind(convertCharsToStrings(hText(iText).String),'s')
                hText(iText).String = strrep(convertCharsToStrings(hText(iText).String),'s','S');
            elseif strfind(convertCharsToStrings(hText(iText).String),'grid')
                hText(iText).String = strrep(convertCharsToStrings(hText(iText).String),'grid','Grid');
            end
        end
        
        % Rotate pie chart so the labels fit nicely
        view([60 90])   % this is to rotate the chart
        
        % Align and position each label so they look nice
        for iText = 1:length(hText)
            hText(iText).HorizontalAlignment = 'center';
            hText(iText).VerticalAlignment = 'middle';
            if hText(iText).String == "VRFB:Power: $6/MWh"
                hText(iText).Position = [0.163544730782529,1.27582666001257,0];
            elseif hText(iText).String == "VRFB:Energy: $1066/MWh"
                hText(iText).Position = [0.195132399506151,-1.241900790319001,-1.4e-14];
            elseif hText(iText).String == "LIB:Power: $8/MWh"
                hText(iText).Position = [-0.489722130595738,1.11305452986894,-1.4e-14];
            elseif hText(iText).String == "LIB:Energy: $20/MWh"
                hText(iText).Position = [-0.38639579378541,1.154930250259128,-1.4e-14];
            elseif hText(iText).String == "Solar: $4/MWh"
                hText(iText).Position = [-0.342594998848975,1.101451076050758,-1.4e-14];
            elseif hText(iText).String == "Tidal: $82/MWh";
                hText(iText).Position = [-0.134017514977172,1.182472758772923,-1.4e-14];
            else
            end
        end
        % Save over file a
        a = aNew;
    elseif iFile == 7
        % Remove middle axis
        a.Children.DisplayVariables = {a.Children.DisplayVariables{1},a.Children.DisplayVariables{3}};
        
        % Rename legend Labels as specified
        a.Children.AxesProperties(1).LegendLabels = {'Demand','Tidal','Solar'};
        a.Children.AxesProperties(2).LegendLabels = {'LIB','VRFB'};
        
        % Remove title
        title('')
    elseif iFile == 8
        
        % Change legend font size
        lgd = a.Children(1);
        lgd.FontSize = 8;
        
        % Edit legend labels as specified
        for iString = 1:length(lgd.String)
            if strfind(convertCharsToStrings(lgd.String{iString}),'flow')
                lgd.String{iString}= strrep(lgd.String{iString},'flow','VRFB');
            elseif strfind(convertCharsToStrings(lgd.String{iString}),'t')
                lgd.String{iString} = strrep(convertCharsToStrings(lgd.String{iString}),'t','T');
            elseif strfind(convertCharsToStrings(lgd.String{iString}),'s')
                lgd.String{iString} = strrep(convertCharsToStrings(lgd.String{iString}),'s','S');
            elseif strfind(convertCharsToStrings(lgd.String{iString}),'grid')
                lgd.String{iString}= strrep(convertCharsToStrings(lgd.String{iString}),'grid','Grid');
            end
        end
        
        for iChild = 1:length(a.Children)
            % There are 4 subplots in this figure, for each of them
            if isa(a.Children(iChild),'matlab.graphics.axis.Axes') == 1
                % Set the Y Lim to be uniform
                a.Children(iChild).YLim = [0 2500];
                
                % Change all the fontsizes to 8
                a.Children(iChild).Title.FontSize = 8;
                a.Children(iChild).XLabel.FontSize = 8;
                a.Children(iChild).YLabel.FontSize = 8;
                a.Children(iChild).XAxis.FontSize = 8;
                a.Children(iChild).YAxis.FontSize = 8;
                
                % Set the colormap to the same as before
                a.Children(iChild).ColorOrder = myColorMap;
                
                % Rename titles as specified
                if a.Children(iChild).Title.String == "Tidal Generator Cost"
                    a.Children(iChild).Title.String = "Tidal RES";
                elseif a.Children(iChild).Title.String == "Solar PV Cost"
                    a.Children(iChild).Title.String = "Solar PV RES";
                elseif a.Children(iChild).Title.String == "Flow Battery Cost"
                    a.Children(iChild).Title.String = "VRFB Cost";
                elseif a.Children(iChild).Title.String =="Li-Ion Battery Cost"
                    a.Children(iChild).Title.String = "LIB Cost";
                end
            end
        end
        
        
        % Re-order Legend
        lbl = a.Children(1).String;                         % Retrieve legend labels
        numlbl = length(lbl);                               % Determine number of lables
        order = sort(1:1:numlbl,'descend');                 % Create array of label numbers in descending order
        newlbl = lbl(order);                                % Create new labels in descending order
        legend(findobj(a.Children(2),'Type','area'),newlbl) % Set the legend to follow the new labels
        
    end
    
    % Save png with minimal white space
    exportgraphics(a,strcat(folderPath,'/Finalized/',figName,'.png'),'Resolution',300)
    
    % Save pdf with minimal white space
    exportgraphics(a,strcat(folderPath,'/Finalized/',figName,'.pdf'),'Resolution',300)
    
    % close it!
    close(a)
end