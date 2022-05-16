%% PLIF post-processing:  Concentration statistics - MEAN and instantaneous.
% HG Nov 2018
% Modified by D Hertwig Dec 2018
% Modified by D Lim     Dec 2020  to process scaled and unscaled PLIF data.
% Modified by D Lim     Mar 2021  option to save instantaneous PLIF data. Code shortened by adding a getPLIF function.
% Modified by D Lim     Jan 2022  for smooth-wall TBL data.
% clear 
% close all
% clc
function Background_intensity_gradient(mainfolder,save_folder,folder_calib,folder_PLIF,y0,x0,snaps,runname)


% runname = '2D_P1_Cs_1';
% save_folder='..\Matlab_Output(Processed)\P1_PLIF\';
%D:\Lab_Volatile__Half_Processed__Tall Building\Matlab_Output(Processed)\P2_PLIF\
%..\Matlab_Output(Processed)\P2_PLIF\
intensity_gradient = zeros(1,snaps);

A = load([save_folder,  'C-Calib_dyecal00', '.mat'],'DyeCalFrame','X','Y');
D = A.DyeCalFrame;
% D = A.Frames{end}.Components{1}.Planes{:} * ...
%     A.Frames{end}.Components{1}.Scale.Slope + ...
%     A.Frames{end}.Components{1}.Scale.Offset;
nx = size(D,1);
ny = size(D,2);
% X = (double(1:nx)-xy_offset1(1))  * xy_scale1;
% Y = (double(1:ny)-xy_offset1(2))  * xy_scale1;
    
    %D(int16(1*(nx/8)):int16(7*(nx/8)),int16(1*(ny/8)):int16(2*(ny/8))) = D(int16(1*(nx/8)):int16(7*(nx/8)),int16(1*(ny/8)):int16(2*(ny/8)))*3;
    %imagesc(D);      %These two lines are for checking the area used for
    %background intensity calcs

E = D(int16(1*(nx/8)):int16(7*(nx/8)),int16(1*(ny/8)):int16(2*(ny/8))); %this line selects section of image to use for background intensity

zeropoint_intensity_value = mean(E,'all');

for i=1:snaps
    %disp([2,i]);
    background_intensity=getbackground_intensity(i, folder_PLIF);
    intensity_gradient(i) = background_intensity;
end




figure(1); clf(1); figure(1);
vars = linspace(1,snaps,snaps);
%plot(intensity_gradient);
%hold on
plot(vars,intensity_gradient);
hold on
p = polyfit(vars,intensity_gradient,1);
background_intensity_curve = polyval(p,vars);
plot(background_intensity_curve);

save([save_folder, 'background_intensity_curve', '.mat'], 'background_intensity_curve');
save([save_folder, 'zeropoint_intensity_value', '.mat'], 'zeropoint_intensity_value');

xlabel('Image number') 
ylabel('Background Intensity Factor')
title(runname);

%print([save_folder,'Background Intensity Factor.png'],'-dpng')

% figure(2); clf(2); figure(2);
% 
% pxx = pwelch(intensity_gradient,snaps*0.1);
% 
% plot(pxx)

end


