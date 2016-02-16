function save_processed_log_in(handles)
%% log_injection 
% This function gets the Digital input value of an attached arduino (Pin
% 13) and writes it to a file in Evaluation/Injection_log.txt
% It waites for 2 seconds after an injection.
% The file continues for infinity time.



fid = fopen(strcat(handles.path,'/Evaluation/Injection_Log_processed.txt'), 'wt');


for i = 1:length(handles.Injection_times)  
    
    handles.Injection_times(i);
    
    fprintf(fid, '%s\n',strcat(num2str(i),';',num2str(handles.Injection_times(i))));

end

fclose(fid);
