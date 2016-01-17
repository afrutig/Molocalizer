function plot_Confirmed_MoloSpots(handles)
    
% this needs to be a separate function that plots the molospots

axes(handles.axes1);
imagesc(handles.image_above_threshold);

axis equal;
hold on;

viscircles(handles.centroids, 10*ones(1,length(handles.centroids(:,1))),'EdgeColor','w','LineWidth',0.5,'DrawBackgroundCircle',false);

for i=1:length(handles.points_to_delete)
    
    viscircles(handles.points_to_delete{i}, 10,'EdgeColor','r','LineWidth',1,'DrawBackgroundCircle',false);

end

for i=1:length(handles.points_to_add)
    
    viscircles(handles.points_to_add{i}, 10,'EdgeColor','g','LineWidth',1,'DrawBackgroundCircle',false);
    
end


% plot the moloVector
for i=1:length(handles.moloVector)
    
    viscircles(handles.moloVector{i}, 10,'EdgeColor','y','LineWidth',1,'DrawBackgroundCircle',false);
    
end



hold off;




% draw the enlarged image with the 
% only if we need that....
% axes(handles.axes2);
% axis off; 
% offset = 5;
% hold on;
% 
% size(handles.image1)
% small_image_y = round(min(handles.centroids(:,2)))-offset:round(max(handles.centroids(:,2)))+offset
% small_image_x = round(min(handles.centroids(:,1)))-offset:round(max(handles.centroids(:,1)))+offset
% 
% imagesc(handles.image1(small_image_y,small_image_x));
% 
% for i=1:length(handles.moloVector)
%     scaled_Molovector = [handles.moloVector{i}(1,1) - small_image_x(1),handles.moloVector{i}(1,2) - small_image_y(1)]
%     viscircles(scaled_Molovector, 10,'EdgeColor','y','LineWidth',1,'DrawBackgroundCircle',false);
%     
% end
% 
% 
% 
% hold off




end