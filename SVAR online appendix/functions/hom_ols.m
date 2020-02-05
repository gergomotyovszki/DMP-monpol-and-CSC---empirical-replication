function [betahat,vbeta,se_beta,ser,rbarsq] = hom_ols(y,x);
%{
     Modified by MWW, 5-12-2017

     Homoskedasticity-only OLS

Input:
     y = tx1
     x = txk
     
Output:
     Beta = OLS estimate of beta (kx1)
    VBeta = Estimate of covariance matrix of beta (kxk)
           

%}
xx=x'*x;
xxi = inv(xx);
betahat=x\y;
u=y-x*betahat;
y_m = y - mean(y);
tss = y_m'*y_m;
ess = u'*u;
ndf = size(x,1)-size(x,2);
ser = sqrt(ess/ndf);
vbeta=(ess/ndf)*xxi;
rbarsq = 1 - (ess/ndf)/(tss/(size(x,1)-1));
se_beta = sqrt(diag(vbeta));


end