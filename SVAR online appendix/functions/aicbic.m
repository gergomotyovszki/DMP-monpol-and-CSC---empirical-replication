function [aic, bic, hqc, a] = aicbic(y,pmax)
[T,N] = size(y);
for p = 1:pmax
[beta, e] = myvar(y, p);

a(p) = log(det((e'*e)/T));
b = p*N^2/T;
aic(p) = a(p) + 2*b;
bic(p) = a(p) + log(T)*b;
hqc(p) = a(p) +  2*b*log(log(T));
end
[minaic,aic] = min(aic);
[minbic,bic] = min(bic);
[minhqc,hqc] = min(hqc);