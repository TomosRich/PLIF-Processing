function PLIF = get_plif_image(i, directories, image_type, background_frame, A_cal, Cs, xy_scale, xy_offset, x0, y0, normalize_energy_monitor)
    % get_plif_velocity
    %
    % Syntax: PLIF = get_plif_image(i, directories, background_frame, A_cal, Cs, xy_scale, xy_offset, x0, y0, normalize_energy_monitor)
    %
    % Inputs:
    %   i
    %   directories
    %   image_type
    %   background_frame
    %   A_cal
    %   Cs
    %   xy_scale
    %   xy_offset
    %   x0
    %   y0
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
    % MAT-files required: none
    % Other files required: none


    fsep = filesep;
    image = imread(strcat(directories.folder_plif, fsep, 'B', num2str(i, '%04d'), '.', image_type))';
    em_fp = strcat(directories.folder_plif, fsep , '..' , fsep, 'EnergyMonitor_ref2000', fsep, 'B00001.im7');


    nx = size(image, 1);
    ny = size(image, 2);
    X = (double(1:nx) - xy_offset(1)) * xy_scale;
    Y = (double(1:ny) - xy_offset(2)) * xy_scale;

    % Shift axes and flip C in streamwise direction (it was flipped in
    % calibration post-processing as well).
    X = X + x0;
    Y =- (Y + y0);
    image = flipud(image);
    background_frame = flipud(background_frame);

    load(strcat(directories.folder_save, fsep, 'zeropoint_intensity_value.mat'), 'zeropoint_intensity_value');
    load(strcat(directories.folder_save, fsep, 'background_intensity_curve.mat'), 'background_intensity_curve');

    % in case of need to manually increase background subtraction
    thoroughness_factor = 1.00;
    background_multiplier = (background_intensity_curve(i) / zeropoint_intensity_value);
    background_multiplier = max([background_multiplier, 1]);
    big_background = background_frame * background_multiplier * thoroughness_factor;

    % Normalise PLIF frame by device data, and add to the average matrix
    % This should only be done with LaVision laser devices
    if normalize_energy_monitor == true && strcmp(image_type, 'im7') == true

                buffer = readimx(strcat(directories.folder_plif, fsep, 'B', num2str(i, '%04d'), '.', image_type));
                buffer_em_value = buffer.Attributes{59, 1}.Value(1,1);  
                energy_monitor_norm = 2000/ (2000 + buffer_em_value);
    else
        energy_monitor_norm = 1;

    end

    C = ((double(image) / energy_monitor_norm) - flipud(big_background)) .* A_cal; % pretty confident background needs flipud
    C = flipud(C); % Now we flip it back.... Yea I know... -_-!

    % Normalise by source concentration
    C = C / Cs;

    % threshold out anything less than zero
    threshold = 0;
    C(C < threshold) = 0;

    % Return the PLIF data
    PLIF.X = X;
    PLIF.Y = Y;
    PLIF.D = image;
    PLIF.C = C;
end
