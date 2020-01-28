function NewDat = convert(Dat,ToFreq,varargin)
% convert   Convert dates to another frequency.
%
% Syntax
% =======
%
%     NewDat = convert(Dat,NewFreq,...)
%
% Input arguments
% ================
%
% * `Dat` [ numeric ] - IRIS serial date numbers that will be converted to
% the new frequency, `NewFreq`.
%
% * `NewFreq` [ `1` | `2` | `4` | `6` | `12` | `52` | `365` ] - New
% frequency to which the dates `d1` will be converted.
%
% Output arguments
% =================
%
% * `NewDat` [ numeric ] - IRIS serial date numbers representing the new
% frequency.
%
% Options
% ========
%
% * `'standinMonth='` [ numeric | `'last'` | *`1`* ] - Month that will be
% used to represent a certain period of time in low- to high-frequency
% conversions.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% Parse options.
opt = passvalopt('dates.convert',varargin{:});
opt = datdefaults(opt);

pp = inputParser();
pp.addRequired('Dat',@isnumeric);
pp.addRequired('NewFreq',@(x) isnumericscalar(x) ...
    && any(x == [1,2,4,6,12,52,365]));
pp.parse(Dat,ToFreq);

%--------------------------------------------------------------------------

fromFreq = datfreq(Dat);
ixFromZero = fromFreq == 0;
ixFromDaily = fromFreq == 365;
ixFromWeekly = fromFreq == 52;
ixFromRegular = ~ixFromZero & ~ixFromWeekly & ~ixFromDaily;

NewDat = nan(size(Dat));

if any(ixFromRegular(:))
    % Get year, period, and frequency of the original dates.
    [fromYear,fromPer,fromFreq] = dat2ypf(Dat(ixFromRegular));
    toYear = fromYear;
    % First, convert the original period to a corresponding month.
    toMon = per2month(fromPer,fromFreq,opt.standinmonth);
    % Then, convert the month to the corresponding period of the request
    % frequnecy.
    toPer = ceil(toMon.*ToFreq./12);
    % Create new dates.
    if ToFreq == 365
        NewDat(ixFromRegular) = dd(toYear,toMon,1);
    else
        NewDat(ixFromRegular) = datcode(ToFreq,toYear,toPer);
    end
end

if any(ixFromWeekly(:))
    if ToFreq == 365
        x = ww2day(Dat(ixFromWeekly),opt.wwday);
        NewDat(ixFromWeekly) = x;
    else
        x = ww2day(Dat(ixFromWeekly),'Thu');
        [toYear,toMon] = datevec(x);
        toPer = ceil(toMon.*ToFreq./12);
        NewDat(ixFromWeekly) = datcode(ToFreq,toYear,toPer);
    end
end

if any(ixFromDaily(:))
    if ToFreq == 365
        NewDat(ixFromDaily) = Dat(ixFromDaily);
    elseif ToFreq == 52
        NewDat(ixFromDaily) = day2ww(Dat(ixFromDaily));
    else
        [toYear,toMon,~] = datevec(Dat(ixFromDaily));
        toPer = ceil(toMon.*ToFreq./12);
        NewDat(ixFromDaily) = datcode(ToFreq,toYear,toPer);
    end
end

end
