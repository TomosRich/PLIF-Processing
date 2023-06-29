function calib_trace_rays(directories, concentrations, y_extra, y_high_end, theta_line_low, theta_line_high, polar_interp)
    % calib_trace_rays      Get the origin for the laser
    %
    % Syntax: trace_rays(directories, y_extra, y_high_end, theta_line_low, theta_line_high)
    %
    % Inputs:
    %   directories
    %   concentrations
    %   y_extra
    %   y_high_end
    %   theta_line_low
    %   theta_line_high
    %   polar_interp
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
    %   Adjusted D Hertwig  20 June 2019
    %   Modified Desmond Lim 19 Dec 2019 -> for unscaled raw PLIF image
    %   Modified Desmond Lim 13 Jan 2022 -> for smooth-wall TBL expts
    %   Modified E Parkinson 18 Jul 2022 -> refactor for publication
    %   Modified T Rich 2023 fixed polar interpolation code, and added
    %   horizontal extrapolation

    % TODO: we should construct this vector from given concentrations.
    % Choose dataset to look at and specify concentration

    fsep = filesep;

    for i = 1:length(concentrations)
        concentration_files{i} = strcat('C-Calib_dyecal', num2str(concentrations(i), '%02d'));
    end


    % Find laser origin. Use data from both concentration to find a common pt.
    num_lines = 4;
    Amat = zeros(num_lines * 2, 2);
    Bmat = zeros(num_lines * 2, 1);

    % Try to first get the origin data from file. If it doesn't exist, then we
    % need the user to manually select the origin.
    origin_filename = strcat(directories.folder_save, fsep, 'origin_XY.mat');

    if isfile(origin_filename)
        load(origin_filename, 'origin_X', 'origin_Y');
    else

        for i = 1:length(concentration_files)-1
            load(strcat(directories.folder_save, fsep, concentration_files{i}, '.mat'), 'dye_calib_frame', 'X', 'Y')
            [origin_X, origin_Y, A, B] = get_laser_origin(dye_calib_frame, X, Y, num_lines);
            Amat((num_lines * i - 3):num_lines * i, :) = A;
            Bmat(num_lines * i - 3:num_lines * i) = B;
            disp(strcat(concentration_files{i}, ': ', 'X = ', num2str(origin_X), ', Y = ', num2str(origin_Y)));
        end

        origin_matrix = Amat \ Bmat;
        origin_X = origin_matrix(1);
        origin_Y = origin_matrix(2);
        disp(strcat('Both concentrations for common laser origin', ': ', 'X = ', num2str(origin_X), ', Y = ', num2str(origin_Y)));
        save(origin_filename, 'origin_X', 'origin_Y')
    end

    % theta_interp_low = -10;
    % theta_interp_high = 10;
    % theta_interp_step = 0.02;

    %% Trace Rays and Extrapolate to replace near wall data
    for i = 1:length(concentration_files) - 1

        % Load Result
        load(strcat(directories.folder_save, fsep, concentration_files{i}, '.mat'), 'dye_calib_frame', 'X', 'Y')

        % Trace Rays
        R = origin_Y;
        hold on;

        for theta = theta_line_low:theta_line_high
            h = line([origin_X, origin_X + R * sind(theta)], [origin_Y, origin_Y - R * cosd(theta)]);
            set(h, 'Color', 'k', 'LineStyle', '--');
        end

        axis equal;
        axis([min(X) max(X) min(Y) max(Y)]);

        % Choosing which part of the image to interpolate over
        % upper then low limit -- near the wall is bad, for example.
        % and then to cut out a little box.
        % Extrapolate data to replace the near wall bad data
        
        % Next 4 lines are optional adding of horizontal limits
        %xmin = -15;
        %xmax = 280;
        %dye_calib_frame( 1:max(find(X < xmin)),:) = NaN;
        %dye_calib_frame( min(find(X > xmax)):end,:) = NaN;

        dye_calib_frame = inpaintn(dye_calib_frame);

        dye_calib_frame(:, find(Y < y_extra, 1):end) = NaN;
        dye_calib_frame(:, 1:max(find(Y > y_high_end))) = NaN;



        % A round of polar interpolation first
        % The choices of theta affects the angle (radians) the interpolation
        % acts over, measured from the laser head
        % -10:.02:5 for p2 and 3

        if polar_interp
        theta_line_low = -atand((min(X)-origin_X)/(max(Y)-origin_Y));
        theta_line_high = -atand((max(X)-origin_X)/(max(Y)-origin_Y));
        interpolation_r = 5; 
        % Input of polar interpolation ratio, 1 means all polar, 4 means
        % every 4th pixel is calculated polar
        interpolation_theta = 5;
        % the same ratio idea but with angles to calculate the rays, not
        % distances along rays, 5 for each is pretty sensible usually
        theta_interp_step = (theta_line_high-theta_line_low)/((size(X,2)+size(Y,2))/2)*interpolation_theta;
        R_resolution = abs(min(Y(1)-Y(2), X(1)-X(2)))*interpolation_r;

            for theta = theta_line_low:theta_interp_step:theta_line_high

                R2 = 0:R_resolution:(max(Y)*max(X)*1.0);%origin_Y + (cat(2,min(Y):.01:y_extra,y_extra:0.1:max(Y)));  % distance along beam
                xi = origin_X + R2 * sind(theta);  % x coordinates of beam
                yi = origin_Y - R2 * cosd(theta);  % y coordinates of beam
                [X3, Y3] = meshgrid(X, Y);  % reformatted x and y coordinates
                
                ci = interp2(X3, Y3, dye_calib_frame', xi, yi);  % interpolating beam
                P = polyfit(R2(~isnan(ci)), ci(~isnan(ci)), 1);  % fitting curve to beam interpolation
                ci(isnan(ci)) = polyval(P, R2(isnan(ci)));  % replacing NaNs with curve points
                ylow = y_high_end;
                yhigh = y_extra;
                
                clc
                polar_interpolation_percent_complete = ((theta-theta_line_low)/(theta_line_high-theta_line_low))*100
                for index = find(yi > ylow)
                    xtemp = find(X >= xi(index), 1);
                    ytemp = find(Y <= yi(index), 1);

                    dye_calib_frame(xtemp , ytemp) = ci(index);
                end
                for index = find(yi < yhigh)
                    xtemp = find(X >= xi(index), 1);
                    ytemp = find(Y <= yi(index), 1);

                    dye_calib_frame(xtemp , ytemp) = ci(index);
                end
                for index = find(xi < xmin)
                    xtemp = find(X >= xi(index), 1);
                    ytemp = find(Y <= yi(index), 1);

                    dye_calib_frame(xtemp , ytemp) = ci(index);
                end
                for index = find(xi > xmax)
                    xtemp = find(X >= xi(index), 1);
                    ytemp = find(Y <= yi(index), 1);

                    dye_calib_frame(xtemp , ytemp) = ci(index);
                end
            end

        end

        % use inpaintn function to fill in any missing data
        % smoothing for ray streaks, this can be turned off if necessary
        % this much smoothing is required only when resolution is high
        dye_calib_frame = inpaintn(dye_calib_frame);
        dye_calib_frame = imgaussfilt(dye_calib_frame,0.5);
        dye_calib_frame = imgaussfilt(dye_calib_frame,1);
        dye_calib_frame = imgaussfilt(dye_calib_frame,2);
        dye_calib_frame = imgaussfilt(dye_calib_frame,4);
        dye_calib_frame = imgaussfilt(dye_calib_frame,8);
        dye_calib_frame = imgaussfilt(dye_calib_frame,16);
        dye_calib_frame = imgaussfilt(dye_calib_frame,0.5);
        dye_calib_frame = imgaussfilt(dye_calib_frame,1);
        dye_calib_frame = imgaussfilt(dye_calib_frame,2);
        dye_calib_frame = imgaussfilt(dye_calib_frame,4);
        dye_calib_frame = imgaussfilt(dye_calib_frame,8);
        dye_calib_frame = imgaussfilt(dye_calib_frame,16);
        dye_calib_frame = imgaussfilt(dye_calib_frame,0.5);
        dye_calib_frame = imgaussfilt(dye_calib_frame,1);
        dye_calib_frame = imgaussfilt(dye_calib_frame,2);
        dye_calib_frame = imgaussfilt(dye_calib_frame,4);
        dye_calib_frame = imgaussfilt(dye_calib_frame,8);
        dye_calib_frame = imgaussfilt(dye_calib_frame,16);
        save(strcat(directories.folder_save, fsep, concentration_files{i}, 'X.mat'), 'dye_calib_frame', 'X', 'Y')
    end

    % Display the final result
    figure(1);
    clf(1);
    imagesc(X, Y, dye_calib_frame');
    colorbar;
    caxis([0 max(dye_calib_frame(:))]);
    set(gca, 'YDir', 'normal');
    axis equal tight;
    hold off;

end
