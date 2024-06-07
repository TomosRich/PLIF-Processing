function calculate_background_intensity_gradient(directories, image_type, num_images, run_name)
    % calculate_background_intensity_gradient
    %
    % Syntax: calculate_background_intensity_gradient(directories, num_images, run_name)
    %
    % Inputs:
    %   directories
    %   image_type
    %   num_images
    %   run_name
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

    % Load in the background intensity image, to get the size of the frame
    fsep = filesep;
    load(strcat(directories.folder_save, fsep, 'C-Calib_dyecal00.mat'), 'dye_calib_frame');
    nx = size(dye_calib_frame, 1);
    ny = size(dye_calib_frame, 2);

    % This line selects section of image to use for background intensity
    % modify the portion of E selected so that it corresponds to a section of the image with no dye
    Eframe = dye_calib_frame;
    E = Eframe(int16(3 * (nx / 8)):int16(5 * (nx / 8)), int16(1 * (ny / 8)):int16(2 * (ny / 8))); 
    zeropoint_intensity_value = mean(E, 'all');

    intensity_gradient = zeros(1, num_images);

    for i = 1:num_images
        intensity_gradient(i) = get_background_intensity(i, directories.folder_plif, image_type);
    end

    % Plot and save the background intensity
    figure(1);
    clf(1);
    vars = linspace(1, num_images, num_images);
    p = polyfit(vars, intensity_gradient, 1);
    background_intensity_curve = polyval(p, vars);

    plot(vars, intensity_gradient);
    hold on;
    plot(background_intensity_curve);
    xlabel('Image Number');
    ylabel('Background Intensity Factor');
    title(run_name);

    save(strcat(directories.folder_save, fsep, 'background_intensity_curve.mat'), 'background_intensity_curve');
    save(strcat(directories.folder_save, fsep, 'zeropoint_intensity_value.mat'), 'zeropoint_intensity_value');

end
