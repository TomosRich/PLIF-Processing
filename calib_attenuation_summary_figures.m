function calib_attenuation_summary_figures(directories, concentration_files, concentrations, origin_X, epsilon, delta_R)
    % correct_attenuation_summary_figures
    %
    % Syntax: correct_attenuation_summary_figures(directories, concentration_files, old_dye_calib_frame, concentrations, origin_X, epsilon, delta_R)
    %
    % Inputs:
    %   directories
    %   concentration_files
    %   old_dye_calib_frame
    %   concentrations
    %   origin_X
    %   epsilon
    %   delta_R
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
    % MAT-files required: none
    % Other files required: none
    %
    % Authors: Dr Christina Vanderwel, D Hertwig, Desmond Lim, Dr Edward Parkinson
    % University of Southampton
    % Revisions:

    fsep = filesep;

    % Check the result
    load(strcat(directories.folder_save, fsep, concentration_files{1}, 'corr', num2str(epsilon), '.mat'), 'dye_calib_frame', 'old_dye_calib_frame');
    corrected_dye_calib_frame1 = dye_calib_frame;
    dye_calib_conc_1 = old_dye_calib_frame;

    load(strcat(directories.folder_save, fsep, concentration_files{2}, 'corr', num2str(epsilon), '.mat'), 'dye_calib_frame', 'old_dye_calib_frame', 'X', 'Y');
    corrected_dye_calib_frame2 = dye_calib_frame;
    dye_calib_conc_2 = old_dye_calib_frame;

    figure(1);
    clf(1);
    imagesc(X, Y, ((corrected_dye_calib_frame1) ./ (corrected_dye_calib_frame2) - concentrations(1) / concentrations(2)));
    colorbar;
    set(gca, 'YDir', 'normal');
    caxis([-2 2]);
    axis equal tight;
    saveas(gca, strcat(directories.folder_save, fsep, 'CorrDyeCal.png'));

    % Plot a sample profile using 1 laser line at near theta=0.
    xi = find(X > origin_X, 1, 'first');
    yi = 1:find(Y < 5, 1, 'first'); % TODO: why is this < 5?
    r_t = delta_R(yi, xi);
    C_t1 = dye_calib_conc_1(xi, yi)';
    C_t2 = dye_calib_conc_2(xi, yi)';
    C_p1 = corrected_dye_calib_frame1(xi, yi)';
    C_p2 = corrected_dye_calib_frame2(xi, yi)';

    figure(2);
    clf(2);
    plot(r_t, C_t1, 'b-', r_t, C_p1, 'r-');
    hold on;
    plot(r_t, C_t2, 'b--', r_t, C_p2, 'r--');
    xlabel('\Delta r'); % Note that 0 is defined at the start of the calibration tank.
    ylabel('Dye cal values');
    title('Sample profile of 1 laser line');
    legend('Solid uncorrected C=0.05', 'Solid corrected C=0.05', 'Dashed uncorrected C=0.03', 'Dashed corrected C=0.03');
    saveas(gca, strcat(directories.folder_save, fsep, 'CorrDyeCal_deltar.png'));

    % Plot theta-averaged profiles over sample line by binning delta_R with resolution of bin_res=1.
    bin_res = 0.5;
    bin_ = discretize(delta_R, min(min(delta_R)):bin_res:max(max(delta_R)));

    start_idx = min(min(bin_));
    end_idx = max(max(bin_));
    num_bins = end_idx - start_idx;

    CC_t1 = zeros(num_bins, 1);
    CC_p1 = zeros(num_bins, 1);
    CC_t2 = zeros(num_bins, 1);
    CC_p2 = zeros(num_bins, 1);
    RR_t = zeros(num_bins, 1);

    for i = start_idx:end_idx
        indx = find(bin_ == i);
        RR_t(i) = mean(delta_R(indx));

        conj_mat = dye_calib_conc_1';
        CC_t1(i) = mean(conj_mat(indx));
        conj_mat = corrected_dye_calib_frame1';
        CC_p1(i) = mean(conj_mat(indx));
        conj_mat = dye_calib_conc_2';
        CC_t2(i) = mean(conj_mat(indx));
        conj_mat = corrected_dye_calib_frame2';
        CC_p2(i) = mean(conj_mat(indx));

    end

    figure(3);
    clf(3);
    plot(RR_t, CC_t1', 'k-', RR_t, CC_p1, 'k-');
    hold on;
    plot(RR_t, CC_t2, 'k--', RR_t, CC_p2, 'k--');
    xlabel('\Delta r');
    ylabel('Theta-averaged Dye cal values');
    title('Sample profile of theta-averaged laser line (black)');
    legend('Solid uncorrected C=0.05', 'Solid corrected C=0.05', 'Dashed uncorrected C=0.03', 'Dashed corrected C=0.03');
    saveas(gca, strcat(directories.folder_save, fsep, 'ThetaAvgCorrDyeCal_deltar.png'));

    % Plot CoorDyeCal ratio based on sample line.
    figure(4);
    clf(4);
    plot((C_p1) ./ (C_p2));
    grid on;
    hold on;
    plot([300 2000], [concentrations(1) / concentrations(2), concentrations(1) / concentrations(2)], 'k');
    xlabel('y-axis pixels');
    ylabel('Ratio');
    xlim([300 2000]);
    ylim([1.5 1.8]);
    title('CoorDyeCal ratio based on sample line');
    saveas(gca, strcat(directories.folder_save, fsep, 'CorrDyeCal_ratio.png'));

    % Plot CoorDyeCal ratio based on theta-averaged values.
    figure(5);
    clf(5);
    plot(RR_t, (CC_p1') ./ (CC_p2'));
    grid on;
    hold on;
    plot([180 320], [concentrations(1) / concentrations(2), concentrations(1) / concentrations(2)], 'k');
    xlabel('\Delta r');
    ylabel('Ratio');
    xlim([170 300]);
    ylim([1.5 1.8]);
    title('CoorDyeCal ratio based on theta-averaged line');
    saveas(gca, strcat(directories.folder_save, fsep, 'ThetaAvg_CorrDyeCal_ratio.png'));

end
