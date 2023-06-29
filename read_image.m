function image = read_image(filepath)
    % read_image    Read in an image from file.
    %
    % Syntax: image = read_image(filepath)
    %
    % Inputs:
    %   filepath
    %
    % Ouputs:
    %   image
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
    % Authors: Dr Edward Parkinson
    % University of Southampton
    % Revisions:
    %   Created E Parkinson 24 Aug 2022

    [~, ~, ext] = fileparts(filepath);

    if strcmp(ext, '.im7') == true
        buffer = readimx(filepath);
        image = buffer.Frames{1}.Components{1}.Planes{:} * ...
                buffer.Frames{1}.Components{1}.Scale.Slope + ...
                buffer.Frames{1}.Components{1}.Scale.Offset;
    elseif strcmp(ext, '.tiff') == true
        image = imread(filepath);
    else
        error('Unable to open image. The image format "%s" is not supported. Only .im7 and .tiff images are supported', ext);
    end

end
