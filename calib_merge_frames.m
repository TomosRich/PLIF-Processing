function calib_merge_frames(directories, concentrations)
    % calib_merge_frames   Merge the max value from multiple images
    %
    % Syntax: merge_frames(concentrations, directories)
    %
    % Inputs:
    %   concentrations
    %   directories
    %
    % Ouputs:
    %   -
    %
    % Example:
    %   -
    %
    % See also: -
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    % Other files required: none
    %

    fsep = filesep;

    for i = 1:length(concentrations)
        concentration_files = get_dye_conc_filenames(concentrations(i));

        % Load first data, in order to get the size of the array
        load([directories.folder_save, fsep, concentration_files{1}, '.mat'], 'dye_calib_frame', 'X', 'Y');
        merged_dye_calib = zeros(size(dye_calib_frame));

        % Across all images for the given concentration, find the largest value for
        % each pixel of the image
        for j = 1:length(concentration_files)
            load([directories.folder_save, fsep, concentration_files{j}, '.mat'], 'dye_calib_frame');
            % Put merged data and current data into the same data structure, so
            % that we have an (nx, ny, 2) array
            squashed_dye_calib = cat(3, merged_dye_calib, dye_calib_frame);
            % Now find the max value in the k/3rd dimension, and that's the merged
            % data
            merged_dye_calib = max(squashed_dye_calib, [], 3);
        end

        base_filename = strcat(directories.folder_save, fsep, 'C-Calib_dyecal', num2str(concentrations(i), '%02d'));

        % Display the merged data and save the image to file
        figure(1);
        clf(1);
        imagesc(X, Y, merged_dye_calib');
        colorbar;
        caxis([0, max(merged_dye_calib(:))]);
        set(gca, 'YDir', 'normal');
        axis equal tight;
        set(gca, 'Color', 'w');
        saveas(gca, base_filename, 'png');

        % We rename the variable here, so it takes the given name we want as is
        % used throughout the rest of the code base
        dye_calib_frame = merged_dye_calib;


        save(strcat(base_filename, '.mat'), 'dye_calib_frame', 'X', 'Y');

    end

end
