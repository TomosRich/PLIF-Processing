function [background_intensity] = get_background_intensity(i, image_folder, image_type)
    % get_background_intensity      Get the background intensity factor for an image
    %
    % Syntax: [background_intensity] = get_background_intensity(i, image_folder)
    %
    % Inputs:
    %   i - the image number
    %   image_folder - the path to the folder containing images
    %   image_type
    %
    % Ouputs:
    %   background_intensity
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


    fsep = filesep;
    image = imread(strcat(image_folder, fsep, 'B', num2str(i, '%04d'), '.', image_type))';


    nx = size(image, 1);
    ny = size(image, 2);

    % aim E at the freestream to get sensible values
    E = image(int16(3 * (nx / 8)):int16(5 * (nx / 8)), int16(1 * (ny / 8)):int16(2 * (ny / 8))); % grab a little chunk of background to judge the background intensity
    background_intensity = mean(E, 'all');

end

% this section(below) is useful to check where youre aiming E in line 37 :), it should be a freestream section in which no dye is present

%image(int16(4 * (nx / 8)):int16(7 * (nx / 8)), int16(1 * (ny/8)):int16(2 * (ny / 8))) = image(int16(4 * (nx / 8)):int16(7 * (nx /8)), int16(1 * (ny / 8)):int16(2 * (ny / 8)))*2;
%imagesc(image)
