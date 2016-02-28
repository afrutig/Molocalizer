function export_LOD(handles,algorithm)
% this exports the LOD's of the individual molograms


    LOD_upper_csv = zeros(size(handles.molo_algo_data.(algorithm),1)*size(handles.molo_algo_data.(algorithm),2),3);
    LOD_lower_csv = zeros(size(handles.molo_algo_data.(algorithm),1)*size(handles.molo_algo_data.(algorithm),2),3);
    LOD_upper = zeros(size(handles.molo_algo_data.(algorithm)));
    LOD_lower = zeros(size(handles.molo_algo_data.(algorithm)));
    
    if isfield(handles.molo_algo_data.(algorithm)(1,1),'LOD')
        length(handles.molo_algo_data.(algorithm)(1,1).LOD)
        size(handles.molo_algo_data.(algorithm))
        LOD_fields = zeros([size(handles.molo_algo_data.(algorithm)) length(handles.molo_algo_data.(algorithm)(1,1).LOD)]);
        
    end
    
    
    styles = 'rbg';
    figure1 = figure('Visible','off');
    axes1 = axes('Parent',figure1,'Fontsize',16);
    
    
    line_numbers = [1,3,4];
    
    for j = 1:size(handles.molo_algo_data.(algorithm),1)
         
         for k = 1:size(handles.molo_algo_data.(algorithm),2)
             
            index = (j-1)*size(handles.molo_algo_data.(algorithm),2) + k;
            LOD_upper_csv(index,1) = j;
            LOD_upper_csv(index,2) = k;
            LOD_upper_csv(index,3) = handles.molo_algo_data.(algorithm)(j,k).upper_LOD;
            LOD_upper(j,k) = handles.molo_algo_data.(algorithm)(j,k).upper_LOD;

            LOD_lower_csv(index,1) = j;
            LOD_lower_csv(index,2) = k;
            LOD_lower_csv(index,3) = handles.molo_algo_data.(algorithm)(j,k).lower_LOD;
            LOD_lower(j,k) = handles.molo_algo_data.(algorithm)(j,k).lower_LOD;
            
            if isfield(handles.molo_algo_data.(algorithm)(1,1),'LOD')
            
                for l = 1:length(handles.molo_algo_data.(algorithm)(1,1).LOD)
                    
                    LOD_fields(j,k,l) = handles.molo_algo_data.(algorithm)(j,k).LOD(1);
                    
                end
                
            end
            
                
         end
         
    end
    
    % for the standard algorithm Volker did not want to have the
    % algorithm labeling, here is a workaround
    
    if strcmp(algorithm,'iter_sig_area_inc_3std')
           
         algorithm = '';
            
    end
    name = strcat(handles.path,'/Evaluation/Plots/', algorithm, '_LOD_upper.png');
    
%     print(figure1,name,'-dpng')
    'LOD upper Mean'
    mean(LOD_upper_csv(:,3))
    'LOD upper Std'
    std(LOD_upper_csv(:,3))
    csvwrite(strcat(handles.path,'/Evaluation/csv_files/', handles.experiment_name, '_', algorithm, '_LOD_upper.txt'),LOD_upper_csv);
    save(strcat(handles.path,'/Evaluation/mat_files/', handles.experiment_name, '_', algorithm, '_LOD_upper.mat'),'LOD_upper');
    save(strcat(handles.path,'/Evaluation/mat_files/', handles.experiment_name, '_', algorithm, '_LODs.mat'),'LOD_fields');

%     styles = 'rbg';
%     figure1 = figure('Visible','off');
%     axes1 = axes('Parent',figure1,'Fontsize',16);
%     
%     h = bar(axes1,LOD_lower');
%     l = cell(1,3);
%     l{1}='MoloLine 1';
%     l{2}='MoloLine 3';
%     l{3}='MoloLine 4';
%     legend(h,l,'Location','North');
%     legend boxoff
%     xlabel('Horizontal Position of molograms');
%     ylabel('LOD []');

    % for the standard algorithm Volker did not want to have the
    % algorithm labeling, here is a workaround

    if strcmp(algorithm,'iter_sig_area_inc_3std')
           
         algorithm = '';
            
    end
    name = strcat(handles.path,'/Evaluation/Plots/', algorithm, '_LOD_lower.png');
    
%     print(figure1,name,'-dpng')
    'LOD lower Mean'
    mean(LOD_lower_csv(:,3))
    'LOD lower Std'
    std(LOD_lower_csv(:,3))
    csvwrite(strcat(handles.path,'/Evaluation/csv_files/', handles.experiment_name, '_', algorithm, '_LOD_lower.txt'),LOD_lower_csv);
    save(strcat(handles.path,'/Evaluation/mat_files/', handles.experiment_name, '_', algorithm, '_LOD_lower.mat'),'LOD_lower');





end