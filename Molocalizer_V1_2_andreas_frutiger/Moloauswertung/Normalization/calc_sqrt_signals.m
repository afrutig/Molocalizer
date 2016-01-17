function  molo = calc_sqrt_signals(molo)

%Preconditions: molo.molo_offset needs to exist (lower normalization of the
%molographci signals need to be performed already.

% Postconditions:
% - molo.sqrt_signals is calculated. Important, square root signal is
% already a preprocessed signal, namely the offset is substracted before
% the operation. 

for i = 1:size(molo,1)
    
    for j = 1:size(molo,2)
        
            % this all needs to be in a separate function. 
            molo(i,j).sqrt_signal = zeros(size(molo(i,j).signal));
            
            molo(i,j).signal_minus_offset = molo(i,j).signal - molo(i,j).molo_offset;
                        
            for k = 1:length(molo(i,j).signal_minus_offset)
                
                if molo(i,j).signal_minus_offset(k) < 0
                   
                    molo(i,j).sqrt_signal(k) = -sqrt(-molo(i,j).signal_minus_offset(k));
                    
                else
                    molo(i,j).sqrt_signal(k) = sqrt(molo(i,j).signal_minus_offset(k));
                end
                              
            end
            
    end
    
end

    


end

