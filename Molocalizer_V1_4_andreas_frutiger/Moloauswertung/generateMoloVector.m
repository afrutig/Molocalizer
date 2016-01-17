function moloVector = generateMoloVector(centroids,points_to_add,points_to_delete,radius,current_image,handles)

% The only variable that is used from handles is handles.MoloArea

% check if within interaction radius
% fist check if there are double points in points_to_add and
% points_to_delete
% always initialize the molovector new. 

moloVector = {};
size(centroids)
centroids
for k = 1:length(centroids(:,1))
  
    moloVector{end+1} = [centroids(k,1) centroids(k,2)];
    
end

% if the MoloArea is defined then check also this area


index_to_remove = [];

if isfield(handles,'MoloArea')
   
    for i = 1:length(moloVector)
         
        

         
         % check y coordinate
         if  handles.MoloArea(1) > moloVector{i}(1,1) || (handles.MoloArea(1)+handles.MoloArea(3)) < moloVector{i}(1,1)
             
             index_to_remove(end+1) = i;
  
             
             continue;
             
         end
             
         % check x coordinate
         
         if handles.MoloArea(2) > moloVector{i}(1,2) || (handles.MoloArea(2)+handles.MoloArea(4)) < moloVector{i}(1,2)
             
             index_to_remove(end+1) = i;
             continue;
             
         end
         
             
    end
    
    moloVector(index_to_remove) = [];
    
end

% check whether you need to add some points

for i = 1:length(points_to_add)
    
    moloVector{end+1} = points_to_add{i};
    
end

for j = 1:length(points_to_delete)

    for i = 1:length(moloVector)



         if radius^2 > (points_to_delete{j}(1,1) - moloVector{i}(1,1))^2 + (points_to_delete{j}(1,2) - moloVector{i}(1,2))^2

            moloVector(i) = [];
            
            break;

         end
         
        

    end



end

% check here as well, whether the point is too close to the
% boundary that an appropriate background can be substracted. 

index_to_remove = [];

for i = 1:length(moloVector)
         
        

         
         % check y coordinate
         if (moloVector{i}(1,1) - radius) < 1 || (radius + moloVector{i}(1,1)) > size(current_image,2)
             
             index_to_remove(end+1) = i;
  
             
             continue;
             
         end
             
         % check x coordinate
         
         if (moloVector{i}(1,2) - radius) < 1 || (radius + moloVector{i}(1,2)) > size(current_image,1)
             
             index_to_remove(end+1) = i;
             continue;
             
         end
         
             
end

moloVector(index_to_remove) = [];

% this was an algorithm that detected overlapping spots, this should be
% adapted for the molovector. 



% for i = 1:size(handles.centroids,1)
%     
%     
%     for j = 1:size(handles.centroids,1)
%         
%         
%         % you only have to check the upper half of the matrix since it is
%         % symmetrical.
%         if j >= i
%             continue;
%         end
%     
% 
%      if handles.radius^2 > (handles.centroids(i,1) - handles.centroids(j,1))^2 + (handles.centroids(i,2) - handles.centroids(j,2))^2        
%          
%         % mark the two overlapping circles for subsequent deletion
%         handles.centroids(i,1) = NaN;
%         handles.centroids(i,2) = NaN;
%         handles.centroids(j,1) = NaN;
%         handles.centroids(j,2) = NaN;
%     
%        
%      end
% 
%     end
% 
% 
% 
% end
% 
% % remove the circles that were marked before since they were overlapping.
% 
% handles.centroids(isnan(handles.centroids)) = [];
% handles.centroids = reshape(handles.centroids,[],2);
% 
% % set(handles.Console_output,'String',num2str(handles.centroids));
% set(handles.Console_output,'String',[get(handles.Console_output,'String') num2str(size(handles.centroids,1)) ]);
% % set(handles.Console,


% handles = remove_overlapping_circles(handles);









