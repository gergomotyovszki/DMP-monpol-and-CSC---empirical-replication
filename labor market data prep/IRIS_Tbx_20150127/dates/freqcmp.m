function Flag = freqcmp(X,Y)
% freqcmp  Compare date frequencies.
%
% Syntax
% =======
%
%     Flag = freqcmp(D1,D2)
%
% Input arguments
% ================
%
% * `D1`, `D2` [ numeric ] - IRIS serial date numbers.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True for dates of the same frequency.
%
% Description
% ============
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

try
    Y; %#ok<VUNUS>
catch
    if ~isempty(X)
        Y = X(1);
    else
        Y = X;
    end
end

%--------------------------------------------------------------------------

if isa(X,'tseries')
    X = startdate(X);
end

if isa(Y,'tseries')
    Y = startdate(Y);
end

ixXInf = isinf(X);
ixYInf = isinf(Y);

fx = inf(size(X));
fy = inf(size(Y));

fx(~ixXInf) = datfreq(X(~ixXInf));
fy(~ixYInf) = datfreq(Y(~ixYInf));

Flag = fx == fy | isinf(fx - fy);

end
