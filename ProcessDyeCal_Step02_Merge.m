% Adjusted D Hertwig  20 Jun 2019
% Modified Desmond Lim 19 Dec 2019 -> for unscaled raw PLIF image
% Modified Desmond Lim 13 Jan 2022 -> for smooth-wall TBL expts

function ProcessDyeCal_Step02_Merge(mainfolder,save_folder,folder_calib,y0,x0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Known concentration #2
clear list
list(1).foldername = 'C-Calibration_C=5.00';
list(2).foldername = 'C-Calibration_C=5.00_01';
list(3).foldername = 'C-Calibration_C=5.00_02';

% Merge Data sets
load([save_folder, list(1).foldername, '.mat'],'DyeCalFrame','X','Y')
DyeCal = zeros(size(DyeCalFrame));
for i = 1:length(list)

    load([save_folder,  list(i).foldername, '.mat'],'DyeCalFrame')
    
    % If there is a bad region of the image replace it with zeros    
    %if i==3
    %    DyeCalFrame(1:find(X<-100,1,'last'),:) = 0;
    %end
    DyeCal = max(cat(3,DyeCal,DyeCalFrame),[],3);
end

% % This step now done in step 3
% DyeCal(:,find(Y<8.5,1):end) = NaN;
% DyeCal = inpaintn(DyeCal);

% Display
figure(1); clf(1); figure(1);
imagesc(X,Y,DyeCal'); colorbar
caxis([0 max(DyeCal(:))]);
set(gca,'YDir','normal')
axis equal tight
set(gca,'Color','w')

% rename variable
DyeCalFrame = DyeCal;

% Save Result
print([save_folder, list(i).foldername(1:7),'_dyecal0',list(i).foldername(17),'.png'],'-dpng')
pause(4)
%export_fig([mainfolder, 'DyeCal\', list(1).foldername(1:15), list(1).foldername(28:end),'.png'],'-png')
save([save_folder, list(i).foldername(1:7),'_dyecal0',list(i).foldername(17),'.mat'],'DyeCalFrame','X','Y')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Known concentration #1
clear list
list(1).foldername = 'C-Calibration_C=3.00';
list(2).foldername = 'C-Calibration_C=3.00_01';
list(3).foldername = 'C-Calibration_C=3.00_02';

% Merge Data sets
load([save_folder, list(1).foldername, '.mat'],'DyeCalFrame','X','Y')
DyeCal = zeros(size(DyeCalFrame));
for i = 1:length(list)

    load([save_folder,  list(i).foldername, '.mat'],'DyeCalFrame')
    
    % If there is a bad region of the image replace it with zeros
%     if i==1
%         DyeCalFrame(1:find(X<-118,1,'last'),:) = 0;
%     end
    %DyeCalFrame(:,1:find(Y>130,1,'last'))=0;
    DyeCal = max(cat(3,DyeCal,DyeCalFrame),[],3);
end

% Extrapolate data to replace the near wall bad data
% DyeCal(:,find(Y<9.5,1):end) = NaN;
% DyeCal = inpaintn(DyeCal);

% Display
figure(1); clf(1); figure(1);
imagesc(X,Y,DyeCal'); colorbar
caxis([0 max(DyeCal(:))]);
set(gca,'YDir','normal')
axis equal tight
set(gca,'Color','w')

% rename variable
DyeCalFrame = DyeCal;

% Save Result
print([save_folder, list(i).foldername(1:7),'_dyecal0',list(i).foldername(17),'.png'],'-dpng')
pause(4)
%export_fig([mainfolder, 'DyeCal\', list(1).foldername(1:15), list(1).foldername(28:end),'.png'],'-png')
save([save_folder, list(i).foldername(1:7),'_dyecal0',list(i).foldername(17),'.mat'],'DyeCalFrame','X','Y')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Known concentration background
clear list
list(1).foldername = 'C-Calibration_C=0.00';
% list(2).foldername = 'C-Calibration_C=0.00_01';
% list(3).foldername = 'C-Calibration_C=0.00_02';

% Merge Data sets
load([save_folder, list(1).foldername, '.mat'],'DyeCalFrame','X','Y')
DyeCal = zeros(size(DyeCalFrame));
for i = 1:length(list)

    load([save_folder,  list(i).foldername, '.mat'],'DyeCalFrame')
    
    % If there is a bad region of the image replace it with zeros
%     if i==1
%         DyeCalFrame(1:find(X<-118,1,'last'),:) = 0;
%     end
%     DyeCalFrame(:,1:find(Y>130,1,'last'))=0;
    DyeCal = max(cat(3,DyeCal,DyeCalFrame),[],3);
end

% Extrapolate data to replace the near wall bad data
% DyeCal(:,find(Y<3,1):end) = NaN;
% DyeCal = inpaintn(DyeCal);

% Display
figure(1); clf(1); figure(1);
imagesc(X,Y,DyeCal'); colorbar
caxis([0 max(DyeCal(:))]);
set(gca,'YDir','normal')
axis equal tight
set(gca,'Color','w')

% rename variable
DyeCalFrame = DyeCal;

% Save Result
print([save_folder, list(i).foldername(1:7),'_dyecal0',list(i).foldername(17),'.png'],'-dpng')
pause(4)
%export_fig([mainfolder, 'DyeCal\', list(1).foldername(1:15), list(1).foldername(28:end),'.png'],'-png')
save([save_folder, list(i).foldername(1:7),'_dyecal0',list(i).foldername(17),'.mat'],'DyeCalFrame','X','Y')

end

