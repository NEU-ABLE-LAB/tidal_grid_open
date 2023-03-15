% Confirm before clear and close all
% Clear workspace and figures
if ~isempty(who) && menu( ...
        'Are you sure you want to clear the workspace?', ...
        'yes','no') == 1
    clear
end
if ~isempty(findobj(allchild(0), 'flat', 'Type','figure')) && menu( ...
        'Are you sure you want to close all open figures?', ...
        'yes','no') == 1
    close all
end