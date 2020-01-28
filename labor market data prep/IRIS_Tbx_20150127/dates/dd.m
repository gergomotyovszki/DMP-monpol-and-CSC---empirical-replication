function Dat = dd(Year,Month,Day)
% dd  Matlab serial date numbers that can be used to construct daily tseries objects.
%
% Syntax
% =======
%
%     Dat = dd(Year,Month,Day)
%     Dat = dd(Year,Month,'end')
%     Dat = dd(Year,Month)
%     Dat = dd(Year)
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers.
%
% Input arguments
% ================
%
% * `Year` [ numeric ] - Year.
%
% * `Month` [ numeric ] - Calendar month in year; if missing, `Month` is
% `1` by default.
%
% * `Day` [ numeric ] - Calendar day in month; if missing, `Day` is `1` by
% default; `'end'` means the end day of the respective month.
%
% Description
% ============
%
% Example
% ========
%
%     >> d = dd(2010,12,3)
%     d =
%           734475
%     >> dat2str(d)
%     ans =  
%         '2010-Dec-03'
% 

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin < 2
    Month = 1;
end

if nargin < 3
    Day = 1;
elseif strcmpi(Day,'end')
    Day = eomday(Year,Month);
end

Dat = datenum(Year,Month,Day);

end
