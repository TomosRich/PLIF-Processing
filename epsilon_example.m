% Code to calculate optimal Epsilon for a set of calibration images
% Nearly everything is the same as the main example

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


addpath('readimx-v2.1.9');
addpath('matlab-plif');

% This struct defines the various directories which contain the LIF images and
% calibration data, as well as the directory to store the program's output

directories.folder_main = 'D:\Processing\Downstream_planar_p100\Properties';  % directory containing calibration info for data
directories.folder_calib = 'D:\Processing\Downstream_planar_p100\Calibration p100\CalibrationExport';        % directory containing images used to calculate calibration coefficients
directories.folder_plif = 'D:\Processing\Downstream_planar_p100\LIF_1';                         % directory containing images to be calibrated
directories.folder_save = 'E:\Downstream_planar_p100\PLIF Epsilon\';  

% These are parameters which control some of the finer details of the
% calibration processes.

dye_conc_mg_L = [0.05, 0.03, 0]; % Dye concentrations

parameters.y0 = -81.173-51.2-135;               % Vertical offsets in [UNITS???]
parameters.x0 = 190;                     % Horizontal offsets in [UNITS???]
parameters.epsilon = 49.178500;               % epsilon value -- can be calculated elsewhere
parameters.x_loc = 50;                       % mm
parameters.y_loc = 50;                       % mm
parameters.y_extra = 142;                      % the lower y interpolation boundary in mm
parameters.y_high_end = 255;                  % the upper y interpolation boundary in mm
parameters.theta_line_low = -0;              % trace_ray polar interpolation boundary in degrees
parameters.theta_line_high = 10;              % trace_ray polar interpolation boundary in degrees
parameters.tank_height = 364;                 % the height of the tank above the origin
parameters.beta_polar_interp = true;         % enable polar interpolation along rays 
parameters.normalize_energy_monitor = true;  % normalize by the laser energy monitor for LaVision devices
concentrations = dye_conc_mg_L;
% We need to do some calibration processing to begin with
image_type = 'im7'; 

calib_average_frames(directories, concentrations, image_type, parameters.y0, parameters.x0, parameters.x_loc, parameters.y_loc, parameters.normalize_energy_monitor);
calib_merge_frames(directories, concentrations);
calib_trace_rays(directories, concentrations, parameters.y_extra, parameters.y_high_end, parameters.theta_line_low, parameters.theta_line_high, parameters.beta_polar_interp);

% Now we can use a numerical method to iterate toward an epsilon value

% Use bisection method to find the root in the function f. The location of the
% root is the value of epsilon, the attenuation factor or s/t

lower_lim = 0; % lower limit to search
upper_lim = 200; % upper limit to search
num_iterations = 25; % number of bisections

f_lower = f(directories, dye_conc_mg_L, lower_lim);
f_upper = f(directories, dye_conc_mg_L, upper_lim);

for i = 1:num_iterations
    midpoint = 0.5 * (lower_lim + upper_lim);
    f_midpoint = f(directories, dye_conc_mg_L, midpoint);

    if f_lower + f_midpoint < f_midpoint + f_upper
        lower_lim = midpoint - ((abs(midpoint - lower_lim)) / 8);
        f_lower = f_midpoint;
    else
        upper_lim = midpoint + ((abs(midpoint - upper_lim)) / 8);
        f_upper = f_midpoint;
    end

    fprintf('lower limit = %f , upper limit = %f\n', lower_lim, upper_lim);
    fprintf('lower limit correlation = %f , upper limit correlation = %f\n', f_lower, f_upper);
    fprintf('iteration = %f / %f\n', i, num_iterations);
end

final_midpoint = 0.5 * (lower_lim + upper_lim);
final_correlation = f(directories, dye_conc_mg_L, final_midpoint);
uncertainty = abs(lower_lim - upper_lim);

fprintf('\n max correlation is achieved with an epsilon value of %f , this corresponds to a correlation coefficient of %f ', final_midpoint, final_correlation);
fprintf('\n uncertainty is equal to %f', uncertainty);

function [correlation] = f(directories, concentrations, epsilon)
    [mean_list, concentration_list, dev_list] = epsilon_correct_attenuation(directories, concentrations, epsilon);
    coef = corrcoef(concentration_list, mean_list);
    correlation_2 = (sum(dev_list));
    correlation = coef(1, 2);
end

% graph for debugging
%plot(concentration_list,mean_list,'-o')
%title('Mean Intensity measured in Calibration Tanks vs Concentration');
%xlabel('C')
%ylabel('Counts')

