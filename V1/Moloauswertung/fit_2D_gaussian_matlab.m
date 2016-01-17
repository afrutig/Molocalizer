%% fitting an arbitrary 2D function to a two D distribution
function Z = fit_2D_gaussian_matlab(X,Y,A,a,b,c,x0,y0)
% this function fits a two dimensional gaussian function to image data with
% a peak in the middle of the image and a linear trend in x and an constant
% offset. 


Z =  A*exp(-(a*(X-x0).^2 + 2*b*(X-x0).*(Y-y0) + c*(Y-y0).^2));

end