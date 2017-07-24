function [image_circles,pixel_per_um] = cut_Molo_circles(confirmedMoloSpots,image)
%cut_Molo_circles: %   This function cuts out circles around the molographic foci positions
%   with a radius equal to the radius of the underlying mologram. 

% Preconditions
% - confirmedMolospots: structured array, containing the three lines of molograms. each has a position x_coord, y_coord with an array of the x
% and y_values of this line
% foci in the image
% - image: actual image_data with the mologra


% Postconditions: 
% - image_circles: two dimensional cell array (three rows for the three lines of different molograms) with
% matrices of the image data. It is a square array with the values outside
% the circle as NaN. Circles that intersect with the boundaries of the
% image are marked as NaN values in the array.


diameter = [300 300 300]; % this is the diameter of the molograms in the three lines. 

% first convert the um in pixels/automatically measures the molographic
% spot seperation, because it is known to be 400 um

pixel_per_um = sqrt((confirmedMoloSpots(1).x_coord(1) - confirmedMoloSpots(1).x_coord(2))^2+(confirmedMoloSpots(1).y_coord(1) - confirmedMoloSpots(1).y_coord(2))^2)/400;

diameter_pixel = diameter*pixel_per_um;

% get a square around the center point

image_circles{3,length(confirmedMoloSpots(1).x_coord)} = NaN;

for i = 1:length(confirmedMoloSpots)
   

    % get the square images
    
    for j = 1:length(confirmedMoloSpots(i).x_coord)
        
        x_ind = round(confirmedMoloSpots(i).x_coord(j) - diameter_pixel(i)/2):round(confirmedMoloSpots(i).x_coord(j) + diameter_pixel(i)/2);
        y_ind = round(confirmedMoloSpots(i).y_coord(j) - diameter_pixel(i)/2):round(confirmedMoloSpots(i).y_coord(j) + diameter_pixel(i)/2);

        square_image = image(y_ind,x_ind);
        
        x_center = size(square_image,1)/2;
        y_center = size(square_image,2)/2;
        
        % generate the inverse mask
        
        mask = ones(size(square_image));
        
        for k = 1:size(square_image,1)
            
            for l = 1:size(square_image,2)
                
                % check whether the point is inside the circle
                if (k-ceil(x_center))^2+(l-ceil(y_center))^2 <= (diameter_pixel(i)/2)^2
                    
                    mask(k,l) = 0;
                    
                end
                
                
            end
             
        end
        
        
        % convert the image to double because otherwise NaN is not
        % supported. 
        circle_image = double(square_image);
        circle_image(logical(mask)) = NaN;
        % surf(circle_image);
        % save('image_data_for_gaussian_fitting.mat','circle_image')
        % imagesc(circle_image);
        
        image_circles{i,j} = circle_image;
        % Here you should check for all the points whether they lie inside
        % the circle and set all other points = 0
   
        
        
    end
    
    
end

end

