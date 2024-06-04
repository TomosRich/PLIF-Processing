# PLIF-Processing
Calibration and post processing software for Planar Laser Induced Fluorescence Imaging

Functions are run from a main file, an example of a main file is included and labeled example.m

A few example images have been included in the Test_dataset folder, these were taken during experiments carried out at the University of Southampton.
They are included for use in code_testing_tools.m, in order to check that the code is functioning correctly.
These images were taken using LaVision equipment and are consequently in .imx format. Therefore processing them requires having LaVision's 'readimx-v2.1.9' file in the path.

If visual artifacts remain in calibration images after averaging then areas can be selected for interpolation in calib_trace_rays.
All attenuation correction is carried out between y = 0 and y = tank height.