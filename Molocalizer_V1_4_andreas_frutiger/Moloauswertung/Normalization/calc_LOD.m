function molo = calc_LOD(Norm_Lower_ind_confirmed,Norm_Upper_ind_confirmed,Norm_conc,molo)
% This function calculates the limit of detection for the quadratic signal
% for two locations, one is at the lower limit of normalization, the other
% one at the injection of the norm concentration.

% Preconditions: 
% - molo.signal_minus_offset  (in calc_sqrt_signals)

% Postconditions:
% - molo.upper_LOD (LOD calculated at the Upper_ind_confirmed)
% - molo.lower_LOD (LOD calculated from baseline noise)


for i = 1:size(molo,1)
    
    
    for j = 1:size(molo,2)
            
            signal = molo(i,j).signal_minus_offset;
            
            Sig_Norm_lower = signal(Norm_Lower_ind_confirmed);
            Mean_lower = mean(Sig_Norm_lower)
            Std_lower = std(Sig_Norm_lower)
            
            
            
            Sig_Norm_Upper = signal(Norm_Upper_ind_confirmed);
            Mean_Upper = mean(Sig_Norm_Upper)
            Std_Upper = std(Sig_Norm_Upper)
            molo(i,j).lower_LOD = (sqrt((3*Std_lower+abs(Mean_lower))/Mean_Upper)-sqrt(abs(Mean_lower)/Mean_Upper))*Norm_conc;
            molo(i,j).upper_LOD = (sqrt((3*Std_Upper+Mean_Upper)/Mean_Upper)-1)*Norm_conc;

          
        
    end
    
end


end

