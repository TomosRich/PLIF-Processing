%% PLIF post-processing:  Concentration statistics - MEAN and instantaneous.
% HG Nov 2018
% Modified by D Hertwig Dec 2018
% Modified by D Lim     Dec 2020  to process scaled and unscaled PLIF data.
% Modified by D Lim     Mar 2021  option to save instantaneous PLIF data. Code shortened by adding a getPLIF function.
% Modified by D Lim     Jan 2022  for smooth-wall TBL data.
% clear 
% close all
% clc
function PLIF_process_stats_DL_22Jan2022(mainfolder,save_folder,folder_calib,folder_PLIF,y0,x0,runname,save_inst,snaps,Cs,use_complex_background)


% runname = '2D_P1_Cs_1';
% save_folder='..\Matlab_Output(Processed)\P1_PLIF\';
%D:\Lab_Volatile__Half_Processed__Tall Building\Matlab_Output(Processed)\P2_PLIF\
%..\Matlab_Output(Processed)\P2_PLIF\
if ~exist(save_folder, 'dir')
    mkdir(save_folder)
end
% save_inst='no';
% snaps = 2000;
%background_snaps = 10;%values to use to create background = snaps/background_snaps
%Cs = 1; % Use 1 for everything. We dont normalise the concentrations yet. 

% folder_PLIF = '..\P1\LIF_5\'; %P3 LIF_4, P2 LIF_14, P1 LIF_5

