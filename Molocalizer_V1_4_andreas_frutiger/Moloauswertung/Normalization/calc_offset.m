function  molo = calc_offset(Norm_Lower_ind_confirmed,molo)

%   Calculates the offset off the signal


% Postconditions:
% - molo.molo_offset: the offset of each mologram that has to be
% substracted befor applying the scaling with the chemical integrities.

for i = 1:size(molo,1)
    
    for j = 1:size(molo,2)
   
            % this all needs to be in a separate function.
            signal = molo(i,j).signal;
            molo(i,j).molo_offset = mean(signal(Norm_Lower_ind_confirmed));
            
    end
    
end

end

