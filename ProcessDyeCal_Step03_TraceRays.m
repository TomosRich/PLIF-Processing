% Adjusted D Hertwig  20 June 2019
% Modified Desmond Lim 19 Dec 2019 -> for unscaled raw PLIF image
% Modified Desmond Lim 13 Jan 2022 -> for smooth-wall TBL expts

function ProcessDyeCal_Step03_TraceRays(mainfolder,save_folder,folder_calib,y0,x0)


% Choose dataset to look at and specify concentration
% save_folder = '..\Matlab_Output(Processed)\P3_PLIF\';
list(1).foldername = 'C-Calib_dyecal05'; C(1) = 0.05;
list(2).foldername = 'C-Calib_dyecal03'; C(2) = 0.03;

y_extra=20; % y<y_extra to extrapolate near-wall data. ; 40 P1, 20, P2,P3
y_high_end=130; % height of tape on tanks

%% Find laser origin. Use data from both concentration to find a common pt.
num_lines = 4;
Amat = zeros(num_lines*2, 2);
Bmat = zeros(num_lines*2, 1);
for ii=1:2
    load([save_folder,  list(ii).foldername, '.mat'],'DyeCalFrame','X','Y')
    [OriginX, OriginY, A, B]=getLaserOrigin(DyeCalFrame, X, Y, num_lines);
    Amat((num_lines*ii-3):num_lines*ii,:)=A;
    Bmat(num_lines*ii-3:num_lines*ii)=B;
    disp([list(ii).foldername, ': ', 'X=', num2str(OriginX), ', Y=', num2str(OriginY)]);
end
tmp=Amat\Bmat;
OriginX=tmp(1);
OriginY=tmp(2);
disp(['Both concentrations for common laser origin', ': ', 'X=', num2str(OriginX), ', Y=', num2str(OriginY)]);
save([save_folder, 'OriginXY.mat'],'OriginX','OriginY')

%% Trace Rays and Extrapolate to replace near wall data
for i = 1:2
    list(i).foldername
    
    % Load Result
    load([save_folder,  list(i).foldername, '.mat'],'DyeCalFrame','X','Y')

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
    Delta_r = sqrt(Delta_x.^2 + Delta_y.^2);
    
    % Extrapolate data to replace the near wall bad data
    DyeCalFrame(:,find(Y<y_extra,1):end) = NaN;  % was y_extra<8
    DyeCalFrame(:,1:max(find((Y>y_high_end)))) = NaN;
    %DyeCalFrame(1:find(X>110,1),find(Y<55,1):find(Y<35,1)) = NaN; %                  only for use at P1
    %DyeCalFrame(find(X>175,1):end,find(Y<37,1):find(Y<25,1)) = NaN;

    %last two lines here can be used to crop out sections of unusable
    %calibration data, due to lights on tank and such, if you want to see
    %where they are then set to a number not NaN, adjust to where they are
    %needed

    for theta = -10:.02:5 % was 0.2,8 for P1, 0.2,7 for P2, 0.2,5 for P3, this line affects the angle the interpolation acts over, emasured from the laser head
        end   
        
        R2 = OriginY+(-150:.01:y_extra);
        xi= [OriginX+R2*sind(theta)];
        yi= [OriginY-R2*cosd(theta)];
        [X3,Y3] = meshgrid(X,Y);
        ci = interp2(X3,Y3,DyeCalFrame',xi,yi);
        P = polyfit(R2(~isnan(ci)),ci(~isnan(ci)),2);
        ci(isnan(ci)) = polyval(P,R2(isnan(ci)));
        for index = find(yi<y_extra)
            xtemp = find(X >= xi(index),1);
            ytemp = find(Y <= yi(index),1);
            DyeCalFrame(xtemp+(0:2),ytemp) = ci(index);%this line is behaving weird 31/03, changed from -1:1 to 0:2
        end   
    end
    DyeCalFrame = inpaintn(DyeCalFrame); % use inpaintn to fill in the rest

    % Display
    figure(1); clf(1); figure(1);
    imagesc(X,Y,DyeCalFrame'); colorbar
    caxis([0 max(DyeCalFrame(:))]);
    set(gca,'YDir','normal')
    axis equal tight
    pause(3)
    
    % Save result
    %export_fig(['DyeCal\',  list(i).foldername, 'X.png'],'-png')
    %print([save_folder, list(i).foldername,'X.png'],'-dpng')
    %pause(4)
    save([save_folder,  list(i).foldername, 'X.mat'],'DyeCalFrame','X','Y')
end

%% Function to get origin.
function [OriginX, OriginY, Amat, Bmat]=getLaserOrigin(DyeCalFrame, X, Y, num_lines)

coeff = zeros(num_lines,2);

% Select prominent lines to trace them to the laser head origin.
figure(1); clf(1); figure(1);
imagesc(X,Y,DyeCalFrame'); colorbar
caxis([0 max(DyeCalFrame(:))]);
set(gca,'YDir','normal')
imcontrast(gca)
hold on

for iii=1:num_lines
    waitfor(msgbox(['Select 5 points on the same line']))
    [x, y]=ginput(5);
    plot(x,y,'ro')
    coeff(iii,:) = polyfit(x,y,1);
    yy=0:1:max(Y);
    line((yy-coeff(iii,2))/coeff(iii,1),yy);
end
close all

Amat = [coeff(:,1), -1*ones(size(coeff(:,1)))];
Bmat = -coeff(:,2);
tmp=Amat\Bmat;
OriginX=tmp(1);
OriginY=tmp(2);

figure(1); clf(1); figure(1);
imagesc(X,Y,DyeCalFrame'); colorbar
caxis([0 max(DyeCalFrame(:))]);
set(gca,'YDir','normal')
hold on
yy=0:1:OriginY;
for iiii=1:num_lines
    line((yy-coeff(iiii,2))/coeff(iiii,1),yy);
end
ylim([-10 600])
hold off
waitfor(msgbox('Check and make sure all lines converge to roughly the same spot!'))

end

