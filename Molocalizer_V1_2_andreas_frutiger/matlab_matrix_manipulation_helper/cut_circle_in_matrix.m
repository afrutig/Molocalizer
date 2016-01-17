function A = cut_circle_in_matrix(A,r,x0,y0,c)

% this function cuts a circle in a matrix A and fills all the values in the
% circle with NaN values and if c=true, then all the values outside the
% circle specified by radius r and a center point x0,y0
% convert to double that NaN values are stored. 
A = double(A);

mask = ones(size(A));

for k = 1:size(A,1)
            
        for l = 1:size(A,2)

            % check whether the point is inside the circle
            
            if c == true;
                
                if (k-ceil(x0))^2+(l-ceil(y0))^2 > (r)^2

                    mask(k,l) = 0;

                end
                
            else
                 if (k-ceil(x0))^2+(l-ceil(y0))^2 <= (r)^2

                    mask(k,l) = 0;

                end
                
            end


        end
             
end

A(logical(mask)) = NaN;





end