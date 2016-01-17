function  molo = calc_chemical_integrities_and_normalize_signal(Norm_Lower_ind_confirmed,Norm_Upper_ind_confirmed,molo,Norm_Conc)

%   Calculates the chemical integrities of the molograms. 


% Postconditions:
% - molo.chemical_integrity Units [uM]: matrix of the shape of the molo signals, which
% doubles corresponding to the chemical integrity of the mologram.
% - molo.sqrt_signal: the original signal minus an offset and square root
% taken from that
% - molo.norm_signal: Normalized Molography signal. 


 

for i = 1:size(molo,1)
    
    
    for j = 1:size(molo,2)
        
        % get the real values of the signal
            signal = molo(i,j).signal;
            molo(i,j).sqrt_signal = zeros(size(molo(i,j).signal));
        % signal is a vector of length time.
        % that is not the index...
            
            
            % substract the offset from the signal and only then you can
            % take the square root!! 
            avg_lower_square = mean(signal(Norm_Lower_ind_confirmed));
            
            sig_minus_offset = signal - avg_lower_square;
            
            % this is a bit black magic but I check whether the value in
            % the square root is negative and preserve the sign.
           
            
            for k = 1:length(sig_minus_offset)
                
                if sig_minus_offset(k) < 0
                   
                    molo(i,j).sqrt_signal(k) = -sqrt(-sig_minus_offset(k));
                    
                else
                    molo(i,j).sqrt_signal(k) = sqrt(sig_minus_offset(k));
                end
                
                
            end
            
            
            % er = 0; % for testing purposes
            avg_upper_sqrt = mean(molo(i,j).sqrt_signal(Norm_Upper_ind_confirmed));
            
            % That is right... all the signals need to be the square root.

            molo(i,j).chemical_integrities = Norm_Conc/(avg_upper_sqrt);
            molo(i,j).norm_signal = molo(i,j).sqrt_signal*molo(i,j).chemical_integrities;
        
        
    end
    
end

    


end

