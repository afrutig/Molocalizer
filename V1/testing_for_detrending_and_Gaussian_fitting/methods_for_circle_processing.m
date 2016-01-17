%% Molofitting



%% first detrend the image by applying a linear fit to all points that are 

% load('molocircles.mat')
% 
% 
% circle_image = a{2,2}
% 
% ft = fittype('fit_2D_gaussian_matlab(X,Y,A,a,b,c,x0,y0)',...
%     'independent', {'X', 'Y'}, 'dependent', 'Z');
% x = 1:size(circle_image,1);
% y = 1:size(circle_image,2);
% 
% [X,Y] = meshgrid(x,y);
% 
% opts = fitoptions( 'Method', 'NonlinearLeastSquares');
% [xData, yData, zData] = prepareSurfaceData(X,Y,circle_image);
% 
% maxValue = max(zData(:));
% [R,C] = find(circle_image == maxValue)
% % mean(mean(circle_image))
% opts.StartPoint = [10000,1,0.5,1,R,C]
% opts.Algorithm = 'Levenberg-Marquardt';
% 
% 
% 
% [fitresult, gof] = fit([xData, yData], zData, ft, opts );
% values = fitresult([xData, yData])
% 
% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, [xData, yData],zData);
% legend( h, 'untitled fit 1', 'Z vs. X, Y', 'Location', 'NorthEast' );
% % Label axes
% xlabel X
% ylabel Y
% zlabel Z
% grid on
% view( -303.5, 6.0 );
% 
% 
% %% Maybe a have to do the fit in an iterative fashion...
% 
% % get all the points that are higher than a certain threshold
% 
% load('image_data_for_gaussian_fitting.mat')
% 
% 
% molo_image = a{3,2}
% 
% % define a circle that has 25 % the size of the entire mologram as the
% % signal region
% 
% % get a circle with the molo signal, this should be such that the sum
% 
% radius = size(molo_image,1)
% 
% signal_ind_x = ceil(3.5*size(molo_image,1)/8):ceil(4.5*size(molo_image,1)/8);
% 
% signal_ind_y = ceil(3.5*size(molo_image,2)/8):ceil(4.5*size(molo_image,2)/8);
% 
% radius = size(molo_image,1)/4;
% 
% signal_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,false)
% background_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,true)
% 
% avg_background = nanmean(nanmean(background_region))
% 
% std_img = nanstd(nanstd(background_region))
% 
% %nansum(nansum(background-avg))/(number of pixel that contribute to the signal is below a threshold)
% 
% signal = sqrt(nansum(nansum(signal_region - avg_background)));
% 
% 
% 
% surf(background);
% surf(signal);
% 
% 
% 
% 
% 
% % avg = nanmean(nanmean(a{2,2}))
% % 
% % std_img = nanstd(nanstd(a{2,2}))
% % 
% % signal_threshold = 1.5;
% % 
% % threshold = 1.2;
% % 
% % 
% % 
% % [C,I] = find(circle_image > nanmean(nanmean(circle_image))*threshold)
% % M = circle_image(find(circle_image > nanmean(nanmean(circle_image))*threshold))
% 
% 
% 
% % for i = 1:size(a,2)
% %     
% %     
% %     for j 1:size
% % 
% 
% 
% 
% 
% % check 
% 
% %% gaussian_detrend
% 
%  % this is the algorithm that should yield the highest
% % accurracy but has the highest computational requirements.
% % 
% % cut a circular hole from the image region
% % the circle around is the background region
% % the circle inside is the signal region
% % 1. fit a first order polynominal to the background
% % region.
% % 2. substract this polynominal from the signal region
% % 3. do the gaussian fitting to the substracted signal in
% % the signal region
% % 4. Take the integral until up to a circle where the value
% % of the fitted function drops below the standarddeviation
% % of the background.
% 
% close all;
% clc;
% 
% background_signal = zeros(1,289);
% background_signal_avg = zeros(1,289);
% background_signal_slope = zeros(1,289);
% 
% for k=1:289
% 
% load(strcat('Evaluation/Cut_Images/moloimages_', num2str(k),'.mat'))
% 
% 
% radius_signal_area = 1/2;
% 
% % loop through all the molo
% for i = 1:size(cut_molocircles,1)
% 
%     for j =1:size(cut_molocircles,2)
%         
%         % separate the image into signal and background region
%         molo_image = cut_molocircles{i,j};
%         radius = size(molo_image,1)/2*radius_signal_area;
%         
%        
%         signal_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,false);
%         background_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,true);
% 
%        
%         
%         [XX,YY] = meshgrid(1:size(background_region,1),1:size(background_region,2));
%         % do a linear fit to the background.
%         [xData, yData, zData] = prepareSurfaceData(XX,YY,background_region');
%         linear_x = fittype('a + b*X +0*Y',...
%         'dependent',{'Z'},'independent',{'X','Y'},...
%         'coefficients',{'a','b'});
%         ws = warning('off','all');  % Turn off warning
%      
%         [fitresults, gof ] = fit([xData, yData],zData ,linear_x);
%         
%         background_signal(k) = fitresults.a;
%         background_signal_avg(k) = nanmean(nanmean(background_region));
%         background_signal_std(k) = nanstd(nanstd(background_region));
%         background_signal_slope(k) = fitresults.b;
%         
%         signal_region_fit(k) = real(sqrt(nansum(nansum(signal_region - fitresults(XX,YY)))));
%         signal_region_avg(k) = real(sqrt(nansum(nansum(signal_region - background_signal_avg(k)))));
%         signal_region_avg_3std(k) = real(sqrt(nansum(nansum(signal_region(signal_region > (30*background_signal_std(k)+background_signal_avg(k))) - background_signal_avg(k)))));
%         % I guess this one is a good algorithm!!! It is not too bad, but I
%         % still do not get the entire signal!!
%         signal_region_avg_3std(k) = real(sqrt(nansum(nansum(signal_region(signal_region > 1.2*max(max(background_region))) - background_signal_avg(k)))));
%         % if there is intensity in the signal, then sum over the rest of
%         % the signal. 
% %         figure()
% %         surf(signal_region);
% %         
% %         % fit the gaussian function
% %         ft = fittype('fit_2D_gaussian_matlab(X,Y,A,a,b,c,x0,y0)',...
% %             'independent', {'X', 'Y'}, 'dependent', 'Z');
% % 
% % 
% %         opts = fitoptions( 'Method', 'NonlinearLeastSquares');
% %         [xData, yData, zData] = prepareSurfaceData(XX,YY,signal_region);
% % 
% %         maxValue = max(zData(:));
% %         [R,C] = find(signal_region == maxValue)
% %         % mean(mean(circle_image))
% %         opts.StartPoint = [maxValue,1,0.5,1,R,C]
% %         opts.Algorithm = 'Levenberg-Marquardt';
% % 
% %      
% %         hold on;
% %         [fitresult, gof] = fit([xData, yData], zData, ft, opts );
% %         surf(fitresult(XX,YY));
% %         nansum(nansum(fitresult(XX,YY)))
% %         nansum(nansum(signal_region))
% %         hold off;
% %         figure()
% %         surf(background_region);
% %         figure()
% %         surf(signal_region);
%         
%         
%         % only process the first image for testing purposes
%        
%      break;
% 
%     end
%     
%     break;
% 
%     
% 
% end
% 
% 
% end
% 
% % plot(background_signal);
% plot(signal_region_fit)
% 
% hold on;
% 
% % plot(background_signal_avg,'r');
% plot(signal_region_avg,'r')
% 
% plot(signal_region_avg_3std,'g')

%% gaussian_detrend

 % this is the algorithm that should yield the highest
% accurracy but has the highest computational requirements.
% 
% cut a circular hole from the image region
% the circle around is the background region
% the circle inside is the signal region
% 1. fit a first order polynominal to the background
% region.
% 2. substract this polynominal from the signal region
% 3. do the gaussian fitting to the substracted signal in
% the signal region
% 4. Take the integral until up to a circle where the value
% of the fitted function drops below the standarddeviation
% of the background.

close all;
clc;

background_signal = zeros(1,289);
background_signal_avg = zeros(1,289);
background_signal_slope = zeros(1,289);

for k=1:289

load(strcat('Evaluation/Cut_Images/moloimages_', num2str(k),'.mat'))


radius_signal_area = 1/2;

% loop through all the molo
for i = 1:size(cut_molocircles,1)

    for j =1:size(cut_molocircles,2)
        
        % separate the image into signal and background region
        molo_image = cut_molocircles{i,j};
        radius = size(molo_image,1)/2*radius_signal_area;
        
       
        signal_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,false);
        background_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,true);
        background_signal_avg(k) = nanmean(nanmean(background_region));
        background_signal_std(k) = nanstd(nanstd(background_region));
    
            
        % get the coordinates of the maximum of the signal region
        [x_max, y_max] = find(signal_region==max(signal_region(:)));
        
        radius = 1;
        signal_previous_iteration = 0;
        non_nan_values_previous_iteration = 0;
        current_signal = [];
        k 
        m = 0;
        while true
            
            try
                hilf = cut_circle_in_matrix(signal_region,radius,x_max,y_max,false);
            catch
                current_signal = max(signal_region(:))
                break;
            end
            non_nan_values = sum(sum(~isnan(hilf)));
            current_signal = nansum(nansum(hilf - background_signal_avg(k)));
    
            
            if (current_signal - signal_previous_iteration) < (3*background_signal_std(k))*(non_nan_values - non_nan_values_previous_iteration)
            
                break;
                
            else
               
      
               radius = radius + 1;
               signal_previous_iteration  = current_signal;
               non_nan_values_previous_iteration = non_nan_values;
               m = m+1
            end
            signal(k) = current_signal;
            
            
        end
        
        
        

       
     break;

    end
    
    break;

    

end


end

% plot(background_signal);
figure()
plot(signal)




                



