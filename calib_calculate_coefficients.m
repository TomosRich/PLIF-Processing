function calib_calculate_coefficients(directories, parameters, image_type, num_images, run_name, concentrations)
    % calculate_calibration_coefficients
    %
    % Syntax: calculate_calibration_coefficients(directories, parameters, num_images, run_name, concentrations)
    %
    % Inputs:
    %   directories
    %   parameters
    %   image_type
    %   num_images
    %   run_name
    %   concentrations
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


    % Process for any unset parameters, and use default values for those

    parameters = get_default_unset_parameters(parameters);% this is a threat, not a practical thing to use

    % Next, we run through the steps to calibrate the dye image
    calib_average_frames(directories, concentrations, image_type, parameters.y0, parameters.x0, parameters.x_loc, parameters.y_loc, parameters.normalize_energy_monitor);
    calib_merge_frames(directories, concentrations);
    calib_trace_rays(directories, concentrations, parameters.y_extra, parameters.y_high_end, parameters.theta_line_low, parameters.theta_line_high, parameters.beta_polar_interp);
    calib_correct_attenuation(directories, concentrations, parameters.epsilon, parameters.theta_line_low, parameters.theta_line_high, parameters.tank_height);
    calculate_background_intensity_gradient(directories, image_type, num_images, run_name);
    calib_make_final_frame(directories, concentrations, parameters.epsilon);

end
