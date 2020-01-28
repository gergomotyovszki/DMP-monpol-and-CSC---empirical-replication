function [AIC, HQ, BIC]=selectIC(dat,nlags,nvars,totnobs);
%dat is a set of analysing variables
%nlags is a maximal number of lags
%nvars is a number of variables
%totnobs is a total number of observations
AIC=zeros(nlags,1);
HQ=zeros(nlags,1);
BIC=zeros(nlags,1);
for k=1:nlags
depnobs = totnobs - k;
ncoeffs = nvars*k;
nparams = nvars*ncoeffs; % # OF TOTAL NUMBER OF ESTIMATED PARAMETERS 
df = depnobs - ncoeffs;
y = zeros(depnobs,nvars);
y(:,:) = dat((k+1):totnobs,:);

% SET UP INDEPENDENT VARIABLES 
x = zeros(depnobs,nvars);
i = 1;  
while i <= nvars;
   j = 1;  
   while j <= k;        
      x(:,j+((i-1)*k)) = dat(k+1-j:totnobs-j,i);
      j = j+1;
   end;   
   i = i+1; 
end;

sizex=size(x);
sizey=size(y);

xxx = inv(x'*x); % x'x matrix
sizexxx=size(xxx);
b = xxx*(x'*y); % ols estimator
sizexy=size(x'*x);
sizeb=size(b);
res = y - x*b;   % ols residuals
sizeres=size(res);
t=size(res,1);
vmat = (1/depnobs)*(res'*res);  %vcov of residuals
AIC(k,1) = log(det(vmat)) + 2*k*(nvars^2)/t;                                               % Akaike Information Criteria
HQ(k,1)  = log(det(vmat)) + 2*log(log(t))*k*(nvars^2)/t;                                   % Hannan & Quinn  
BIC(k,1) = log(det(vmat)) + log(t)*k*(nvars^2)/t; 

clear xxx yy xx res depnobs ncoeffs nparams df b vmat
end

p=1:1:nlags;
%disp('       Lag      AIC      HQ      BIC')
%disp([p' AIC HQ BIC])



