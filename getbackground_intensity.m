%% Function to get background intensity factor
    function background_intensity=getbackground_intensity(i, folder_PLIF)
    A = readimx([folder_PLIF,'B',num2str(i,'%05d'),'.im7']);
    D = A.Frames{end}.Components{1}.Planes{:} * ...
        A.Frames{end}.Components{1}.Scale.Slope + ...
        A.Frames{end}.Components{1}.Scale.Offset;
    nx = size(D,1);
    ny = size(D,2);
%     X = (double(1:nx)-xy_offset1(1))  * xy_scale1;
%     Y = (double(1:ny)-xy_offset1(2))  * xy_scale1;
    
    E = D(int16(1*(nx/8)):int16(7*(nx/8)),int16(1*(ny/8)):int16(2*(ny/8)));
    %D(int16(1*(nx/8)):int16(7*(nx/8)),int16(1*(ny/8)):int16(2*(ny/8))) = D(int16(1*(nx/8)):int16(7*(nx/8)),int16(1*(ny/8)):int16(2*(ny/8)))*3;
    %imagesc(D);      %These two lines are for checking the area used for
    %intensity calculations
    background_intensity = mean(E,'all');
    
    end