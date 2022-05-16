% Adjusted D Hertwig  20 June 2019
% Modified Desmond Lim 19 Dec 2019 -> for unscaled raw PLIF image
% Modified Desmond Lim 13 Jan 2022 -> for smooth-wall TBL expts

function ProcessDyeCal_Step05_MakeFinalDyeCalFiles(mainfolder,save_folder,folder_calib,folder_PLIF,y0,x0,snaps,Cs)

close all


% Choose datasets to look at and specify concentration
% save_folder = '..\Matlab_Output(Processed)\P1_PLIF\';

load([save_folder,  'epsilon', '.mat'],'epsilon')
list(1).foldername = ['C-Calib_dyecal05', 'corr', num2str(epsilon)]; C(1) = 0.05;
list(2).foldername = ['C-Calib_dyecal03', 'corr', num2str(epsilon)]; C(2) = 0.03;
list(3).foldername = 'C-Calib_dyecal00'; C(3) = 0.00;   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load files
load([save_folder,  list(1).foldername, '.mat'],'DyeCalFrame','X','Y')
A1 = DyeCalFrame;

load([save_folder,  list(2).foldername, '.mat'],'DyeCalFrame','X','Y')
A2 = DyeCalFrame;

load([save_folder,  list(3).foldername, '.mat'],'DyeCalFrame','X','Y')
B = DyeCalFrame;

%save_folder='..\Matlab_Output(Processed)\P1_PLIF\';
% snaps = 2000;load([save_folder,  'C-Calib_dyecal00', '.mat'],'DyeCalFrame','X','Y')

% folder_PLIF = '..\P1\LIF_5\';

%folder_calib = save_folder;
load([save_folder, 'geometricScale.mat'],'xy_scale1','xy_offset1');


    
load([save_folder 'C-Calib_dyecal00.mat'],'DyeCalFrame');
B = DyeCalFrame;



% y0 = -134.7320 - 1.25; % for P1 = -134.7320 - 1.25, P2 = -134.7320 - 4.2, P3 = -134.7320 + 0.5
% x0 = 53.3733+150; % need big positive here   84.91+198.8+199.3;     53.3733




load([save_folder,  list(3).foldername, '.mat'],'DyeCalFrame','X','Y')
%B = DyeCalFrame;



% Determine the calibration coefficient
Acal1 = C(1) ./ (A1 - B);
Acal2 = C(2) ./ (A2 - B);
Acal = (Acal1 + Acal2) ./2;
Adiff = (Acal1 - Acal2) ./ Acal;

% Display
figure(1); clf(1); figure(1);
ax1 = subplot(2,2,1); imagesc(X,Y,Acal1'); colorbar; caxis([0 0.05]); set(gca,'YDir','normal'); title('Tank 1'); axis equal tight
ax2 = subplot(2,2,2); imagesc(X,Y,Acal2'); colorbar; caxis([0 0.05]); set(gca,'YDir','normal'); title('Tank 2'); axis equal tight
ax3 = subplot(2,2,3); imagesc(X,Y,Acal'); colorbar; caxis([0 0.05]); set(gca,'YDir','normal'); title('Average'); axis equal tight
ax4 = subplot(2,2,4); imagesc(X,Y,Adiff'*100); colorbar; caxis([-50 50]); set(gca,'YDir','normal'); title('% Diff'); axis equal tight
%colormap(ax1,parula); colormap(ax2,parula); colormap(ax3,parula); colormap(ax4,redblue)
% pause(3)

% save
print([save_folder,  list(1).foldername(1:14), '.png'],'-dpng')
% pause(4)
%export_fig([mainfolder, 'DyeCal\',  list(1).foldername(1:13), '.png'])
save([save_folder,  list(1).foldername(1:14), '.mat'], 'B', 'Acal', 'Adiff', 'X', 'Y')

end
