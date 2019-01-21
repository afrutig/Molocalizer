function molo = calculate_surface_mass_density(molo,damping_constant)
    % this calculates the equivalent coherent surface mass densities according to formula no 11
    % in the Paper Principles for sensitive and robust biomolecular interaction analysis: The Limits of Detection and Resolution of Diffraction-Limited Focal Molography [pg]/[mm]^2
    % function is hardcoded for water
    % this gives an average surface mass density on the mologram.
    % j is the number of the mololine
    % k the kth mologram in line j
    % attention if only two mololines are supplied the wrong diameter might be used. 
    
    detector_noise = 220; % this is the mean detector signal, if there is no light in the waveguide (dark noise), it is an offset that is added to the readout of the detector it is this value.
    lambda = 632.8*1e-9; % m
    dn_dc = 0.182*1e-3; % m^3/kg
    n_c = 1.33; % unitless
    n_s = 1.521; % unitless
    n_f = 2.117; % unitless
    N = 1.814; % unitless
    A_scat = damping_constant*1000; % m^-1
    t_eff = 329*1e-9; % m the effective mode thickness
    pixelsize = 12.5*1e-6 % m
    
    
    
    if size(molo,1) < 3

        msgbox('Number of mololines is less than 3, the diameter calculation might be incorrect for the surface mass density modulation calculation.')
    end
    
    for j = 1:size(molo,1)

        for k = 1:size(molo,2)

            % account for differently sized molograms
            if j == 3
    
                D = 0.256*1e-3; % m %the effective diameters would be: 256 and 357 um for the small and big molograms, respectively. 
   
                D_footprint = 0.300*1e-3;
                NA = sin(atan(D_footprint/(2*592*1e-6)));
                
            else
                D = 0.357*1e-3;
                D_footprint = 0.4*1e-3;
                NA = sin(atan(D_footprint/(2*592*1e-6)));

            end
            A_airy = 1.16*lambda^2/NA^2
            A_mologram = pi*D^2/4;
            A_ridges = A_mologram/2;
            A_footprint = pi*D_footprint^2/4;
            
            P_diff = molo(j,k).signal/A_airy;
            P_scat = (molo(j,k).background - detector_noise)/(pixelsize^2); 

            % molo(j,k).surface_mass_densities_mod = sqrt(P_diff./P_scat/(dN_dn0*64/lambda^5*n0*ns^2*Lambda*D^2/A_scat *(dn_dc)^2))*10^(-4); % 10^-4 is the correction factor that arises from unit conversions
            
            % try to compute the mass densities according to the paper
            % "Principles of 
            a_ani = 0.054; 
            FOM_FM = D^2/lambda^4*n_c*(n_f^2-N^2)/(N*t_eff*(n_f^2-n_c^2)*a_ani*A_scat);
            Gamma_0 = 0.1056*A_ridges/A_footprint*1/sqrt(FOM_FM)*1/dn_dc;
            Gamma = Gamma_0*sqrt(P_diff./P_scat);

            
            molo(j,k).surface_mass_densities_mod = Gamma*1e9; % is not the surface mass density modulation but the equivalent coherent mass density
            molo(j,k).surface_mass_densities_mod;
        end
        
    end
     
    
    
    
end