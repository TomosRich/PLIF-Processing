
function ProcessDyeCal_Stitch_and_Print

figure(3); clf(3); figure(3);

clear
hold on
load("..\Matlab_Output(Processed)\P1_PLIF\2D_P1_Cs_1_PLIFstats.mat")
corrected = AC.meanC'*1;
imagesc(AC.X,AC.Y,log10(corrected)); 
colorbar
axis equal tight
set(gca,'YDir','normal')
caxis([-5 0])
ylim([0 135])

hold on
load("..\Matlab_Output(Processed)\P2_PLIF\2D_P2_Cs_40_PLIFstats.mat")
imagesc(AC.X,AC.Y,log10(AC.meanC')); 
colorbar
axis equal tight
set(gca,'YDir','normal')
% caxis([-2 0])
ylim([0 135])

hold on
load("..\Matlab_Output(Processed)\P3_PLIF\2D_P3_Cs_60_PLIFstats.mat")
imagesc(AC.X,AC.Y,log10(AC.meanC')); 
colorbar
axis equal tight
set(gca,'YDir','normal')
caxis([-6 -2])
ylim([0 135])

        figure(4)
        load("..\Matlab_Output(Processed)\P1_PLIF\C-Calibration_C=0.00.mat");
        K = imrotate(DyeCalFrame,90);
        imagesc(K);
        colorbar;
        axis equal tight;
        set(gca,'YDir','normal');
        imcontrast(gca);
        
        figure(5)
        load("..\Matlab_Output(Processed)\P3_PLIF\2D_P3_Cs_60_PLIF_120.mat");
        J = imrotate(ACi.C,90);
        imagesc((J));
        colorbar;
        colormap("hot")
        axis equal tight;
        set(gca,'YDir','normal');
        imcontrast(gca);

%{
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%background printing
figure(4); clf(4); figure(4);

hold on
load("..\Matlab_Output(Processed)\P1_PLIF\2D_P1_Cs_1_PLIFstats.mat")
load("..\Matlab_Output(Processed)\P1_PLIF\0_complex_background.mat")
imagesc(AC.X,AC.Y,log10(B')); 
colorbar
axis equal tight
set(gca,'YDir','normal')
% caxis([-2 0])
ylim([0 135])

hold on
load("..\Matlab_Output(Processed)\P2_PLIF\2D_P2_Cs_40_PLIFstats.mat")
load("..\Matlab_Output(Processed)\P2_PLIF\0_complex_background.mat")
imagesc(AC.X,AC.Y,log10(B')); 
colorbar
axis equal tight
set(gca,'YDir','normal')
% caxis([-2 0])
ylim([0 135])

hold on
load("..\Matlab_Output(Processed)\P3_PLIF\2D_P3_Cs_60_PLIFstats.mat")
load("..\Matlab_Output(Processed)\P3_PLIF\0_complex_background.mat")
imagesc(AC.X,AC.Y,log10(B')); 
colorbar
axis equal tight
set(gca,'YDir','normal')
%caxis([-6 -2])
ylim([0 135])


%background printing
figure(5); clf(5); figure(5);

clear
hold on
load("..\Matlab_Output(Processed)\P1_PLIF\C-Calib_dyecal.mat")
imagesc(X,Y,log10(Acal')); 
colorbar
axis equal tight
set(gca,'YDir','normal')
% caxis([-2 0])
ylim([0 135])

hold on
load("..\Matlab_Output(Processed)\P2_PLIF\C-Calib_dyecal.mat")
imagesc(X,Y,log10(Acal')); 
colorbar
axis equal tight
set(gca,'YDir','normal')
% caxis([-2 0])
ylim([0 135])

hold on
load("..\Matlab_Output(Processed)\P3_PLIF\C-Calib_dyecal.mat")
imagesc(X,Y,log10(Acal')); 
colorbar
axis equal tight
set(gca,'YDir','normal')
caxis([-6 -2])
ylim([0 135])

end
%}