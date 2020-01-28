function X = arma(E,Ar,Ma,Range)
% arma  Apply ARMA model to input series.
%
% Syntax
% =======
%
%     X = arma(E,Ar,Ma)
%     X = arma(E,Ar,Ma,Range)
%
% Input arguments
% ================
% 
% * `E` [ tseries ] - Input time series that will be run through an ARMA
% model.
%
% * `Ar` [ numeric | empty ] - Row vector of AR coefficients; if empty, `Ar
% = 1`; see Description.
%
% * `Ma` [ numeric | empty ] - Row vector of MA coefficients; if empty, `Ma
% = 1`; see Description.
%
% * `Range` [ numeric | `@auto` ] - Range on which the input series will be
% constructed; if not specified or `@auto`, the range will be determined
% based on the input time series, `E`.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output time series constructed by running an ARMA
% model through the input series.
%
% Options
% ========
%
% Description
% ============
%
% The output series is constructed as follows:
%
% $$ A(L) X_t = M(L) E_t $$
%
% where $A(L)$ and $M(L)$ are polynomials in lag operator defined by the
% vectors `Ar` and `Ma`. In other words,
%
%     X(t) = ( -Ar(2)*X(t-1) - Ar(3)*X(t-2) - ...
%            + Ma(1)*E(t) + Ma(2)*E(t-1) + ... ) / Ar(1);
%
% Example
% ========
%
% Construct an AR(1) process with autoregression coefficient 0.8, based on
% normally distributed innovations.
%
%     E = tseries(1:20,@randn);
%     X = arma(E,[1,-0.8],[]);
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

try
    Range; %#ok<VUNUS>
catch
    Range = @auto;
end

Ar = Ar(:).';
if isempty(Ar)
    Ar = 1;
end

Ma = Ma(:).';
if isempty(Ma)
    Ma = 1;
end

%--------------------------------------------------------------------------

pa = length(Ar) - 1;
pm = length(Ma) - 1;
p = max(pa,pm);
if isequal(Range,@auto)
    xRange = range(E);
else
    xRange = Range(1)-p : Range(end);
end
nXPer = length(xRange);

E = rangedata(E,xRange);
E(isnan(E)) = 0;
X = zeros(size(E));

for t = p+1 : nXPer
    X(t,:) = ( -Ar(2:end)*X(t-1:-1:t-pa,:) ...
        + Ma*E(t:-1:t-pm,:) ) / Ar(1);
end

X = tseries(xRange(1),X);

end
