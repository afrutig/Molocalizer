function export_chemical_integrities(handles,algorithm)
% also exports the molo_offsets if one does not want to perform the 

    chemical_integrities_csv = zeros(size(handles.molo_algo_data.(algorithm),1)*size(handles.molo_algo_data.(algorithm),2),3);
    chemical_integrity_matrix = zeros(size(handles.molo_algo_data.(algorithm)));

    header = {'index j','index k','Chemical integrity'};
    
    styles = 'rbg';
    figure1 = figure('Visible','off');
    axes1 = axes('Parent',figure1,'Fontsize',16);
    
    
    line_numbers = [1,3,4];
    
    for j = 1:size(handles.molo_algo_data.(algorithm),1)
         
         for k = 1:size(handles.molo_algo_data.(algorithm),2)
             
            index = (j-1)*size(handles.molo_algo_data.(algorithm),2) + k;
            chemical_integrities_csv(index,1) = j;
            chemical_integrities_csv(index,2) = k;
            chemical_integrities_csv(index,3) = handles.molo_algo_data.(algorithm)(j,k).chemical_integrities;
            chemical_integrity_matrix(j,k) = handles.molo_algo_data.(algorithm)(j,k).chemical_integrities;

         end
         
    end
    
    h = bar(axes1,chemical_integrity_matrix');
    l = cell(1,3);
    l{1}='MoloLine 1';
    l{2}='MoloLine 3';
    l{3}='MoloLine 4';
    legend(h,l,'Location','North');
    legend boxoff
    xlabel('Horizontal Position of molograms');
    ylabel('Chemical Integrity []');
    
    name = strcat(handles.path,'/Evaluation/Plots/', algorithm, '_chemical_integrities.png');
    
    print(figure1,name,'-dpng')
    
    csvwrite_with_headers(strcat(handles.path,'/Evaluation/csv_files/', handles.experiment_name, '_', algorithm, '_chemical_integrities.txt'),chemical_integrities_csv,header);
    save(strcat(handles.path,'/Evaluation/mat_files/', handles.experiment_name, '_', algorithm, '_chemical_integrities.mat'),'chemical_integrity_matrix');




end