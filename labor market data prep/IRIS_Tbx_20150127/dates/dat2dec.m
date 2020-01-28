function Dec = dat2dec(Dat,Pos)
% dat2dec  Convert dates to decimal grid.
%
% Syntax
% =======
%
%     Dec = dat2dec(Dat)
%     Dec = dat2dec(Dat,Pos)
%
% Input arguments
% ================
%
% * `Dat` [ numeric ] - IRIS serial date number.
%
% * `Pos` [ *`'start'`* | `'centre'` | `'end'` ] - Point within the period
% that will represent the date; if omitted, `Pos` is set to `'start'`.
%
% Output arguments
% =================
%
% * `Dec` [ numeric ] - Decimal grid representing the input dates,
% computed as `Year + (Per-1)/Freq`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

try
    Pos; %#ok<VUNUS>
catch
    Pos = 's';
end
Pos = lower(Pos(1));

%--------------------------------------------------------------------------

Dec = nan(size(Dat));
[year,per,freq] = dat2ypf(Dat);

ixZero = freq == 0;
ixWeekly = freq == 52;
ixDaily = freq == 365;
ixRegular = ~ixZero & ~ixWeekly & ~ixDaily;

% Regular frequencies
%---------------------
if any(ixRegular(:))
    switch Pos
        case {'s','b'}
            adjust = -1;
        case {'c','m'}
            adjust = -1/2;
        case {'e'}
            adjust = 0;
        otherwise
            adjust = -1;
    end
    Dec(ixRegular) = year(ixRegular) ...
        + (per(ixRegular) + adjust) ./ freq(ixRegular);
end

% Weekly frequency
%------------------
if any(ixWeekly(:))
    switch Pos
        case {'s','b'}
            standinDay = 'Monday';
        case {'c','m'}
            standinDay = 'Thursday';
        case {'e'}
            standinDay = 'Sunday';
        otherwise
            standinDay = 'Monday';
    end
    x = ww2day(Dat(ixWeekly),standinDay);
    Dec = day2dec(x);
end

% Unspecified frequency
%-----------------------
if any(ixZero(:))
    Dec(ixZero) = per(ixZero);
end

% Daily frequency
%-----------------
if any(ixDaily(:))
    Dec(ixDaily) = per(ixDaily);
end

end
