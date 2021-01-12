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
info.XDim = [3.25;3.25;3.25;3.25;3.25;3.25;3.25;6.5];
info.YDim = [3.25;3.25;3.25;3.25;3.25;3.25;3.25;6.5];

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
    drawnow
            
    % Resize image based on specified dimensions
    Pos = [1,1,info.XDim(iFile),info.YDim(iFile)];
    set(a, 'Position', Pos);
        
    drawnow
    
    %if iFile == 1;
    %else
%     if iFile == 2;
%         title('Solar + Tidal + LIB')
%         xlabel('Tidal Rated Power (kW)')
%         ylabel('Solar Rated Power (kW)')
%         t = text(50,600,'$1506/MWh');
%         t.Color = 'red';
%         caxis([0 10*1.0e+04])
%         a.Children(2).Children(3).LineColor = 'none';
%         sub = text(0,0,'(a)','Units','inches');
%         sub.Position = [-.25,2.75,0]; 
%     elseif iFile == 3;
%         title('Solar + Tidal + VRFP')
%         xlabel('Tidal Rated Power (kW)')
%         ylabel('Solar Rated Power (kW)')
%         t = text(20,1100,'$1914/MWh');
%         t.Color = 'red';
%         caxis([0 10*1.0e+04])
%         a.Children(2).Children(3).LineColor = 'none';
%         sub = text(0,0,'(b)','Units','inches');
%         sub.Position = [-.25,2.75,0]; 
%     elseif iFile == 4;
%         title('Solar + LIB + VRFP')
%         ylabel('Controller Span (hr)')
%         xlabel('Solar Rated Power (kW)')
%         t = text(100,10,'$2511/MWh');
%         t.Color = 'red';
%         caxis([0 10*1.0e+04])
%         a.Children(2).Children(3).LineColor = 'none';
%         sub = text(0,0,'(c)','Units','inches');
%         sub.Position = [-.25,2.75,0]; 
%     elseif iFile == 5;
%         title('Tidal + LIB + VRFP')
%         ylabel('Controller Span (hr)')
%         xlabel('Tidal Rated Power (kW)')
%         t = text(70,80,'$1285/MWh');
%         t.Color = 'red';
%         caxis([0 10*1.0e+04])
%         a.Children(2).Children(3).LineColor = 'none';
%         sub = text(0,0,'(d)','Units','inches');
%         sub.Position = [-.25,2.75,0]; 
%     else
        if iFile == 6
                hAx = findobj('type', 'axes');
                for iAx = 1:length(hAx)
                   if iAx == 2
                    aNew = figure;
                    hNew = copyobj(hAx(iAx), aNew);
                    aNew.Units = 'inches';
                    Pos = [1,1,info.XDim(iFile),info.YDim(iFile)];
                    set(aNew, 'Position', Pos);
                   end
                end
                title('pie')
                lgd = legend;
                lgd.NumColumns = 3;
                lgd.String=["Tidal: $82/MWh","Solar: $4/MWh","LIB:Energy: $20/MWh","LIB:Power: $8/MWh","LIB:error: $0/MWh","VRFP:Energy: $1066/MWh","VRFP:Power: $6/MWh","VRFP:error: $0/MWh","Grid: $0/MWh"];
                aNew.Children(3).Units = 'inches';
                aNew.Children(3).Position = [(info.XDim(iFile)-info.XDim(iFile)*.75)/2,info.YDim(iFile)/4,info.XDim(iFile),info.XDim(iFile)];
        
        %     elseif iFile == 7;
        %     else
    %elseif iFile == 8
        
    else
        
    end

    % Save png with minimal white space
    exportgraphics(a,strcat(folderPath,'/Finalized/',figName,'.png'),'Resolution',300)
    
    % Save pdf with minimal white space
    exportgraphics(a,strcat(folderPath,'/Finalized/',figName,'.pdf'),'Resolution',300)
    
end
%%
pieData = [10 20 30 40 50];     % Size of pie slices 
pieHandle = pie(pieData);       % Get vector of handles to graphics objects
pieAxis = get(pieHandle(1), 'Parent');  
pieAxisPosition = get(pieAxis, 'Position');
newRadius = 0.50;   % Change the radius of the pie chart
deltaXpos = 0.2;    % Move axis position left or right
deltaYpos = 0.2;    % Move axis position up or down

