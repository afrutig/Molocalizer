function save_datalog(handles)
    
fid = fopen(strcat(handles.path,'/Evaluation/Experiment_log.txt'), 'a');

for i=1:length(handles.Consolecontent)

    fprintf(fid, '%s\n', handles.Consolecontent{i});

    
    
    
end

fclose(fid);

    

end