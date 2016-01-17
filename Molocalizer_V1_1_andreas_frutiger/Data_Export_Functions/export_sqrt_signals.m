function export_sqrt_signals(handles,algorithm)
    
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
             
             signals_csv(:,index) = handles.molo_algo_data.(algorithm)(j,k).sqrt_signal;
             
             
             if k == size(handles.molo_algo_data.(algorithm),2)
                 
                 h(j) =  plot(handles.time,handles.molo(j,k).sqrt_signal,'Linewidth',1,'Color',styles(j));
               
             else
               
               plot(handles.time,real(handles.molo(j,k).sqrt_signal),'Linewidth',1,'Color',styles(j));
               
             end
             
         end
         
         set(h(j),'DisplayName',strcat('MoloLine' ,num2str(line_numbers(j))));
         
    end
    
    xlabel('Time [s]');
    ylabel('Sqrt(MoloSignal) a.u.');

    legend(h,'Location','NorthWest');
    legend boxoff
    hold off;
    
    name = strcat(handles.path,'/Evaluation/Plots/', algorithm, '_sqrt_signals.png');
    
    print(figure1,name,'-dpng')
    
    csvwrite_with_headers(strcat(handles.path,'/Evaluation/csv_files/', algorithm, '_sqrt_signals.txt'),signals_csv,header);

end
