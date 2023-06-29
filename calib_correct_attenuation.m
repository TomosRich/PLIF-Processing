function calib_correct_attenuation(directories, concentrations, epsilon, theta_line_low, theta_line_high, tank_height)
    % calib_correct_attenuation
    %
    % Syntax: correct_attenuation(directories, concentrations, epsilon, theta_line_low, theta_line_high)
    %
    % Inputs:
    %   directories
    %   concentrations - the dye concentrations, 0 must be included last for the background.
    %   epsilon
    %   theta_line_low
    %   theta_line_high
    %   tank_height
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
    % Authors: Dr Christina Vanderwel, D Hertwig, Desmond Lim, Dr Edward Parkinson
    % University of Southampton
    % Revisions:
    %   Adjusted D Hertwig  20 June 2019
    %   Modified Desmond Lim 19 Dec 2019 -> for unscaled raw PLIF image
    %   Modified Desmond Lim 13 Jan 2022 -> for smooth-wall TBL expts
    %   Modified E Parkinson 18 Jul 2022 -> refactor for publication

    fsep = filesep;

    for i = 1:length(concentrations)
        concentration_files{i} = strcat('C-Calib_dyecal', num2str(concentrations(i), '%02d'));
        concentrations(i) = concentrations(i); % Need to do division here, as units change, no we don't
    end

    % Laser origin
    load(strcat(directories.folder_save, fsep, 'origin_XY.mat'), 'origin_X', 'origin_Y');

    % Correct the frame for attenuation, excluding the background image.
    for i = 1:length(concentration_files) - 1

        % Load Result from trace rays
        load(strcat(directories.folder_save, fsep, concentration_files{i}, 'X.mat'), 'dye_calib_frame', 'X', 'Y')

        % Display
        figure(1);
        clf(1);
        imagesc(X, Y, dye_calib_frame');
        colorbar;
        caxis([0, max(dye_calib_frame(:))]);
        set(gca, 'YDir', 'normal');

        % Trace and draw rays
        R = origin_Y;
        hold on;

        for theta = theta_line_low:theta_line_high
            h = line([origin_X, origin_X + R * sind(theta)], [origin_Y, origin_Y - R * cosd(theta)]);
            set(h, 'Color', 'k', 'LineStyle', '--');
        end

        axis equal;
        axis([min(X), max(X), min(Y), max(Y)]);

        % Determine path length through the tank
        [X_mesh, Y_mesh] = meshgrid(X, Y);
        delta_Y = tank_height - Y_mesh;
        delta_X = (tank_height - Y_mesh) ./ (origin_Y - Y_mesh) .* (origin_X - X_mesh);
        delta_R = sqrt(delta_X.^2 + delta_Y.^2); % 

        % Correct the tank image for attenuation
        corrected_dye_calib_frame = dye_calib_frame ./ exp(-delta_R' * concentrations(i) * epsilon / 1000);

        % Display result
        figure(2);
        clf(2);
        imagesc(X, Y, corrected_dye_calib_frame');
        colorbar;
        caxis([0, max(corrected_dye_calib_frame(:))]);
        set(gca, 'YDir', 'normal');
        axis equal tight;

        % change identifiers, so they're saved how we want using print and saveas
        old_dye_calib_frame = dye_calib_frame;
        dye_calib_frame = corrected_dye_calib_frame;

        % Save Result
        save(strcat(directories.folder_save, fsep, concentration_files{i}, 'corr', num2str(epsilon), '.mat'), 'old_dye_calib_frame', 'X', 'Y', 'dye_calib_frame');
        saveas(gca, strcat(directories.folder_save, fsep, concentration_files{i}, 'corr', num2str(epsilon), '.png'));

    end

    calib_attenuation_summary_figures(directories, concentration_files, concentrations, origin_X, epsilon, delta_R);

end
