function [image_above_threshold, centroids] = getMoloSpots(image,Threshold_slider)
% this function calculates the positions of the molographic spots in the
% image, it uses the average background of the image plus an offset
% determined by the standard deviation in order to find the appropriate
% values. 

% Postconditions: 



% compute the average of the image

avg_int = mean(mean(image));
std_int = std2(image);


image_above_threshold = image > (avg_int + std_int*get(Threshold_slider,'Value'));

BW = imregionalmax(image_above_threshold);
s = regionprops(image_above_threshold,'centroid');




centroids = cat(1, s.Centroid);



if isempty(centroids)
    
    centroids(1,:) = [100 100]
    
end



end