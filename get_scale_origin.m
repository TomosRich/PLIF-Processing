function [xy_scale, xy_offset] = get_scale_origin(calib_image, x_loc, y_loc)
    % get_scale_origin  Get geometric scaling and offset parameters for image setup
    %
    % The user is prompted to select two points at the corners of the calibration
    % board, followed by the origin. This will then be used to calculate gemoetric
    % scaling factors.
    %
    % Syntax: [xy_scale, xy_offset] = get_scale_origin(calib_image, x_loc, y_loc)
    %
    % Inputs:
    %   calib_image
    %   x_loc
    %   y_loc
    %
    % Ouputs:
    %   xy_scale
    %   xy_offset
    %
    % Example:
    %   -
    %
    % See also: -
    %
    % Other m-files required: none
    % Subfunctions: showimx, readimx
    % MAT-files required: none
    % Other files required: none
    %
    % Authors: Dr Edward Parkinson
    % University of Southampton
    % Revisions:
    %   Created E Parkinson 11 Aug 2022 Creating for refactor/documentation purposes

    [~, ~, ext] = fileparts(calib_image);
    if strcmp(ext, '.im7') == true
        showimx(readimx(calib_image).Frames{1});
        imcontrast(gca);
    else
        caxis([min(calib_image(:)) max(calib_image(:))]);
        imagesc(read_image(calib_image));
    end

    hold on;
    axis equal tight;

    % manually choose and extract scaling factor.
    waitfor(msgbox(['Select two points at the corners of the calibration board followed by origin. Corresponding' ...
                ' real-world dimensions: x = ', num2str(x_loc), 'mm, y=', num2str(y_loc), 'mm']));

    [x, y] = ginput(3);
    
    plot(x, y, 'ro');


    x_px = abs(x(2) - x(1));
    y_px = abs(y(2) - y(1));
    x_scale = x_loc / x_px;
    y_scale = y_loc / y_px;
    disp(['Image distortion based on x-scale to y-scale ratio: ', num2str(x_scale / y_scale)]);

    % return variables
    xy_scale = (x_scale + y_scale) / 2;
    xy_offset = [x(3), y(3)];

end
