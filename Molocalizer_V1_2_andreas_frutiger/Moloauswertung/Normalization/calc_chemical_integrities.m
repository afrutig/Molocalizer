function  molo = calc_chemical_integrities(Norm_Upper_ind_confirmed,molo)

%   Calculates the chemical integrities of the molograms. 
% Preconditions: 
% molo.sqrt_signals need to be calculated.

% Postconditions:
% - molo.chemical_integrities: matrix of the shape of the molo signals, which
% doubles corresponding to the chemical integrity of the mologram.

 
for i = 1:size(molo,1)
    
    
    for j = 1:size(molo,2)
        
            avg_upper_sqrt = mean(molo(i,j).sqrt_signal(Norm_Upper_ind_confirmed));
            
            molo(i,j).chemical_integrities = avg_upper_sqrt;
        
    end
    
end

    


end