% Load in CAL file. CHECK THIS IS THE RIGHT ONE!
% folder_calib = '..\Matlab_Output(Processed)\P1_PLIF\';
folder_calib = save_folder;
load([folder_calib 'C-Calib_dyecal.mat'],'B', 'Acal');
load([folder_calib, 'geometricScale.mat'],'xy_scale1','xy_offset1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Check line 122 to ensure the attribute is the energy monitor data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Manual offset in mm (to set dye source as origin).  
% P1: x0=84.91, P2: x0+198.8mm, % P3: P2+199.3mm.
% y0 = -134.7320 + 1.25; % for P1 = -134.7320 - 1.25, P2 = -134.7320 - 4.2, P3 = -134.7320 + 0.5
% x0 = 53.3733+150; % need big positive here   84.91+198.8+199.3;     53.3733

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{

if ~exist([save_folder,  '0_complex_background', '.mat'], 'file')

    B = complex_background(folder_PLIF, B, Cs, xy_scale1,xy_offset1, x0, y0,snaps,background_snaps,save_folder);
else
    load([save_folder, '0_complex_background.mat']);
end

if use_complex_background == 1;
    B = flipud(B);
else

end
%}

%B = flipud(B);
%% PLIF mean values.
AvgC = 0;
VarC = 0;

if ~exist([save_folder, runname, '_PLIFstats.mat'], 'file')
    for i=1:snaps    
        %disp([1,i]);                 %line displaying progress
        PLIF=getPLIF(i, folder_PLIF, B, Acal, Cs, xy_scale1,xy_offset1, x0, y0,use_complex_background, save_folder);
        AvgC = AvgC + PLIF.C;
    end

    AC.meanC = AvgC./snaps;
    % AC.meanC=AC.meanC(AC.Y>0); % This might be useful if AC.meanC has already truncate away values that are below Y=0.
else
    load([save_folder, runname, '_PLIFstats.mat']);
end

%%  PLIF post-processing:  Concentration statistics - Variance
for i=1:snaps
    %disp([2,i]);
    PLIF=getPLIF(i, folder_PLIF, B, Acal, Cs, xy_scale1,xy_offset1, x0, y0,use_complex_background, save_folder);
    VarC = VarC + (PLIF.C - AC.meanC).^2.0;
      
    if strcmp(save_inst, 'yes')
        ACi.X=PLIF.X;
        ACi.Y=PLIF.Y;
        ACi.C=PLIF.C;
        ACi.cc=(PLIF.C - AC.meanC).^2.0;
        save([save_folder runname '_PLIF_' num2str(i) '.mat'], 'ACi')
        %{
        figure(1)
        load("..\Matlab_Output(Processed)\P3_PLIF\C-Calibration_C=0.00.mat");
        K = imrotate(DyeCalFrame,90);
        imagesc(K);
        colorbar;
        axis equal tight;
        set(gca,'YDir','normal');
        imcontrast(gca);
        
        figure(2)
        load("..\Matlab_Output(Processed)\P3_PLIF\2D_P3_Cs_60_PLIF_7.mat");
        J = imrotate(ACi.C,90);
        imagesc(J);
        colorbar;
        axis equal tight;
        set(gca,'YDir','normal');
        imcontrast(gca);
        %}
    end
end

AC.varC = VarC./(snaps - 1);
AC.X = PLIF.X;
AC.Y = PLIF.Y;

save([save_folder runname '_PLIFstats.mat'], 'AC')

%% Plot and export figures.

% figure(1); clf(1); figure(1);
% imagesc(ACi.X,ACi.Y,log10(ACi.C')); 
% colorbar
% axis equal tight
% set(gca,'YDir','normal')
% % caxis([-2 0])
% ylim([0 135])
% colormap jet
% % % print([runname '_Cmean'],'-dpng')
% % % pause(5)

figure(1); clf(1); figure(1);
%imagesc(AC.X,AC.Y,(log10(AC.meanC'))); %normally log
imagesc(AC.X,AC.Y,(AC.meanC'));
colorbar
axis equal tight
set(gca,'YDir','normal')
 %caxis([-2 0])
ylim([-31 135])
%colormap jet
% print([runname '_Cmean'],'-dpng')
% % pause(5)

figure(2); clf(2); figure(2);
imagesc(AC.X,AC.Y,log10(AC.varC')); 
colorbar
axis equal tight
set(gca,'YDir','normal')
% caxis([-2 0])
ylim([0 135])
%colormap jet
% % print([runname '_Cvar'],'-dpng')
% % pause(5)


end

%% Function to aquire complex background for subtraction
%{
function B = complex_background(i, folder_PLIF, B, Acal, Cs, xy_scale1, xy_offset1, x0, y0,snaps,background_snaps,save_folder)

    %arr = zeros(2560,2160,snaps);
    arraysize = int8(snaps/background_snaps);
    snaps_data_stack = zeros(2560,2160,arraysize);

    for i = 4:background_snaps:(snaps-1)

        A = readimx([folder_PLIF,'B',num2str(i,'%05d'),'.im7']);
        D = A.Frames{end}.Components{1}.Planes{:} * ...
        A.Frames{end}.Components{1}.Scale.Slope + ...
        A.Frames{end}.Components{1}.Scale.Offset;
        nx = size(D,1);
        ny = size(D,2);
        X = (double(1:nx)-xy_offset1(1))  * xy_scale1;
        Y = (double(1:ny)-xy_offset1(2))  * xy_scale1;
    
    % Shift axes
        X = X + x0;
        Y = -(Y + y0);

        EnergyMonitor_1 = mean(2000-A.Attributes{12,1}.Value)/2000;
        A.Attributes{12,1}.Value;


        %D=flipud(D);           % Flip C in streamwise direction (it was flipped in calibration post-processing as well).
        location = int8(i/4);
        %arr = cat(3,arr,D{:,:})
        snaps_data_stack(:,:,location) = D(:,:);
        %disp(D)
        
    end
    snaps_data_stack(:, :, end) = [];     
    B = min(snaps_data_stack,[],3)*1.5;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   check 5
    save([save_folder,  '0_complex_background', '.mat'], 'B', 'X', 'Y'  )
    clear snaps_data_stack
    %disp(B)
end
%}

%% Function to get instantaneous PLIF velocity
function PLIF=getPLIF(i, folder_PLIF, B, Acal, Cs, xy_scale1, xy_offset1, x0, y0,use_complex_background, save_folder)
    A = readimx([folder_PLIF,'B',num2str(i,'%05d'),'.im7']);
    D = A.Frames{end}.Components{1}.Planes{:} * ...
        A.Frames{end}.Components{1}.Scale.Slope + ...
        A.Frames{end}.Components{1}.Scale.Offset;
    nx = size(D,1);
    ny = size(D,2);
    X = (double(1:nx)-xy_offset1(1))  * xy_scale1;
    Y = (double(1:ny)-xy_offset1(2))  * xy_scale1;
    
    % Shift axes
    X = X + x0;
    Y = -(Y + y0);

    EnergyMonitor_1 = mean(2000-A.Attributes{12,1}.Value)/2000;
    A.Attributes{12,1}.Value;
%     EnergyMonitor_1 = 2000+A.Attributes{13,1}.Value; % Use 13 for calibration.
%     A.Attributes{13,1}.Value
    
    % Apply Dye Calibration

    % Added section for background subtraction
    %zero = load('..\Matlab_Output(Processed)\P2_PLIF\C-Calibration_C=0.00.mat'); % Check this is correct
    %zero=zero.DyeCalFrame;
    

    D=flipud(D);           % Flip C in streamwise direction (it was flipped in calibration post-processing as well).
    %D = double(D)-zero;


    if use_complex_background == 1;


        B = B;

        else
        B = flipud(B);

    end

    load([save_folder, 'zeropoint_intensity_value.mat']);
    load([save_folder, 'background_intensity_curve.mat']);
    intensity_curve_i = background_intensity_curve(i);
    thoroughness_factor = 1.03;
    background_multiplier = (intensity_curve_i/zeropoint_intensity_value); % intensity_curve_i/zeropoint_intensity_value;
    background_multiplier = max([background_multiplier, 1]);
    Big_background = B*background_multiplier*thoroughness_factor;
%     if use_scaling_background == 1;
% 
%         Big_background = B*background_multiplier*thoroughness_factor;
% 
%     else
% 
%         Big_background = B*thoroughness_factor;
% 
%     end

    Big_background = flipud(Big_background);

    C = ((double(D)/EnergyMonitor_1) - Big_background) .* Acal; % pretty confident background needs flipud
    C = flipud(C);         % Now we flip it back.... Yea I know... -_-!
    
    % Normalise by source concentration
    C = C / Cs;
    
    % threshold out anything less than zero
    threshold = 0;
    C(C<threshold)=0;

    % Remove data below y=0
    %C = C(:,Y>0);
    %Y = Y(Y>0);
    
    %%%DO the cutting at the end when its all sorted
    %%%now we need to shift them again due to the offset used in the PIV files
%     xx= X<131.9;
%     yy=Y<133.9;
%     X=X(xx); % use to cut D down
%     Y=Y(yy); % use to cut D down
%     D=D(xx,yy); % cut down d
%     C=C(xx,yy);
    PLIF.X=X;
    PLIF.Y=Y;
    PLIF.D=D;
    PLIF.C=C;
end



