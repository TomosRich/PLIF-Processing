%% This script loads and displays the LaVision Data
% by Dr Christina Vanderwel, University of Southampton
% Adjusted D Hertwig  20 June 2019
% Modified Desmond Lim 19 Dec 2019 -> for unscaled raw PLIF image
% Modified Desmond Lim 13 Jan 2022 -> for smooth-wall TBL expts

function ProcessDyeCal_Step01_Average(mainfolder,save_folder,folder_calib,y0,x0)

% clear all
% clc

% mainfolder  = '..\P3\Properties\C-Calibration Data\';
% save_folder = '..\Matlab_Output(Processed)\P3_PLIF\';

list(1).foldername = 'C-Calibration_C=5.00';
list(2).foldername = 'C-Calibration_C=5.00_01';
list(3).foldername = 'C-Calibration_C=5.00_02';

list(4).foldername = 'C-Calibration_C=3.00';
list(5).foldername = 'C-Calibration_C=3.00_01';
list(6).foldername = 'C-Calibration_C=3.00_02';

list(7).foldername = 'C-Calibration_C=0.00';
% list(8).foldername = 'C-Calibration_C=0.00_01';
% list(9).foldername = 'C-Calibration_C=0.00_02';

% Load geometric calibration file to find origin position. 
% folder_calib = '..\P1\Properties\Calibration History\Calibration_211208_191636\';
x_real = 110;
y_real = 110;
[xy_scale1, xy_offset1] = getScaleOrigin([folder_calib 'camera1' '\B00001.im7'], x_real, y_real);
if ~exist(save_folder, 'dir')
    mkdir(save_folder)
end
save([save_folder, 'geometricScale','.mat'],'xy_scale1','xy_offset1');
close

% Manual offset in mm (to set dye source as origin).  
% P1: x0=84.91, P2: x0+198.8mm, % P3: P2+199.3mm.
%imagesc(DyeCalFrame)

% y0 = -134.7320+0.5;%+41 for P2 - 4.2 for P3 + 0.5
% x0 = 53.3733+150+200+200; %+198.8+199.3;

%% Average ten images from each dataset.
for i = 1:length(list)
     
    % Get coordinates from LaVision File
    A = readimx([mainfolder, list(i).foldername,'\LIF\B', num2str(1,'%04d'),'.im7']);
    FrameIndex = 1;
    
    % Get PLIF Frame
    B = A.Frames{FrameIndex}.Components{1}.Planes{:} * ...
        A.Frames{FrameIndex}.Components{1}.Scale.Slope + ...
        A.Frames{FrameIndex}.Components{1}.Scale.Offset;
    
    % Get Coordinates
    nx = size(B,1);
    ny = size(B,2);
%     X = double(1:nx)  * A.Frames{FrameIndex}.Scales.X.Slope + A.Frames{FrameIndex}.Scales.X.Offset ;
%     Y = double(1:ny)  * A.Frames{FrameIndex}.Scales.Y.Slope + A.Frames{FrameIndex}.Scales.Y.Offset ;
%     X = double(1:nx)  * 0.0665 + -134.9550;
%     Y = double(1:ny)  * -0.0665 + 117.7140;
    X = (double(1:nx)-xy_offset1(1))  * xy_scale1;
    Y = (double(1:ny)-xy_offset1(2))  * xy_scale1;
    
    % Shift axes
    X = X + x0;
    Y = -(Y + y0);
    
    % Setup Averaging Matrix
    DyeCalFrame = zeros(size(B));
    
    for j = 1:10
        % Load LaVision File
        A = readimx([mainfolder, list(i).foldername,'\LIF\B', num2str(j,'%04d'),'.im7']);
        
        %Load Energy Monitor Data
        EnergyMonitor = mean(2000-A.Attributes{12,1}.Value)/2000;
        %EnergyMonitor = mean(EnergyMonitor);
                
        % Get PLIF Frame
        FrameIndex = 1;
        B = A.Frames{FrameIndex}.Components{1}.Planes{:} * ...
            A.Frames{FrameIndex}.Components{1}.Scale.Slope + ...
            A.Frames{FrameIndex}.Components{1}.Scale.Offset;
        
        % Normalise by Device Data
        C = double(B)./EnergyMonitor;
        
        % Add to the Averaging Matrix
        DyeCalFrame = DyeCalFrame + C;
    end
    
    % Divide the averaging Matrix by the number of images
    DyeCalFrame = DyeCalFrame ./ j;
    DyeCalFrame = flipud(DyeCalFrame);
    
%     DyeCalFrame(:,find(Y<15,1):end) = NaN; %    Extrapolate section has been added here, check output as it is produced
%     DyeCalFrame(:,1:max(find((Y>120)))) = NaN;
%     DyeCalFrame = inpaintn(DyeCalFrame);

    % Display
    imagesc(X,Y,DyeCalFrame'); colorbar
    caxis([0 max(DyeCalFrame(:))]);
    set(gca,'YDir','normal')
    
    % Save Result
    %export_fig(['DyeCal\', list(i).foldername,'.png'],'-png')
    if ~exist(save_folder, 'dir')
        mkdir(save_folder)
    end
    print([save_folder, list(i).foldername,'.png'],'-dpng')
    %     pause(4)
    save([save_folder, list(i).foldername,'.mat'],'DyeCalFrame','X','Y')
end

end

% Export Figure
%export_fig(['DyeCal5X_10.png'])
%save '..\Matlab_Output(Processed)\P3_PLIF\C-Calibration_C=3.00.mat' DyeCalFrame X Y
%% Function to extract geometric scaling.
function [xy_scale, xy_offset]=getScaleOrigin(calib, x_real, y_real)

A = readimx(calib);
A = showimx(A.Frames{1});
hold on
axis equal tight

% Manually choose and extract scaling factor.
waitfor(msgbox(['Select two points at the corners of the calibration board followed by origin. Corresponding real-world dimensions: x=', num2str(x_real), 'mm, y=', num2str(y_real), 'mm']))
[x, y]=ginput(3);
plot(x,y,'ro')

x_px = abs(x(2)-x(1));
y_px = abs(y(2)-y(1));
x_scale = x_real / x_px;
y_scale = y_real / y_px;
disp(['Image distortion based on x-scale to y-scale ratio: ', num2str(x_scale/y_scale)]);
xy_scale = (x_scale+y_scale)/2;
xy_offset= [x(3), y(3)];
end
