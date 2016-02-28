function molo = calc_LOD(params,Norm_conc,molo)
% This function calculates the limit of detection for the quadratic signal
% for two locations, one is at the lower limit of normalization, the other
% one at the injection of the norm concentration.

% In addition, it calculates detrends the LOD and

% Preconditions: 
% - molo.signal_minus_offset  (in calc_sqrt_signals)

% Postconditions:
% - molo.upper_LOD (LOD calculated at the Upper_ind_confirmed)
% - molo.lower_LOD (LOD calculated from baseline noise)

Norm_Lower_ind_confirmed = params.Norm_Lower_ind_confirmed;
Norm_Upper_ind_confirmed = params.Norm_Upper_ind_confirmed;

if isfield(params,'LOD_fields')
   
    LOD_fields = params.LOD_fields;
    
end


for i = 1:size(molo,1)
    
    
    for j = 1:size(molo,2)
            
            signal = molo(i,j).signal_minus_offset;
            
            
            % here the signal is also detrended, because any trend would
            % artifically increase the Std of the signal
            
            Sig_Norm_lower = signal(Norm_Lower_ind_confirmed);
            Mean_lower = mean(Sig_Norm_lower);
            Sig_Norm_lower = detrend(Sig_Norm_lower);
            Std_lower = std(Sig_Norm_lower);
            
            Sig_Norm_Upper = signal(Norm_Upper_ind_confirmed);
            Mean_Upper = mean(Sig_Norm_Upper);
            Sig_Norm_Upper = detrend(Sig_Norm_Upper);
            Std_Upper = std(Sig_Norm_Upper);
            molo(i,j).lower_LOD = (sqrt((3*Std_lower+abs(Mean_lower))/Mean_Upper)-sqrt(abs(Mean_lower)/Mean_Upper))*Norm_conc;
            molo(i,j).upper_LOD = (sqrt((3*Std_Upper+Mean_Upper)/Mean_Upper)-1)*Norm_conc;
            
            if isfield(params,'LOD_fields')
   

            % loop here through all detrended fields
            
            molo(i,j).LOD = [];
            LOD = zeros(1,length(LOD_fields));
            
            for k = 1:length(LOD_fields)

                LOD_signal_area = signal(LOD_fields{k});
                LOD_mean = mean(LOD_signal_area);
                LOD_signal_area = detrend(LOD_signal_area);
               	LOD_std = std(LOD_signal_area);
                LOD = (sqrt((3*LOD_std+abs(LOD_mean))/Mean_Upper)-sqrt(abs(LOD_mean)/Mean_Upper))*Norm_conc;
                
            end
            
            molo(i,j).LOD = LOD;
            
              
            end
            

            
    end
    
end


end

