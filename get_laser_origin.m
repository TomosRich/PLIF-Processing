function [origin_X, origin_Y, Amat, Bmat] = get_laser_origin(dye_calib_frame, X, Y, num_lines)
    % get_laser_origin      Get the origin for the laser
    %
    % Syntax: [origin_X, origin_Y, Amat, Bmat] = get_laser_origin(dye_calib_frame, X, Y, num_lines)
    %
    % Inputs:
    %   dye_calib_frame
    %   X
    %   Y
    %   num_lines
    %
    % Ouputs:
    %   origin_X
    %   origin_Y
    %   Amat
    %   Bmat
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
    %   Created E Parkinson 11 Aug 2022  Created to document better

    coeff = zeros(num_lines, 2);

    % Select prominent lines to trace them to the laser head origin.
    figure(1);
    clf(1);
    imagesc(X, Y, dye_calib_frame');
    hold on;
    colorbar;
    caxis([0 max(dye_calib_frame(:))]);
    set(gca, 'YDir', 'normal');
    imcontrast(gca);

    for i = 1:num_lines
        waitfor(msgbox('Select 5 points on the same line'))
        [x, y] = ginput(5);
        plot(x, y, 'ro')
        coeff(i, :) = polyfit(x, y, 1);
        yy = 0:1:max(Y);
        %line((yy - coeff(i, 2)) / coeff(image, 1), yy);
    end

    close all; % Close selection figure, otherwise it gets confusing

    Amat = [coeff(:, 1), -1 * ones(size(coeff(:, 1)))];
    Bmat = -coeff(:, 2);
    origin_matrix = Amat \ Bmat;
    origin_X = origin_matrix(1);
    origin_Y = origin_matrix(2);

    figure(1);
    clf(1);
    imagesc(X, Y, dye_calib_frame');
    hold on;
    colorbar;
    caxis([0 max(dye_calib_frame(:))]);
    set(gca, 'YDir', 'normal');

    yy = 0:1:origin_Y;

    for i = 1:num_lines
        line((yy - coeff(i, 2)) / coeff(i, 1), yy);
    end

    ylim([-10 600]);
    hold off;
    waitfor(msgbox('Check and make sure all lines converge to roughly the same spot!'));

end
