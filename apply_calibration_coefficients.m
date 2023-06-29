function apply_calibration_coefficients(directories, parameters, image_type, run_name, save_inst, num_images, Cs)
    % apply_calibration_coefficients    Concentration statistics - MEAN and instantaneous.
    %
    % Syntax: apply_calibration_coefficients(directories, parameters, run_name, save_inst, num_images, Cs, use_complex_background)
    %
    % Inputs:
    %   directories
    %   parameters
    %   image_type
    %   run_name
    %   save_inst
    %   num_images
    %   Cs
    %   use_complex_background
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
    % Authors: Dr Edward Parkinson
    % University of Southampton
    % Revisions:
    %   Created E Parkinson 11 Aug 2022

    if ~exist(directories.folder_save, 'dir')
        mkdir(directories.folder_save)
    end

    fsep = filesep;
    load(strcat(directories.folder_save, fsep, 'C-Calib-dyecal.mat'), 'background_frame', 'A_cal');
    load(strcat(directories.folder_save, fsep, 'geometric_scale.mat'), 'xy_scale', 'xy_offset');

    % If we've already calculated the stats, then retreive from file. Otherwise
    % calculate the properties. The things we want are kept in the AC struct.

    stats_filename = strcat(directories.folder_save, run_name, '_PLIFstats.mat');

    if exist(stats_filename, 'file')
        load(stats_filename, 'AC');
    else
        mean_C = 0;

        for i = 1:num_images
            PLIF = get_plif_image(i, directories, image_type, background_frame, A_cal, Cs, xy_scale, xy_offset, ...
                parameters.x0, parameters.y0, parameters.normalize_energy_monitor);

            mean_C = mean_C + PLIF.C;
        end

        AC.mean_C = mean_C ./ num_images;

        % Now we calculate the variance

        variance_C = 0;

        for i = 1:num_images
            PLIF = get_plif_image(i, directories, image_type, background_frame, A_cal, Cs, xy_scale, ...
                xy_offset, parameters.x0, parameters.y0, parameters.normalize_energy_monitor);

            variance_C = variance_C + (PLIF.C - AC.mean_C).^2.0;

            if save_inst == true
                AC_frame.X = PLIF.X;
                AC_frame.Y = PLIF.Y;
                AC_frame.C = PLIF.C;
                AC_frame.cc = (PLIF.C - AC.mean_C).^2.0;
                save(strcat(directories.folder_save, fsep, run_name, '_PLIF_', num2str(i), '.mat'), 'AC_frame');
            end

        end

        AC.variance_C = variance_C ./ (num_images - 1);
        AC.X = PLIF.X;
        AC.Y = PLIF.Y;

        save(strcat(directories.folder_save, fsep, run_name, '_PLIFstats.mat'), 'AC')
    
    end

    % Plot the average

    figure(1);
    clf(1);
    imagesc(AC.X, AC.Y, log10(AC.mean_C'));
    colorbar;
    axis equal tight;
    clim([-6 -1])
    set(gca, 'YDir', 'normal');
    %saveas(gca, strcat(directories.folder_save, fsep, run_name, '_mean_C.png'));

    % Plot the variance

    figure(2);
    clf(2);
    imagesc(AC.X, AC.Y, log10(AC.variance_C'));
    colorbar;
    axis equal tight;
    clim([-12 -4])
    set(gca, 'YDir', 'normal');
    %saveas(gca, strcat(directories.folder_save, fsep, run_name, '_variance_C.png'));

end
