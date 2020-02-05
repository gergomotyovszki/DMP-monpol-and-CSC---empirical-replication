function [dx] = dif(x,p)
% Form x(t) - x(t-p) with missing values for initial conditions 
 nr = size(x,1);
 dx = NaN*zeros(size(x));
 dx(p+1:nr,:) = x(p+1:nr,:)-x(1:nr-p,:);
end

