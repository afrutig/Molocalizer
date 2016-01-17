function log_injection(path)
%% log_injection 
% This function gets the Digital input value of an attached arduino (Pin
% 13) and writes it to a file in Evaluation/Injection_log.txt
% It waites for 2 seconds after an injection.
% The file continues for infinity time.


a = arduino;


Injection_number = 1;


fid = fopen(strcat(path,'/Evaluation/Injection_log.txt'), 'a');



while true
    
    value = readDigitalPin(a,'D13');
  
    
    if value == 1
       
       fprintf(fid, '%s\n',strcat(num2str(Injection_number),';',datestr(datetime)));
       strcat('Injectionnumber:', num2str(Injection_number), 'Time:', datestr(datetime))
       pause(2)
       Injection_number = Injection_number + 1;
       
    end
        

end

fclose(fid);

clear a
