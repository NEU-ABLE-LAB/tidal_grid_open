function [data,t] = process_iso_csv(filenames)
%PROCESS_ISO_CSV Imports hourly load data from ISO csv

%% Input processing

% Read all files in data folder if nonspecified
if ~exist('filenames','var')
    dir_listing = dir('data/');
    csv_listing = dir_listing( cellfun( @(x)( ~isempty( regexp( x,  ...
            'OI_darthrmwh_iso_4005_\d+_\d+\.csv', 'once') ) ),...
        {dir_listing.name} ) );
    filenames = arrayfun( @(x)([x.folder '/' x.name]), ...
        csv_listing, 'UniformOutput',false);
end

% If one filename provide, package in cell array
if ~iscell(filenames) && (ischar(filenames) || isstring(filenames))
    filenames = {filenames};
end

%% Variable prep 
t = [];
data = [];
    
%% Process each file

n_filenames = length(filenames);

for filename_n = 1:n_filenames
    
    filename = filenames{filename_n};
    disp(filename)
    
    % Read CSV
    raw_data = read_iso_csv(filename);

    % Get number of lines
    num_lines = regexp(raw_data.Date{end},'(\d+) lines','tokens');
    num_lines = str2double(num_lines{1}{1});

    % Extract real time hourly demand
    raw_MWH1 = raw_data.MWH1(1:end-1);

    % Validate
    assert(num_lines == length(raw_MWH1), ...
        'Lines read did not match lines specified in file');
    
    % Concatenate data
    data = [data; raw_MWH1];
    
    % Get time vector
    raw_t = arrayfun( @(x,y)(datetime( ...
            [x{1} ' ' num2str(y-1) ':00:00'])), ...
        raw_data.Date(1:end-1), raw_data.Hourending(1:end-1));
    
    % Validate time concatenation
    if ~isempty(t)
        assert( t(end) + hours(1) == raw_t(1), ...
            'End of previous time does not match with start of this time');
    end
    
    % Concatenate time
    t = [t; raw_t];
    
end


end

