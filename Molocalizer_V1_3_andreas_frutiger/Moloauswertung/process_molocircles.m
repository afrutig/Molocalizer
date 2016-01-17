function [signal, background] = process_molocircles(image_circles,options)
    
    % this function processes the circle images with the molographic foci
    % according to the algorithm specified in options
    
    % Preconditions:
    % - image_circles: two dimensional cell array (three rows for the three lines of different molograms) with
	% matrices of the image data. It is a square array with the values outside
    % the circle as NaN. Circles that intersect with the boundaries of the
    % image are marked as NaN values in the array.
    
    % options:
    % - Algorithm:
    %       - histogram: sums up all the intensities in the region of
    %       interest circle of the molographic circle image.
    %       - this algorithm does not do a sophisticated calculation of the
    %       background signal yet.
   
    signal = ones(size(image_circles));
    background = ones(size(image_circles));
    
    if (isfield(options,'Algorithm'))
        
        switch options.Algorithm
            
%             case 'histogram'
%                 % processes the image according to
%                 
%                 background(size(image_circles,1),size(image_circles,2)) = 0;
%                 signal(size(image_circles,1),size(image_circles,2)) = 0;
%                 
%                 for i = 1:size(image_circles,1)
%                     
%                     for j =1:size(image_circles,2)
%                         
%                         molo_image = image_circles{i,j};
% 
%                         radius = size(molo_image,1)/4;
% 
%                         signal_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,false);
%                         background_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,true);
% 
%                         background(i,j) = nanmean(nanmean(background_region));
% 
%                         std_img = nanstd(nanstd(background_region));
%                         
%                         % maybe implement something like a quality measure
%                         % here.
%                         %nansum(nansum(background-avg))/(number of pixel that contribute to the signal is below a threshold)
%                         
%                         % this has to be done after the normalization
%                         % otherwise I make an error. (signal_region > 1*max(max(background_region)))
%                         signal(i,j) = sqrt(nansum(nansum(signal_region - background(i,j))));
%                         
%                         %surf(background_region);
%                         %surf(signal_region);
%                         
%                         
%                     end
%                     
%                 end
                
            case 'std_5_times'
                % algorithm implemented according to Michael
                % everything in the image area which is higher than
                % background + 5 times the standard deviation is a signal
                % and summed up.
                % --> that is my benchmark.
      
                background(size(image_circles,1),size(image_circles,2)) = 0;
                signal(size(image_circles,1),size(image_circles,2)) = 0;
                
                for i = 1:size(image_circles,1)
                    
                    for j =1:size(image_circles,2)
                        
                        molo_image = image_circles{i,j};

                        radius = size(molo_image,1)/4;

                        signal_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,false);
                        background_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,true);

                        background(i,j) = nanmean(nanmean(background_region));

                        std_img = nanstd(nanstd(background_region));

                        % this has to be done after the normalization
                        % otherwise I make an error.)
                        signal(i,j) = nansum(nansum(signal_region(signal_region > (background(i,j)+5*std_img)) - background(i,j)));
                        
                        %surf(background_region);
                        %surf(signal_region);
                        
                        
                    end
                    
                end
                
            case 'iter_sig_area_inc_3std'
               
                % loop through all the molo
                for i = 1:size(image_circles,1)

                    for j =1:size(image_circles,2)

                        % separate the image into signal and background region
                        molo_image = image_circles{i,j};
                        radius = size(molo_image,1)/4;


                        signal_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,false);
                        background_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,true);
                        background(i,j) = nanmean(nanmean(background_region));
                        background_signal_std = nanstd(nanstd(background_region));


                        % get the coordinates of the maximum of the signal region
                        % [x_max, y_max] = find(signal_region==max(signal_region(:)));

                        r = 1;
                        signal_previous_iteration = 0;
                        non_nan_values_previous_iteration = 0;
                        current_signal = 0;

                        while true

                            try
                                hilf = cut_circle_in_matrix(signal_region,r,size(molo_image,1)/2,size(molo_image,2)/2,false);
                            catch
                                current_signal = max(signal_region(:));
                                break;
                            end
                            non_nan_values = sum(sum(~isnan(hilf)));
                            current_signal = nansum(nansum(hilf - background(i,j)));


                            if (current_signal - signal_previous_iteration) < (3*background_signal_std*(non_nan_values - non_nan_values_previous_iteration))

                                break;

                            elseif r > size(signal_region,2)/2
                                
                                break;
                                
                            else

                               r = r + 1;
                               signal_previous_iteration  = current_signal;
                               non_nan_values_previous_iteration = non_nan_values;
                  
                            end
                            


                        end

                        signal(i,j) = current_signal;

                    end




                end
                
                case 'maximum_vs_background'
                    
                for i = 1:size(image_circles,1)

                    for j =1:size(image_circles,2)

                        % separate the image into signal and background region
                        molo_image = image_circles{i,j};
                        radius = size(molo_image,1)/4;


                        signal_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,false);
                        background_region = cut_circle_in_matrix(molo_image,radius,size(molo_image,1)/2,size(molo_image,2)/2,true);
                        background(i,j) = nanmean(nanmean(background_region));
                       

                        signal(i,j) = max(max(signal_region));

                    end




                end
                    
                    
                    

        end
        
   
        
        
        
        
        
    end


end

% hypothetical algorithm (never implemented). 
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