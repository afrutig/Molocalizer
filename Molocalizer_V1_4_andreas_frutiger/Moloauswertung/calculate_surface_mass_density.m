function molo = calculate_surface_mass_density(molo,damping_constant)
    % this calculates the surface mass densities according to formula no 10
    % in the Paper Focal Molography: Coherent Microscopic Detection of Biomolecular Interaction
    % the units of the surface mass density modulation is in [pg]/[mm]^2

    % this gives an average surface mass density on the mologram.
    % j is the number of the mololine
    % k the kth mologram in line j
    % attention if only two mololines are supplied the wrong diameter might be used. 
    
    detector_noise = 210; % this is the mean detector signal, if there is no light in the waveguide (dark noise)
    lambda = 635; % nm
    Lambda = 477; % nm
    dN_dn0 = 0.08; % unitless
    dn_dc = 0.182; % ml/g
    n0 = 1.33; % unitless
    ns = 1.521; % unitless
    D = 0.3666; % mm %the effective diameters would be: 266,6 and 366.6 um for the small and big molograms, respectively. 
    A_scat = damping_constant; % mm^-1
    delta_z = 82; % nm
    
    
    if size(molo,1) < 3

        msgbox('Number of mololines is less than 3, the diameter calculation might be incorrect for the surface mass density modulation calculation.')
    end
    
    for j = 1:size(molo,1)

        for k = 1:size(molo,2)

            % account for differently sized molograms
            if j == 3

                D = 0.2666

            else
                D = 0.3666
            end

            P_diff = molo(j,k).signal;
            P_scat = molo(j,k).background - detector_noise;

            molo(j,k).surface_mass_densities_mod = sqrt(P_diff./P_scat/(dN_dn0*64/lambda^5*n0*ns^2*Lambda*D^2/A_scat *(dn_dc)^2))*10^(-4); % 10^-4 is the correction factor that arises from unit conversions
            
        end
        
     end
    
    
end