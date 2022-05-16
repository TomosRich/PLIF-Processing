
function B = complex_background(folder_PLIF, B, Cs, xy_scale1, xy_offset1, x0, y0,snaps,background_snaps,save_folder)

    use_proportion_of_data = 1; %This fraction
    array_division = background_snaps;
    stack_length = (array_division/use_proportion_of_data);
    %arr = zeros(2560,2160,snaps);
    arraysize = (snaps/background_snaps)-1;
    %snaps_data_stack = zeros(2560,2160,arraysize);

    stack = zeros(2560,2160,stack_length);
    j = -(snaps/array_division);

    use_proportion_of_data = 4; %This fraction
    
    for four = 1:stack_length
        j = j + (snaps/array_division);
        snaps_data_stack = zeros(2560,2160,arraysize);
        storage_count = 1;
        for i = 1:arraysize
            i = i + j;
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
            location = storage_count;
        %arr = cat(3,arr,D{:,:})
            snaps_data_stack(:,:,location) = D(:,:);
        %disp(D)
            storage_count = storage_count + 1;
        end
        snaps_data_stack(:, :, end) = [];
        %snaps_data_stack = squeeze(snaps_data_stack);
        snaps_data_stack = min(snaps_data_stack,[],3);
        snaps_data_stack = squeeze(snaps_data_stack);
        stack(:,:,four) = min(snaps_data_stack,[],3);
        clear snaps_data_stack
        
    end
  
    B = min(stack,[],3);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   check 5
    save([save_folder,  '0_complex_background', '.mat'], 'B', 'X', 'Y'  )
    %disp(B)
end
%{
save_folder='..\Matlab_Output(Processed)\P1_PLIF\';
snaps = 2000;
background_snaps = 4;
folder_PLIF = '..\P1\LIF_5\';

folder_calib = '..\Matlab_Output(Processed)\P1_PLIF\';
load([folder_calib 'C-Calib_dyecal.mat'],'B', 'Acal');
load([folder_calib, 'geometricScale.mat'],'xy_scale1','xy_offset1');

y0 = -134.7320 - 1.25; % for P1 = -134.7320 - 1.25, P2 = -134.7320 - 4.2, P3 = -134.7320 + 0.5
x0 = 53.3733+150; % need big positive here   84.91+198.8+199.3;     53.3733

B = complex_background(i, folder_PLIF, B, Acal, Cs, xy_scale1,xy_offset1, x0, y0,snaps,background_snaps,save_folder);
%}
