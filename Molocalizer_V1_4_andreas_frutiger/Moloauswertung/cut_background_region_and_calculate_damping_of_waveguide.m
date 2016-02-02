function damping_constant = cut_background_region_and_calculate_damping_of_waveguide(background_rectangle_coordinates, image,pixel_per_um)
%UNTITLED Summary of this function goes here
%   This function cuts the background region images for the calculation of
%   the damping constant of the waveguide.
% Robustness: Because of waveguide impurities it is necessary for each line
% to average abadon the highest 20% of the values and the lowest 20 % this
% should then give a reliable estimate of the background intensity of this
% line - with this it is also possible to have the molograms in the
% background region without adversely affecting the results.$

% postconditions: Returns the damping constant of the waveguide in 1/mm

x_s = round(background_rectangle_coordinates(1));
x_e = round(background_rectangle_coordinates(1) + background_rectangle_coordinates(3));
y_s = round(background_rectangle_coordinates(2));
y_e = round(background_rectangle_coordinates(2) + background_rectangle_coordinates(4));
x_ind = x_s:x_e;
y_ind = y_s:y_e;
cut_background_image = image(y_ind,x_ind);

% figure
% imagesc(cut_background_image)


% loop through the x-indices and average along the y-axis but omit the 20%
% lowest and highest values

damping_profile = zeros(1,length(x_ind));

for i = 1:length(x_ind)
    
    sorted_slice = sort(cut_background_image(:,i));
    sorted_slice = sorted_slice(round(0.2*length(y_ind)):round(0.8*length(y_ind)));
    damping_profile(i) = mean(sorted_slice);
    
end

prop_distance = (1:length(damping_profile))/pixel_per_um;

% Set up fittype and options.
ft = fittype(@(a,b,c,x) a*exp(-b*x)+c);
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [damping_profile(1)-damping_profile(end),(damping_profile(1)-mean(damping_profile))/prop_distance(end),damping_profile(end)];

% Fit model to data.

[fitresult] = fit(prop_distance', damping_profile', ft, opts );
coeffvals = coeffvalues(fitresult)
% coeffvals(2)
figure;
plot(fitresult,prop_distance,damping_profile)

% for conversion into dB/cm
10*log(coeffvals(2)*10000);

damping_constant = coeffvals(2)*1000;




end

