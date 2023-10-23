% Created - Tomos Rich, unfinished epsilon experimental code

function [mean_list, concentration_list, dev_list] = epsilon_correct_attenuation(directories, concentrations, epsilon)

    for i = 1:length(concentrations)
        concentration_files{i} = strcat('C-Calib_dyecal', num2str(concentrations(i), '%02d'));
    end

    mean_list = zeros(1, size(concentrations, 2));
    dev_list = zeros(1, size(concentrations, 2));
    concentration_list = flip(concentrations);

    % Laser origin.
    load(strcat(directories.folder_save, 'origin_XY.mat'), 'origin_X', 'origin_Y');

    % attenuation factor
    save(strcat(directories.folder_save, 'epsilon.mat'), 'epsilon')

    % Correct the frame for attenuation
    for i = 1:length(concentration_files) - 1
        load(strcat(directories.folder_save, concentration_files{i}, 'X.mat'), 'dye_calib_frame', 'X', 'Y');

        % Determine path length through the tank
        tank_height = 364;  % tank height must be specified, this is distance from origin to top of tank
        [X_mesh, Y_mesh] = meshgrid(X, Y);
        delta_Y = tank_height - Y_mesh;
        delta_X = (tank_height - Y_mesh) ./ (origin_Y - Y_mesh) .* (origin_X - X_mesh);
        delta_R = sqrt(delta_X.^2 + delta_Y.^2); % + 10 here to account for z-axis attenuation.?

        % Correct the tank image for attenuation
        corrected_dye_calib = dye_calib_frame ./ exp(-delta_R' * concentrations(i+1) * epsilon / 1000);
        mean_list(i) = mean(corrected_dye_calib, 'all');

        Delta_y = tank_height - Y_mesh;
    Delta_x = (tank_height-Y_mesh)./(origin_Y-Y_mesh) .* (origin_X-X_mesh);
    Delta_r = sqrt(Delta_x.^2 + Delta_y.^2); %

    % Correct the tank image for attenuation
    CorrectedDyeCal = dye_calib_frame ./ exp(-Delta_r' * concentration_list(i+1) * epsilon/1000);

    OldDyeCalFrame = dye_calib_frame;
    dye_calib_frame = CorrectedDyeCal;


    r_min = min(min(delta_R));
    r_max = max(max(delta_R));
    r_range = r_max-r_min;
    r_min_low = r_min+0.05*r_range;
    r_min_high = r_min+0.10*r_range;
    r_max_low = r_max-0.10*r_range;
    r_max_high = r_max-0.05*r_range;
    r_min_test_area = find(delta_R>r_min_low & delta_R<r_min_high,1000);
    r_max_test_area = find(delta_R>r_max_low & delta_R<r_max_high,1000);
    unravelled_dyecal = dye_calib_frame(:);
    mean_r_min = mean(unravelled_dyecal(r_min_test_area));
    mean_r_max = mean(unravelled_dyecal(r_max_test_area));

    Deviation_Intensity = abs(mean_r_max-mean_r_min);


    dev_list(i) = Deviation_Intensity;
    % used to select area to optimise epsilon within
    Mean_Intensity = mean(dye_calib_frame(880:end-880,1400:1900),'all');
    MeanList(i) = Mean_Intensity;


    end

    background = load(strcat(directories.folder_save, concentration_files{end}, '.mat')).dye_calib_frame;
    mean_intensity_background = mean(background(880:end-880,1400:1900), 'all');
    mean_list(end) = mean_intensity_background;

    mean_list = flip(mean_list);
    dev_list = flip(dev_list);
    mean_list = mean_list(:) - mean_list(1);
end
