function calib_average_frames(directories, concentrations, image_type, y0, x0, x_loc, y_loc, normalize_energy_monitor)
    % calib_average_frames   Combine multiple image frames into one by taking the average value
    %
    % Syntax: average_frames(concentrations, directories, y0, x0, x_loc, y_loc)
    %
    % Inputs:
    %   concentrations
    %   directories
    %   image_type
    %   y0
    %   x0
    %   x_loc
    %   y_loc
    %   normalize_energy_monitor
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
    % MAT-files required: geometric_scale.mat [optional]
    % Other files required: .im7 image files
    %
    % Authors: Dr Christina Vanderwel, D Hertwig, Desmond Lim, Dr Edward Parkinson
    % University of Southampton
    % Revisions:
    %   Adjusted D Hertwig   20 June 2019
    %   Modified Desmond Lim 19 Dec 2019 -> for unscaled raw PLIF image
    %   Modified Desmond Lim 13 Jan 2022 -> for smooth-wall TimageL expts
    %   Modified E Parkinson 15 Jul 2022 -> clean up for publication
    %   Modified T Rich 23/05/2023 Fixed energy monitor input application
    fsep = filesep;
    concentration_files = get_dye_conc_filenames(concentrations);

    % Load geometric calibration file, or prompt user to input calibration by clicking image
    gm_scale_filename = strcat(directories.folder_save, fsep, 'geometric_scale.mat');

    if isfile(gm_scale_filename) == true
        load(gm_scale_filename, 'xy_scale', 'xy_offset');
    else
        [xy_scale, xy_offset] = ...
            get_scale_origin(strcat(directories.folder_calib, fsep, 'camera1', fsep, 'B00001.', image_type), x_loc, y_loc);

    end

    % Create save folder, and save geometric calibration file
    if ~exist(directories.folder_save, 'dir')
        mkdir(directories.folder_save)
    end

    save(strcat(directories.folder_save, fsep, 'geometric_scale.mat'), 'xy_scale', 'xy_offset');

    num_average = 10; % We are fixing this at 10, although in the future we may want to be more flexible

    for i = 1:length(concentration_files)

        % Use first image to get the coordinates from the image
        image_fp = strcat(directories.folder_main, fsep, concentration_files{i}, fsep, 'B', num2str(1, '%04d'), '.', image_type);
        image = read_image(image_fp);

        % Get Coordinates
        nx = size(image, 1);
        ny = size(image, 2);
        X = (double(1:nx) - xy_offset(1)) * xy_scale;
        Y = (double(1:ny) - xy_offset(2)) * xy_scale;

        % Shift axes
        X = X + x0;
        Y =- (Y + y0);

        % Setup averaging matrix
        dye_calib_frame = zeros(size(image));

        % Average over all images
        for j = 1:num_average
            % Load image
            image_fp = strcat(directories.folder_main, fsep, concentration_files{i}, fsep, 'B', num2str(j, '%04d'), '.', image_type);
            em_fp = strcat(directories.folder_main, fsep, concentration_files{i}, fsep, 'EnergyMonitor_ref2000', fsep, 'B00001.im7');
            image = read_image(image_fp);

            % Normalise PLIF frame by device data, and add to the average matrix
            % This should only be done with LaVision laser devices
            if normalize_energy_monitor == true && strcmp(image_type, 'im7') == true
                buffer = readimx(image_fp);
                buffer_em_value = buffer.Attributes{72, 1}.Value(1,1);  
                energy_monitor_norm = 2000/ (2000 + buffer_em_value);
            else
                energy_monitor_norm = 1;
            end

            % dye_calib_frame += image / energy_monitor_norm for python enthusiats
            dye_calib_frame = dye_calib_frame + (double(image) / energy_monitor_norm);

        end

        % Divide the averaging Matrix by the number of images
        % Flip array, up to down
        dye_calib_frame = dye_calib_frame ./ j;
        dye_calib_frame = flipud(dye_calib_frame);

        % Display the calibration frame
        figure(1);
        clf(1);
        imagesc(X, Y, dye_calib_frame');
        caxis([0, max(dye_calib_frame(:))]);
        set(gca, 'YDir', 'normal')
        colorbar;

        % Save result, but create save directory if it doesn't exist
        if ~exist(directories.folder_save, 'dir')
            mkdir(directories.folder_save)
        end

        saveas(gca, strcat(directories.folder_save, fsep, concentration_files{i}, '.png'));
        save(strcat(directories.folder_save, fsep, concentration_files{i}, '.mat'), 'dye_calib_frame', 'X', 'Y')
    end

end
