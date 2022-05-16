%main central function

%Variable Input
runname = '2D_P1_Cs_5';
save_inst = 'yes'; %Should instantaneous data be saved as well as average? (Yes adds roughly 200% to run time)
use_complex_background = 0; %1 means it is used in calculating calibration gradients
%use_scaling_background = 1; %1 means background for subtraction can vary in intensity, advisable for high dye concentrations
snaps = 2000; %Number of images to process (multiple of 4 pls)
Cs = 5; %Dye release concentration (Usually in mg/L)

mainfolder = '..\P1\Properties\C-Calibration Data\';
save_folder = '..\Matlab_Output(Processed)\P15_PLIF\';
folder_calib = '..\P1\Properties\Calibration\';%'..\P1\Properties\Calibration History\Calibration_211208_191636\', '..\P3\Properties\Calibration\'
folder_PLIF = '..\P1\LIF Cs 5 (other is 1)\'; %P3 LIF_4, P2 LIF_14, P1 LIF_5

y0 = -134.7320+1.25; % Vertical offsets: P1= -134.7320 + 1.25, P2 = -134.7320, P3 = -101.4820
x0 = 203.3733 ; % Horizontal offsets: P1= 203.3733, P2= 357.9233 P3= 550.9233 
epsilon = 31;

addpath('readimx-v2.1.9')  

%ProcessDyeCal_Step01_Average(mainfolder,save_folder,folder_calib,y0,x0)

%ProcessDyeCal_Step02_Merge(mainfolder,save_folder,folder_calib,y0,x0)

%ProcessDyeCal_Step03_TraceRays(mainfolder,save_folder,folder_calib,y0,x0)

%ProcessDyeCal_Step04_CorrectAttenuation(mainfolder,save_folder,folder_calib,y0,x0,epsilon)

%Background_intensity_gradient(mainfolder,save_folder,folder_calib,folder_PLIF,y0,x0,snaps,runname)

%ProcessDyeCal_Step05_MakeFinalDyeCalFiles(mainfolder,save_folder,folder_calib,folder_PLIF,y0,x0,snaps,Cs)

PLIF_process_stats_DL_22Jan2022(mainfolder,save_folder,folder_calib,folder_PLIF,y0,x0,runname,save_inst,snaps,Cs,use_complex_background)

ProcessDyeCal_Stitch_and_Print % Use if other processing is complete
