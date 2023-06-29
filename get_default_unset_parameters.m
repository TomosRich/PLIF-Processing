function [parameters] = get_default_unset_parameters(parameters)
    % get_default_unset_parameters   Set default values in parameters struct
    %
    % This function will set a default value for a parameter if it is not included
    % in the parameters struct. These values are historically set for experiments
    % at Southampton.
    %
    % Syntax: parameters = get_default_unset_parameters(parameters)
    %
    % Inputs:
    %   parameters - the struct containing parameters and their values
    %
    % Outputs:
    %   parameters - the updated struct
    %
    % Example:
    %   -
    %
    % See also: -
    %
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    % Other files required:  none
    %
    % Authors: Dr Edward Parkinson
    % University of Southampton
    % Revisions:
    %   Created E Parkinson 11 Aug 2022     Created file and function

    if ~isfield(parameters, 'x_loc')
        parameters.x_loc = 110;
    end

    if ~isfield(parameters, 'y_loc')
        parameters.y_loc = 110;
    end

    if ~isfield(parameters, 'y_extra')
        parameters.y_extra = 23;
    end

    if ~isfield(parameters, 'y_high_end')
        parameters.y_high_end = 150;
    end

    if ~isfield(parameters, 'theta_line_low')
        parameters.theta_line_low = -20;
    end

    if ~isfield(parameters, 'theta_line_high')
        parameters.theta_line_high = 20;
    end

    if ~isfield(parameters, 'x0')
        parameters.x0 = 357.9233;
    end

    if ~isfield(parameters, 'y0')
        parameters.y0 = -134.7320 + 20;
    end

    if ~isfield(parameters, 'epsilon')
        parameters.epsilon = 49.178500;
    end

    if ~isfield(parameters, 'beta_polar_interp')
        parameters.beta_polar_interp = false;
    end

    if ~isfield(parameters, 'normalize_energy_monitor')
        parameters.normalize_energy_monitor = true;
    end

end
