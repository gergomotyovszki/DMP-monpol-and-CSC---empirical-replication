function out = lagmat(inputmat,P)
%-----------------------------------------------------------------------------------------------
%                      Code by: J. Cloyne, C. Ferreira, P. Surico
%-----------------------------------------------------------------------------------------------
% This script generates lags of the vector / matrix inputmat

for j=1:P
        out(:,j) = inputmat(P+1-j:end-j,1);
end