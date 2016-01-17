function plotSelection(handles)
    
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





end