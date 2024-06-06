# PLIF-Processing
Calibration and post processing software for Planar Laser Induced Fluorescence Imaging

Functions are run from a main file, an example of a main file is included and labeled example.m, this file is copied directly from an experimental case carried out
at the University of Southampton and has not been designed to run without configuring to the user's case. 
The script code_testing_tools.m is designed to run directly from the cloned file using the built in functions and data. It has been included as a direct example 
of the code working as intended, and also as a check of the package's functionality.
To use it to test your own data it is advised to copy the data into the test_data/inputs folder, and delete the files in the output folder in order to reset user inputs.
If you would like to practice an example of entering the user inputs then empty the output folder prior to running code_testing_tools.m without resetting the input data. 
Calibration plate dot spacing in the example images is 10mm and the intended origin is the cross in the center of the calibration plate.

A few example images have been included in the Test_dataset folder, these were taken during experiments carried out at the University of Southampton.
They are included for use in code_testing_tools.m, in order to check that the code is functioning correctly.
These images were taken using LaVision equipment and are consequently in .imx format. Therefore processing them requires having LaVision's 'readimx-v2.1.9' file in the path.

This code is designed to convert fields of dye fluorescence into fields of dye concentration.
Running this code can be divided into two sections; create calibration, and apply calibration. 
Creating a calibration requires images in which dye of known concentrations is fluorescing in the same location as the experimental images.
It also requires a background image of the area with no dye present, and a calibration image that a length scale can be calculated from (eg an image of a calibration plate).
User input is required at several steps but only the initial time the code is run, if you want to reset the user input then go into your output folder and delete the geometric_scale.mat, and origin_XY.mat files.

If visual artifacts remain in calibration images then adjusting the interpolation area is advised.
Interpolation area is defined as everything outside parameters.y_extra - parameters.y_high_end in the y direction.
X limits for interpolation are defined on lines 97-98 of calib_trace_rays.m.
As of 05/06/2024 polar interpolation is advised for most cases.
All attenuation correction is carried out between y = 0 and y = tank height. It is advised to set a y offset such that y = 0  is at the bottom of the calibration tank, even if this is outside the camera field of view.

Good luck, PLIF is a finicky science :)
