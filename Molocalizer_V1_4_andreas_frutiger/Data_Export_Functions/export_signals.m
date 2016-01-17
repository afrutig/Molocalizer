function export_signals(handles,algorithm)
    
% exports and saves the plots of the signal data for the algorithm
% specified by algorithm.
    
    
    signals_csv = zeros(length(handles.molo_algo_data.(algorithm)(1,1).signal),(1+size(handles.molo_algo_data.(algorithm),1)*size(handles.molo_algo_data.(algorithm),2)));
    header = cell((1+size(handles.molo_algo_data.(algorithm),1)*size(handles.molo_algo_data.(algorithm),2)),1);
    header{1} = 'Time';
    signals_csv(:,1) = handles.time;
    
    styles = 'rbg';
    figure1 = figure('Visible','off');
    hold on;
    
    
    line_numbers = [1,3,4];
    
    for j = 1:size(handles.molo_algo_data.(algorithm),1)
         
         for k = 1:size(handles.molo_algo_data.(algorithm),2)
             
             index = 1+(j-1)*size(handles.molo_algo_data.(algorithm),2) + k;
             
             header{index} = strcat(num2str(j) ,':', num2str(k));
             
             signals_csv(:,index) = handles.molo_algo_data.(algorithm)(j,k).signal;
             
             
             if k == size(handles.molo_algo_data.(algorithm),2)
                 
                 h(j) =  plot(handles.time,handles.molo_algo_data.(algorithm)(j,k).signal,'Linewidth',1,'Color',styles(j));
               
             else
               
               plot(handles.time,real(handles.molo_algo_data.(algorithm)(j,k).signal),'Linewidth',1,'Color',styles(j));
               
             end
             
         end
         
         set(h(j),'DisplayName',strcat('MoloLine' ,num2str(line_numbers(j))));
         
    end
    
    xlabel('Time [s]');
    ylabel('MoloSignal a.u.');

    legend(h,'Location','NorthWest');
    legend boxoff
    hold off;
    handles.experiment_name
    
    % for the standard algorithm Volker did not want to have the
    % algorithm labeling, here is a workaround
    if strcmp(algorithm,'iter_sig_area_inc_3std')
           
         algorithm = '';
            
    end
    
    name = strcat(handles.path,'/Evaluation/Plots/', handles.experiment_name, '_', algorithm, '_signals.png');
    
    print(figure1,name,'-dpng')
    
    csvwrite(strcat(handles.path,'/Evaluation/csv_files/', handles.experiment_name, '_', algorithm, '_signals.txt'),signals_csv);

end

