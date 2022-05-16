% Adjusted D Hertwig  20 June 2019
% Modified Desmond Lim 19 Dec 2019 -> for unscaled raw PLIF image
% Modified Desmond Lim 13 Jan 2022 -> for smooth-wall TBL expts

function ProcessDyeCal_Step04_CorrectAttenuation(mainfolder,save_folder,folder_calib,y0,x0,epsilon)


close all

% Choose datasets to look at and specify concentration
% save_folder = '..\Matlab_Output(Processed)\P3_PLIF\';
list(1).foldername = 'C-Calib_dyecal05'; C(1) = 0.05;
list(2).foldername = 'C-Calib_dyecal03'; C(2) = 0.03;
list(3).foldername = 'C-Calib_dyecal00'; C(3) = 0.00;   %%%% Background must always be the last one.

% Laser origin.
load([save_folder, 'OriginXY.mat'],'OriginX','OriginY')

% attenuation factor
%epsilon = 31; % 31 for P3;  % 43 for P2  % 35.5 for P1.   % 13.242; % 110; % 4 m-1 (mg/L)-1
save([save_folder,  'epsilon', '.mat'],'epsilon')

% Correct the frame for attenuation
for i = 1:length(list)-1
    
    % Load Result
    load([save_folder, list(i).foldername, 'X.mat'],'DyeCalFrame','X','Y')

    % Display
    figure(1); clf(1); figure(1);
    imagesc(X,Y,DyeCalFrame'); colorbar
    caxis([0 max(DyeCalFrame(:))]);
    set(gca,'YDir','normal')
    pause(3)

    % Trace Rays
    R = OriginY;
    hold on;
    for theta = -20:20
        h = line([OriginX OriginX+R*sind(theta)],[OriginY OriginY-R*cosd(theta)]);
        set(h,'Color','k','LineStyle','--');
    end
    axis equal
    axis([min(X) max(X) min(Y) max(Y)])
    pause(3)

    % Determine path length through the tank
    TankH = 300;
    [X3,Y3] = meshgrid(X,Y);
    Delta_y = TankH - Y3;
    Delta_x = (TankH-Y3)./(OriginY-Y3) .* (OriginX-X3);
    Delta_r = sqrt(Delta_x.^2 + Delta_y.^2) + 10; %%%%%%%%%%%%%%%%%%%%%%%%%%% + 10 here to account for z-axis attenuation.?

    % Correct the tank image for attenuation
    CorrectedDyeCal = DyeCalFrame ./ exp(-Delta_r' * C(i) * epsilon/1000);

    % Display
    figure(2); clf(2); figure(2);
    imagesc(X,Y,CorrectedDyeCal'); colorbar
    caxis([0 max(DyeCalFrame(:))]);
    set(gca,'YDir','normal')
    axis equal tight
    pause(3)
    
    % rename files
    OldDyeCalFrame = DyeCalFrame;
    DyeCalFrame = CorrectedDyeCal;
    
    % Save Result
    %export_fig([mainfolder, 'DyeCal\', list(i).foldername, 'corr', num2str(epsilon),'.png'],'-png')
    print([save_folder, list(i).foldername, 'corr', num2str(epsilon), '.png'],'-dpng')
    pause(4)
    save([save_folder,  list(i).foldername, 'corr', num2str(epsilon), '.mat'],'OldDyeCalFrame','X','Y','DyeCalFrame')

end

close all;

%% Check the result
load([save_folder,  list(1).foldername, 'corr', num2str(epsilon), '.mat'])
CorrectedDyeCal1 = DyeCalFrame; DyeCal1 = OldDyeCalFrame;
load([save_folder,  list(2).foldername, 'corr', num2str(epsilon), '.mat'])
CorrectedDyeCal2 = DyeCalFrame; DyeCal2 = OldDyeCalFrame;
load([save_folder,  list(3).foldername, '.mat'],'DyeCalFrame','X','Y')
Background = DyeCalFrame;

figure(1); clf(1); figure(1);
imagesc(X,Y,((CorrectedDyeCal1)./(CorrectedDyeCal2) - C(1)/C(2))); colorbar%undetied code is below, background shouldnt be removed?
%imagesc(X,Y,((CorrectedDyeCal1' - Background')./(CorrectedDyeCal2' - Background') - C(1)/C(2))); colorbar
set(gca,'YDir','normal')
caxis([-2 2])
axis equal tight
%colormap(redblue)
% pause(3)
print([save_folder,'CorrDyeCal.png'],'-dpng')
% pause(2)

%% Plot a sample profile using 1 laser line at near theta=0.
xi = find(X>OriginX,1,'first');
yi = 1:find(Y<5,1,'first');
r_t = Delta_r(yi,xi);
C_t1 = DyeCal1(xi,yi)';
C_p1 = CorrectedDyeCal1(xi,yi)'; 
C_t2 = DyeCal2(xi,yi)';
C_p2 = CorrectedDyeCal2(xi,yi)'; 

figure(2); clf(2); figure(2); 
plot(r_t,C_t1,'b-',r_t,C_p1,'r-'); hold on;
plot(r_t,C_t2,'b--',r_t,C_p2,'r--');
xlabel('\Delta r') % Note that 0 is defined at the start of the calibration tank.
ylabel('Dye cal values')
title('Sample profile of 1 laser line');
legend('Solid uncorrected C=0.05', 'Solid corrected C=0.05','Dashed uncorrected C=0.03', 'Dashed corrected C=0.03');
% pause(3)
print([save_folder,'CorrDyeCal_deltar.png'],'-dpng')
% pause(2)

%% Plot theta-averaged profiles over sample line by binning delta_r with resolution of bin_res=1.
hold on
bin_res=0.5;
bin_ = discretize(Delta_r, min(min(Delta_r)):bin_res:max(max(Delta_r)));
DyeCal1_thetaAvg=0;
DyeCal2_thetaAvg=0;

for ii=min(min(bin_)):max(max(bin_))
    indx=find(bin_==ii);
    tmp = DyeCal1';
    CC_t1(ii) = mean(tmp(indx));
    tmp = CorrectedDyeCal1';
    CC_p1(ii) = mean(tmp(indx));
    tmp = DyeCal2';
    CC_t2(ii) = mean(tmp(indx));
    tmp = CorrectedDyeCal2';
    CC_p2(ii) = mean(tmp(indx));
    RR_t(ii)  = mean(Delta_r(indx));
end

% figure(3); clf(3); figure(3); 
plot(RR_t,CC_t1','k-',RR_t,CC_p1,'k-'); hold on;
plot(RR_t,CC_t2,'k--',RR_t,CC_p2,'k--');
xlabel('\Delta r')
ylabel('Theta-averaged Dye cal values')
title('Sample profile of theta-averaged laser line (black)');
legend('Solid uncorrected C=0.05', 'Solid corrected C=0.05','Dashed uncorrected C=0.03', 'Dashed corrected C=0.03');
% pause(3)
print([save_folder,'ThetaAvgCorrDyeCal_deltar.png'],'-dpng')
% pause(2)

%% Plot CoorDyeCal ratio based on sample line.
figure(4); clf(4); figure(4);
plot((C_p1)./(C_p2))
grid on; hold on
plot([300 2000],[C(1)/C(2) C(1)/C(2)],'k')
xlabel('y-axis pixels')
ylabel('Ratio')
xlim([300 2000])
ylim([1.5 1.8])
title('CoorDyeCal ratio based on sample line');
% pause(3)
print([save_folder,'CorrDyeCal_ratio.png'],'-dpng')
% pause(2)

%% Plot CoorDyeCal ratio based on theta-averaged values.
figure(5); clf(5); figure(5);
plot(RR_t,(CC_p1')./(CC_p2'))
grid on; hold on
plot([180 320],[C(1)/C(2) C(1)/C(2)],'k')
xlabel('\Delta r')
ylabel('Ratio')
xlim([170 300])
ylim([1.5 1.8])
title('CoorDyeCal ratio based on theta-averaged line');
% pause(3)
print([save_folder,'ThetaAvg_CorrDyeCal_ratio.png'],'-dpng')
% pause(2)

end
