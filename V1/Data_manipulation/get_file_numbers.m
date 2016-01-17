function filenumbers = get_file_numbers(filenames)
%UNTITLED2 Summary of this function goes here
%   Extracts the filenumbers from the file names 
    
    filenumbers = zeros(1,length(filenames));

    % extract the number from the file string.

    for i = 1:length(filenumbers)

            hilf = filenames(i).name;
            first_split = strsplit(hilf,'_');
            hilf = (first_split{end});
            hilf = strsplit(hilf,'.');
            filenumbers(1,i) = str2num(hilf{1});
    end



end

