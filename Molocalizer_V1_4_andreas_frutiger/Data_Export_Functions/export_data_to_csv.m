function export_data_to_csv(data_field,ylabel_text,handles,algorithm)
    
% exports and saves the plots of the signal data for the algorithm
% specified by algorithm.
% this exports, the signals, the sqrt_signals, the normalized molosignals,
% the background signals as well as the pg/mm^2 of all the molograms
% add here the standard deviation plots as well.

    molo_data = handles.molo_algo_data.(algorithm)


    data_to_csv = zeros(length(getfield(molo_data(1,1),data_field)),(1+size(molo_data,1)*size(molo_data,2)));
    
    data_to_csv(:,1) = handles.time;
    
    styles = 'rbg';
    figure1 = figure('Visible','off');
    hold on;
    
    line_numbers = [1,3,4]; % only for naming the legend.
    
    % here I should add a plot that exports the standard deviation plots.
    
    for j = 1:size(molo_data,1)
         
         for k = 1:size(molo_data,2)
             
             index = 1+(j-1)*size(molo_data,2) + k;
             
             data_to_csv(:,index) = getfield(molo_data(j,k),data_field);

             if k == size(molo_data,2)
                 
                h(j) =  plot(handles.time,getfield(molo_data(j,k),data_field),'Linewidth',1,'Color',styles(j));
               
             else
               
               plot(handles.time,real(getfield(molo_data(j,k),data_field)),'Linewidth',1,'Color',styles(j));
               
             end
             
         end
         
         set(h(j),'DisplayName',strcat('MoloLine' ,num2str(line_numbers(j))));
         
    end
    
    xlabel('Time [s]','interpreter','tex','FontName','Arial');
    ylabel(ylabel_text,'interpreter','tex','FontName','Arial');
    legend(h,'Location','NorthWest');
    legend boxoff
    hold off;
    
    
    
    % for the standard algorithm Volker did not want to have the
    % algorithm labeling, here is a workaround
    
    if strcmp(algorithm,'iter_sig_area_inc_3std')
           
         algorithm = '';
            
    end
    
    name = strcat(handles.path,'/Evaluation/Plots/', handles.experiment_name, '_' , data_field, '.png');
    
    print(figure1,name,'-dpng')
    
    csvwrite(strcat(handles.path,'/Evaluation/csv_files/', handles.experiment_name, '_', algorithm, '_' , data_field,'.txt'),data_to_csv);

end

