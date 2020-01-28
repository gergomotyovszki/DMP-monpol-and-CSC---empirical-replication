function Freq = datfreq(Dat)
% datfreq  Frequency of IRIS serial date numbers.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

Freq = round(100*(Dat - floor(Dat)));

ixDaily = Freq == 0 & Dat >= 365244;
Freq(ixDaily) = 365;

end
