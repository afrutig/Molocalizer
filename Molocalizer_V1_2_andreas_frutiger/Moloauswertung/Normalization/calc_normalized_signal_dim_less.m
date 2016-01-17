function molo = calc_normalized_signal_dim_less(molo)

%   Calculates the normalied_signal of a mologram
% Preconditions: 
% molo.sqrt_signals need to be calculated.
% molo.chemical_integrities needs to be calculated

% Postconditions:
% - molo.chemical_integrities: matrix of the shape of the molo signals, which
% doubles corresponding to the chemical integrity of the mologram.

 
for i = 1:size(molo,1)
    
    
    for j = 1:size(molo,2)
            
            molo(i,j).norm_signal_dim_less = molo(i,j).sqrt_signal*1/molo(i,j).chemical_integrities;
        
    end
    
end

end

