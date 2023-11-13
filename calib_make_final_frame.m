function calib_make_final_frame(directories, concentrations, epsilon)
    % make_final_frame  Create plots of final calibration result
    %
    % syntax: make_final_frame(directories, concentrations, epsilon)
    %
    % Inputs:
    %   directories
    %   concentrations
    %   epsilon
    %
    % Ouputs:
    %   -
    %
    % Example:
    %   -
    %
    % See also: -
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: Processed .mat files from previous steps
    % Other files required: none
    %

    %   Modified T Rich 23/05/2023 -> added A_cal3 calculation

    fsep = filesep;
    concs = zeros(length(concentrations));
    concentration_files = {};

    for i = 1:length(concentrations)
        concs(i) = concentrations(i); % No need to change units here
        filename = strcat(directories.folder_save, fsep, 'C-Calib_dyecal', num2str(concentrations(i), '%02d'));

        if concentrations(i) > 0
            filename = strcat(filename, 'corr', num2str(epsilon));
        end

        concentration_files{i} = strcat(filename, '.mat');
    end

    A_frame1 = load(concentration_files{1}).dye_calib_frame;
    A_frame2 = load(concentration_files{2}).dye_calib_frame;
    background_frame = load(concentration_files{end}); % Always assume background is last in vector

    % Using background_frame to get the X and Y coordinates, as they're the same in all
    X = background_frame.X;
    Y = background_frame.Y;
    background_frame = background_frame.dye_calib_frame;

    % Determine the calibration coefficients and save to a .mat file
    A_cal1 = concs(1) ./ (A_frame1 - 0);%A_cal1 = concs(1) ./ (A_frame1 - background_frame);
    A_cal2 = concs(2) ./ (A_frame2 - 0);%A_cal2 = concs(2) ./ (A_frame2 - background_frame)
    A_cal3 = abs(concs(1)-concs(2)) ./ (A_frame1-A_frame2); % gradient between conc 1 and 2
    %A_cal = (A_cal1 + A_cal1) ./ 2; %1 is 0.05, 2 is 0.03 
    A_cal = (A_cal1 + A_cal2 + A_cal3) ./ 3;
    A_diff = (A_cal1 - A_cal2) ./ A_cal;

    save(strcat(directories.folder_save, fsep, 'C-Calib-dyecal.mat'), 'background_frame', 'A_cal', 'A_diff', 'X', 'Y')

    % Display the final results as a plot

    figure(1);
    clf(1);

    % Panel 1 of final figure
    subplot(2, 2, 1);
    imagesc(X, Y, (A_cal.*A_frame1)');
    colorbar;
    caxis([0 0.06]);
    set(gca, 'YDir', 'normal');
    title('Tank 1');
    axis equal tight;

    % Panel 2 of final figure
    subplot(2, 2, 2);
    imagesc(X, Y, (A_cal.*A_frame2)');
    colorbar;
    caxis([0 0.06]);
    set(gca, 'YDir', 'normal');
    title('Tank 2');
    axis equal tight;

    % Panel 3 of final figure
    subplot(2, 2, 3);
    imagesc(X, Y, (A_cal.*((A_frame1+A_frame2)/2))');
    colorbar;
    caxis([0.03 0.05]);
    set(gca, 'YDir', 'normal');
    title('Average');
    axis equal tight;

    % Panel 4 of final figure
    subplot(2, 2, 4);
    imagesc(X, Y, A_diff' * 100);
    colorbar;
    caxis([-50 50]);
    set(gca, 'YDir', 'normal');
    title('% Diff');
    axis equal tight;

    % Save figure as png
    saveas(gca, strcat(directories.folder_save, fsep, 'C-Calib-dyecal.png'));

end
