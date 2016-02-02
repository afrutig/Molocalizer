function surface_mass_density_mod = calculate_surface_mass_density(signals,backgrounds,damping_constant)
    % this calculates the surface mass densities according to formula no 10
    % in the Paper Focal Molography: Coherent Microscopic Detection of Biomolecular Interaction
    % the units of the surface mass density modulation is in [pg]/[mm]^2
    lambda = 635; % nm
    Lambda = 477; % nm
    dN_dn0 = 0.08; % unitless
    dn_dc = 0.182; % ml/g
    n0 = 1.33; % unitless
    ns = 1.521; % unitless
    D = 0.4; % mm
    A_scat = damping_constant; % mm^-1
    delta_z = 82; % nm
    P_diff = signals;
    P_scat = backgrounds;
    
    
    
    surface_mass_density_mod = zeros(size(signals));
    
    for j = 1:size(signals,1)

        for k = 1:size(signals,2)
            
            surface_mass_density_mod(j,k) = sqrt(P_diff(j,k)/P_scat(j,k)/(dN_dn0*64/lambda^5*n0*ns^2*Lambda*D^2/A_scat *(dn_dc)^2))*10^(-4); % 10^-4 is the correction factor that arises from unit conversions
            
        end
        
     end
    
    
end