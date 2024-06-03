function combineCSVs(downsampleRatio)
    if nargin < 1
        downsampleRatio = 100;
    end

    % user prompt to select folder with csvs or select csv files
    selectionType = questdlg('Would you like to select individual files or a folder?', ...
                             'Select Input Type', 'Files', 'Folder', 'Files');
    
    if strcmp(selectionType, 'Files')
        [files, path] = uigetfile('*.csv', 'Select CSV files', 'MultiSelect', 'on');
        if ischar(files)
            files = {files}; %single handeling
        end
    elseif strcmp(selectionType, 'Folder')
        path = uigetdir('Select Folder with CSV files');
        if path == 0
            disp('No folder selected.');
            return;
        end
        files = dir(fullfile(path, '*.csv'));
        files = {files.name};
    else
        disp('No selection made.');
        return;
    end

    % base out file name handeling 
    filenames = cellfun(@(f) fullfile(path, f), files, 'UniformOutput', false);
    fileLengths = cellfun(@length, files);
    [~, idx] = min(fileLengths);
    filename_base = files{idx};

 
    underscores = strfind(filename_base, '_');
    if length(underscores) >= 3
        filename_base = [filename_base(1:underscores(1)-1), ... 
                        filename_base(underscores(1)+1:underscores(2)-1), ...
                        filename_base(underscores(2)+1:underscores(3)-1), ...
                         ' - ', ...
                         filename_base(underscores(3)+1:end)];
    end

    data = cellfun(@(f) readtable(f), filenames, 'UniformOutput', false);

    combinedData = vertcat(data{:});

    sortedData = sortrows(combinedData, 1);

    % UI slider
    f = uifigure('Name', 'Select Downsample Ratio', 'NumberTitle', 'off', ...
                 'Position', [400, 400, 350, 150]);
    lbl = uilabel(f, 'Position', [20, 100, 310, 20], ...
                  'Text', 'Select Downsample Ratio (0 to 100%)');
    valLbl = uilabel(f, 'Position', [160, 80, 40, 20], ...
                     'Text', sprintf('%d%%', round(downsampleRatio)), 'Tag', 'sliderValue');
    sld = uislider(f, 'Position', [20, 60, 310, 20], ...
                   'Limits', [0 100], 'MajorTicks', 0:10:100, ...
                   'Value', downsampleRatio, 'ValueChangedFcn', @sliderCallback);
    btn = uibutton(f, 'Position', [135, 10, 80, 20], ...
                   'Text', 'Confirm', 'ButtonPushedFcn', @confirmCallback);

    uiwait(f);

    % Downsample 
    downsampleRatio = round(downsampleRatio) / 100;
    if downsampleRatio < 1
        numRows = size(sortedData, 1);
        indices = round(linspace(1, numRows, round(numRows * downsampleRatio)));
        sortedData = sortedData(indices, :);
    end

   % Prompt for saving name
saveChoice = questdlg(sprintf('Would you like to save the file with the base filename "%s" or specify a name manually?', filename_base), ...
                      'Save File', 'Use Base Filename', 'Specify Manually', 'Use Base Filename');

    if strcmp(saveChoice, 'Use Base Filename')
        savePath = uigetdir('Select Folder to Save File');
        if savePath == 0
            disp('No folder selected.');
            return;
        end
        saveFile = filename_base;
    elseif strcmp(saveChoice, 'Specify Manually')
        [saveFile, savePath] = uiputfile('*.csv', 'Save combined CSV file as', filename_base);
        if isequal(saveFile, 0)
            disp('No file selected.');
            return;
        end
    else
        disp('No selection made.');
        return;
    end

    % saving 
    writetable(sortedData, fullfile(savePath, saveFile));

    function sliderCallback(src, ~)
        value = round(src.Value);
        valLbl.Text = sprintf('%d%%', value);
    end

    function confirmCallback(~, ~)
        downsampleRatio = str2double(valLbl.Text(1:end-1));
        close(f);
    end
end
