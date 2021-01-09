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
info.XDim = [3.25;3.25;3.25;3.25;3.25;3.25;3.25;3.25];
info.YDim = [3.25;3.25;3.25;3.25;3.25;3.25;3.25;3.25];

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
   
    % Save png with minimal white space   
    exportgraphics(a,strcat(folderPath,'/Finalized/',figName,'.png'),'Resolution',300)
    
    % Save pdf with minimal white space
    exportgraphics(a,strcat(folderPath,'/Finalized/',figName,'.pdf'),'Resolution',300)
   
    % Close figure
    clf
end

