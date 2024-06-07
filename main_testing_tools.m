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
addpath('Sub_functions');
addpath('readimx-v2.1.9');

%% Parameters
% Set the run time parameters first. These parameters are split between
% the `directories` and `parameters` structs, or are their own variables.

run_name = 'Test';   % A descriptive name for the experiment
save_inst = true;           % Should instantaneous data be saved, as well as average? (true adds ~200 % to run time)
num_images = 20;            % Number of images to process
dye_release_conc = 60;      % Dye release concentration (usually in mg/L)
dye_conc_mg_L = [0.05, 0.03, 0.00];  % Dye concentration variations
image_type = 'im7';          % The image file extension

% This struct defines the various directories which contain the LIF images and
% calibration data, as well as the directory to store the program's output
directories.folder_main = 'Test_dataset\Inputs\Concentration_calibration';  % directory containing calibration info for data
directories.folder_calib = 'Test_dataset\Inputs\Calibration_plate\CalibrationExport';  % directory containing images used to calculate calibration coefficients
directories.folder_plif = 'Test_dataset\Inputs\Unprocessed_LIF';                         % directory containing images to be calibrated
directories.folder_save = 'Test_dataset\Outputs';  

% These are parameters which control some of the finer details of the
% calibration process. Not all of them are required, and a default value will
% be used if not provided.

parameters.y0 = -146.2;               % Vertical offsets in mm
parameters.x0 = 190;                     % Horizontal offsets in mm
parameters.epsilon = 11.05;               % epsilon value -- can be calculated elsewhere
parameters.x_loc = 70;                       % calibration distance, default is mm
parameters.y_loc = 70;                       % calibration distance, default is mm
parameters.y_extra = 25;                      % the lower y interpolation boundary in mm
parameters.y_high_end = 130;                  % the upper y interpolation boundary in mm
parameters.theta_line_low = 0;              % trace_ray polar interpolation boundary in degrees
parameters.theta_line_high = 10;              % trace_ray polar interpolation boundary in degrees
parameters.tank_height = 156;                 % the height of the tank above the origin, code is easiest to run when setting origin to tank floor
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
% Graph printing to test code functionality
print_test_diagrams % if entering user inputs with test dataset then note that it is designed to 
                    % use the cross in the middle as the origin, and each dot is separated by 10mm
function print_test_diagrams
close all

background_unprocessed = load('Test_dataset\Outputs\C-Calibration_C=0.00.mat');
cal_03_unprocessed = load('Test_dataset\Outputs\C-Calibration_C=0.03_01.mat');
cal_05_unprocessed = load('Test_dataset\Outputs\C-Calibration_C=0.05_01.mat');
cal_03_processed = load('Test_dataset\Outputs\C-Calib_dyecal3.000000e-02X.mat');
cal_05_processed = load('Test_dataset\Outputs\C-Calib_dyecal5.000000e-02X.mat');

figure(1);
clf(1);
subplot(3,2,1)
imagesc(background_unprocessed.X, background_unprocessed.Y, (fliplr(background_unprocessed.dye_calib_frame')));
colorbar;
axis equal tight;
%clim([-6 -1])
set(gca, 'YDir', 'normal');
title('Background image')

subplot(3,2,3)
imagesc(cal_03_unprocessed.X, cal_03_unprocessed.Y, (fliplr(cal_03_unprocessed.dye_calib_frame')));
colorbar;
axis equal tight;
set(gca, 'YDir', 'normal');
title('Unprocessed calibration image for 0.03 mg/l dye tank')

subplot(3,2,5)
imagesc(cal_05_unprocessed.X, cal_05_unprocessed.Y, (fliplr(cal_05_unprocessed.dye_calib_frame')));
colorbar;
axis equal tight;
set(gca, 'YDir', 'normal');
title('Unprocessed calibration image for 0.05 mg/l dye tank')

subplot(3,2,4)
imagesc(cal_03_processed.X, cal_03_processed.Y, real(fliplr((cal_03_processed.dye_calib_frame'))));
colorbar;
axis equal tight;
ylim([-138 150])
%clim([-6 -1])
set(gca, 'YDir', 'normal');
title('Fully processed calibration image for 0.03 mg/l dye tank')

subplot(3,2,6)
imagesc(cal_05_processed.X, cal_05_processed.Y, real(fliplr((cal_05_processed.dye_calib_frame'))));
colorbar;
axis equal tight;
ylim([-138 150])
%clim([-6 -1])
set(gca, 'YDir', 'normal');
title('Fully processed calibration image for 0.05 mg/l dye tank')
disp(' ')
disp('Figure 1 subplot 1 shows the background, this image should have low but positive pixel values')
disp(' ')
disp('Figure 1 subplots 3 and 5 show unprocessed calibrations, these should have count values roughly mid way between')
disp('zero and the maximum pixel depth of your camera')
disp(' ')
disp('Figure 1 subplots 2 and 4 show processed calibration images, these should have similar values to the unprocessed ones')
disp('but the shape of the calibration tank should not be visible. Visual artifacts should be minimal.')
disp(' ')


figure(2);
clf(2);

raw_plif = read_image('Test_dataset\Inputs\Unprocessed_LIF\B0018.im7');
processed_plif = load('Test_dataset\Outputs\Test_PLIF_18.mat');
mean_plif = load('Test_dataset\Outputs\Test_PLIFstats.mat');

subplot(2,2,1)
%raw image example
imagesc(processed_plif.AC_frame.X, processed_plif.AC_frame.Y, real(log10(double(raw_plif'))));
colorbar;
axis equal tight;
ylim([-138 150])
clim([3 4.6])
set(gca, 'YDir', 'normal');
title('Raw PLIF image, values equate to log10 measured count value of each pixel')

subplot(2,2,2)
%processed instantaneous image
imagesc(processed_plif.AC_frame.X, processed_plif.AC_frame.Y, real((log10(processed_plif.AC_frame.C'))));
colorbar;
axis equal tight;
ylim([-138 150])
clim([-5 -3.5])
set(gca, 'YDir', 'normal');
title('Fully processed PLIF image, values represent log10 local concentration at each pixel, normalised by source')

subplot(2,2,3)
%mean concentration
imagesc(mean_plif.AC.X, mean_plif.AC.Y, real((log10(mean_plif.AC.mean_C'))));
colorbar;
axis equal tight;
ylim([-138 150])
clim([-5.2 -3.5])
set(gca, 'YDir', 'normal');
title('Mean concentration over 20 snapshots, on log10 scale')

subplot(2,2,4)
%concentration variance
imagesc(mean_plif.AC.X, mean_plif.AC.Y, real((log10(mean_plif.AC.variance_C'))));
colorbar;
axis equal tight;
ylim([-138 150])
clim([-10 -7])
set(gca, 'YDir', 'normal');
title('Concentration variance over 20 snapshots, on log10 scale')

disp('Raw plif image (figure 2 subplot 1) should have pixel values around 3 : 5 where dye is present, depending on your camera pixel depth')
disp(' ')
disp('Processed plif image (figure 2 subplot 2) should have pixel values around -3 : -5 where')
disp('dye is present, depending on your camera pixel depth')

end
