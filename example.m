% example.m     Example script for using package.
%
% An example script for calibrating and applying the calibration to get
% mean and variance statistics for the experiment.
%
% Other m-files required:
%   calib_calculate_coefficients.m
%   apply_calibration_coefficients.m
% Subfunctions: none
% MAT-files required: none
% Other files required: calibration files, image files, geometry files
%


% Add the required libraries/packages to the MATLAB path

addpath('readimx-v2.1.9');
addpath('matlab-plif');

%% Parameters
% Set the run time parameters first. These parameters are split between
% the `directories` and `parameters` structs, or are their own variables.

run_name = 'Downstream_Planar_P100';   % A descriptive name for the experiment
save_inst = true;           % Should instantaneous data be saved, as well as average? (true adds ~200 % to run time)
num_images = 2000;            % Number of images to process
dye_release_conc = 60;      % Dye release concentration (usually in mg/L)
dye_conc_mg_L = [0.05, 0.03, 0.00];  % Dye concentration variations
image_type = 'im7';          % The image file extension

% This struct defines the various directories which contain the LIF images and
% calibration data, as well as the directory to store the program's output
directories.folder_main = 'D:\Processing\Downstream_planar_p100\Properties';  % directory containing calibration info for data
directories.folder_calib = 'D:\Processing\Downstream_planar_p100\Calibration p100\CalibrationExport';  % directory containing images used to calculate calibration coefficients
directories.folder_plif = 'D:\Processing\Downstream_planar_p100\LIF_1';                         % directory containing images to be calibrated
directories.folder_save = 'E:\Downstream_planar_p100\PLIF';  

% These are parameters which control some of the finer details of the
% calibration process. Not all of them are required, and a default value will
% be used if not provided. Using defaults is highly discoruaged and will not give accurate results 
% for your individual case. It is included to help in running the code initially.

parameters.y0 = -81.173-51.2-135;               % Vertical offsets typically in mm
parameters.x0 = 190;                     % Horizontal offsets also typically in mm
parameters.epsilon = 11.05;               % epsilon value -- can be calculated elsewhere
parameters.x_loc = 50;                       % calibration distance, default is mm
parameters.y_loc = 50;                       % calibration distance, default is mm
parameters.y_extra = 142;                      % the lower y interpolation boundary in mm
parameters.y_high_end = 255;                  % the upper y interpolation boundary in mm
parameters.theta_line_low = 0;              % trace_ray polar interpolation boundary in degrees
parameters.theta_line_high = 10;              % trace_ray polar interpolation boundary in degrees
parameters.tank_height = 364;                 % the height of the tank above the origin, code is easiest to run when setting origin to tank floor
parameters.beta_polar_interp = true;         % enable polar interpolation along rays - this is a BETA feature
parameters.normalize_energy_monitor = true;  % normalize by the laser energy monitor for LaVision devices

%% Perform the calibration calculations
% Once the parameters are set, we can call the two functions to calculate
% the calibration coefficients, and then the other to apply those
% coefficients to an image.

% Calibration steps -- this function squashes all five calibration steps into
% one function call to calculate calibration coefficients
calib_calculate_coefficients(directories, parameters, image_type, num_images, run_name, dye_conc_mg_L);

% Apply calibration and generate summary statistics
apply_calibration_coefficients(directories, parameters, image_type, run_name, save_inst, num_images, ...
                               dye_release_conc);

