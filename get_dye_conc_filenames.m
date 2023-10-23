function [filepaths] = get_dye_conc_filenames(concentrations)
    % get_dye_conc_filenames  Returns a list of image filenames
    %
    % Create a list of file names for a slection of dye concentrations, in mg/L.
    % With a concentration > 0 (e.g. that there is dye) three file paths are
    % returned, corresponding to three images for the same dye concentration. When
    % there is no dye, only one file path will be returned.
    %
    % The name of the directories/files used are those as decided by the LaVision
    % camera hardware.
    %
    % Syntax: filepaths = get_dye_conc_filenames(concentrations)
    %
    % Inputs:
    %   concentrations
    %
    % Outputs:
    %   filepaths
    %
    % Example:
    %   -
    %
    % See also: -
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    % Other files required:  none
    %


    filepaths = {};

    for i = 1:length(concentrations)
        filepaths{end + 1} = strcat('C-Calibration_C=', num2str(concentrations(i), '%.2f')); % list.append doesn't exist

        % Bit hacky, but for background concentration images we don't have multiple images
        if concentrations(i) > 0
            filepaths{end + 1} = strcat('C-Calibration_C=', num2str(concentrations(i), '%.2f'), '_01');
            filepaths{end + 1} = strcat('C-Calibration_C=', num2str(concentrations(i), '%.2f'), '_02');
        end

    end

end
