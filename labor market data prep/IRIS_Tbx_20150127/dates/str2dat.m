function [Dat,IsCalendar] = str2dat(String,varargin)
% str2dat  Convert strings to IRIS serial date numbers.
%
% Syntax
% =======
%
%     Dat = str2dat(S,...)
%
% Input arguments
% ================
%
% * `S` [ char | cellstr ] - Strings representing dates.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers.
%
% Options
% ========
%
% * `'freq='` [ `1` | `2` | `4` | `6` | `12` | `52` | `365` | *empty* ] -
% Enforce frequency.
%
% See help on [`dat2str`](dates/dat2str) for other options available.
%
% Description
% ============
%
% Example
% ========
%
%     d = str2dat('04-2010','dateFormat=','MM-YYYY');
%     dat2str(d)
%     ans =
%        '2010M04'
%
%     d = str2dat('04-2010','dateFormat=','MM-YYYY','freq=',4);
%     dat2str(d)
%     ans =
%        '2010Q2'
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

opt = passvalopt('dates.str2dat',varargin{:});
opt = datdefaults(opt);

%--------------------------------------------------------------------------

IsCalendar = false;
doDateFormat();

longMonthList = sprintf('%s|',opt.months{:});
longMonthList(end) = '';
shortMonthList = regexp(opt.months,'\w{1,3}','match','once');
shortMonthList = sprintf('%s|',shortMonthList{:});
shortMonthList(end) = '';
romanList = 'xii|xi|x|ix|viii|vii|vi|v|iv|iii|ii|i|iv|v|x';

if ischar(String)
    String = {String};
end

if isempty(String)
    Dat = nan(size(String));
    return
end

ptn = doPattern();
tkn = regexpi(String,ptn,'names','once');
[year,per,day,month,freq] = xxParseDates(tkn,IsCalendar,opt);

if IsCalendar
    ixDaily = freq == 365;
    ixWeekly = freq == 52;
    if any(ixDaily)
        Dat(ixDaily) = dd(year(ixDaily),month(ixDaily),day(ixDaily));
    end
    if any(ixWeekly)
        Dat(ixWeekly) = ww(year(ixWeekly),month(ixWeekly),day(ixWeekly));
    end
else
    Dat = datcode(freq,year,per);
    % Try indeterminate frequency for NaN dates.
    ixNan = find(isnan(Dat(:).'));
    for i = ixNan
        %aux = round(str2double(String{i}));
        aux = sscanf(String{i},'%g');
        aux = round(aux);
        if ~isempty(aux)
            Dat(i) = aux;
        end
    end
end


% Nested functions...


%**************************************************************************

    
    function x = doPattern()
        x = upper(opt.dateformat);
        x = regexptranslate('escape',x);
        x = regexprep(x,'(?<!%)\*','.*?');
        x = regexprep(x,'(?<!%)\?','.');
        subs = { ...
            '(?<!%)YYYY','(?<longyear>\\d{4})'; ... Four-digit year
            '(?<!%)YY','(?<shortyear>\\d{2})'; ... Last two digits of year
            '(?<!%)Y','(?<longyear>\\d{0,4})'; ... One to four digits of year
            '(?<!%)PP','(?<longperiod>\\d{2})'; ... Two-digit period
            '(?<!%)P','(?<shortperiod>\\d*)'; ... Any number of digits of period
            '(?<!%)MMMM',['(?<month>',longMonthList,')']; ... Full name of months
            '(?<!%)MMM',['(?<month>',shortMonthList,')']; ... Three-letter name of month
            '(?<!%)MM','(?<numericmonth>\\d{2})'; ... Two-digit month
            '(?<!%)M','(?<numericmonth>\\d{1,2})'; ... One- or two-digit month
            '(?<!%)Q',['(?<romanmonth>',romanList,')']; ... Roman numerals for month
            '(?<!%)R',['(?<romanperiod>',romanList,')']; ... Roman numerals for period
            '(?<!%)I','(?<indeterminate>\\d+)'; ... Any number of digits for indeterminate frequency
            '(?<!%)DD','(?<longday>\\d{2})'; ... Two-digit day
            '(?<!%)D','(?<varday>\\d{1,2})'; ... One- or two-digit day
            ... Frequency letters must be done last because they can include characters that would be substituted for.
            '(?<!%)F',sprintf('(?<freqletter>[%s])',opt.freqletters); ... Frequency letter
            };
        for ii = 1 : size(subs,1)
            x = regexprep(x,subs{ii,1},subs{ii,2});
        end
        x = regexprep(x,'%([YFPMQRID])','$1');
    end % doPattern()


%**************************************************************************
    
    
    function doDateFormat()
        if isequal(opt.freq,'daily')
            opt.freq = 365;
        end
        
        if isstruct(opt.dateformat)
            if isempty(opt.freq)
                opt.dateformat = opt.dateformat.qq;
            else
                opt.dateformat = mydateformat(opt.dateformat,opt.freq);
            end
        end
        
        if isequal(opt.freq,365) ...
            && ( ~isempty(opt.dateformat) && ~strncmp(opt.dateformat,'$',1) )
            opt.dateformat = ['$',opt.dateformat];
        end
        
        if strncmp(opt.dateformat,'$',1) && ...
            ( isempty(opt.freq) || isequal(opt.freq,0) )
            opt.freq = 365;
        end
        
        IsCalendar = false;
        if strncmp(opt.dateformat,'$',1)
            opt.dateformat(1) = '';
            IsCalendar = true;
        end
        
        validDateFormat = true;
        if IsCalendar
            if ~isequal(opt.freq,365) && ~isequal(opt.freq,52)
                validDateFormat = false;
            end
        else
            if isequal(opt.freq,365)
                validDateFormat = false;
            end
        end
        
        if ~validDateFormat
            utils.error('dates:str2dat', ...
                ['Inconsistent values for ''freq='' and ''dateFormat='' ', ...
                'options.']);
        end
    end % doDateFormat()
end


% Subfunctions...


%**************************************************************************


function [Year,Per,Day,Month,Freq] = xxParseDates(Tokens,IsCalendar,Opt)
[thisYear,~] = datevec(now());
thisCentury = 100*floor(thisYear/100);
freqVec = [1,2,4,6,12,52];
Freq = nan(size(Tokens));

% if `isCalendar` then `freq` is guaranteed to be either `365` or `52`; it
% cannot be empty.
if IsCalendar
    Freq(:) = Opt.freq;
end

Day = nan(size(Tokens));
% Set period to 1 by default so that e.g. YPF is correctly matched with
% 2000Y.
Per = ones(size(Tokens));
Month = nan(size(Tokens));
Year = nan(size(Tokens));



for i = 1 : length(Tokens)
    
    tkn = Tokens{i};
    if length(tkn) ~= 1
        continue
    end
    
    if ~IsCalendar
        if isfield(tkn,'indeterminate') ...
                && ~isempty(tkn.indeterminate)
            Freq(i) = 0;
            Per(i) = sscanf(tkn.indeterminate,'%g');
            continue
        end
        if isempty(Opt.freq) && ( ...
                (isfield(tkn,'longmonth') && ~isempty(tkn.longmonth)) ...
                || (isfield(tkn,'shortmonth') && ~isempty(tkn.shortmonth)) ...
                || (isfield(tkn,'numericmonth') && ~isempty(tkn.numericmonth)) )
            Freq(i) = 12;
        end
        if isfield(tkn,'freqletter') && ~isempty(tkn.freqletter)
            inx = upper(Opt.freqletters) == upper(tkn.freqletter);
            if any(inx)
                Freq(i) = freqVec(inx);
            end
        end
    end
    
    if isfield(tkn,'shortyear')
        yeari = sscanf(tkn.shortyear,'%g');
        yeari = yeari + thisCentury;
        if yeari - thisYear > 20
            yeari = yeari - 100;
        elseif yeari - thisYear <= -80
            yeari = yeari + 100;
        end
        Year(i) = yeari;
    end
    if isfield(tkn,'longyear')
        yeari = sscanf(tkn.longyear,'%g');
        if ~isempty(yeari)
            Year(i) = yeari;
        end
    end
    
    if isfield(tkn,'shortperiod')
        Per(i) = sscanf(tkn.shortperiod,'%g');
    end
    
    if isfield(tkn,'longperiod')
        Per(i) = sscanf(tkn.longperiod,'%g');
    end
    
    if isfield(tkn,'romanperiod')
        Per(i) = xxRoman2Num(tkn.romanperiod);
    end
    
    if isfield(tkn,'romanmonth')
        Month(i) = xxRoman2Num(tkn.romanmonth);
    end
    
    if isfield(tkn,'numericmonth')
        Month(i) = sscanf(tkn.numericmonth,'%g');
    end
    
    if isfield(tkn,'month')
        inx = strncmpi(tkn.month,Opt.months,length(tkn.month));
        if any(inx)
            Month(i) = find(inx,1);
        end
    end
    if ~isnumeric(Month(i)) || isinf(Month(i))
        Month(i) = NaN;
    end
    
    if IsCalendar
        if isfield(tkn,'varday')
            Day(i) = sscanf(tkn.varday,'%g');
        end
        if isfield(tkn,'longday')
            Day(i) = sscanf(tkn.longday,'%g');
        end
    end
    
    if ~isempty(Opt.freq)
        Freq(i) = Opt.freq;
    end
    
    if ~isnan(Month(i)) && ~IsCalendar
        if ~isnan(Freq(i)) && Freq(i) ~= 12
            Per(i) = month2per(Month(i),Freq(i));
        else
            Per(i) = Month(i);
            Freq(i) = 12;
        end
    end
    
    % Disregard periods for annual dates. This is now also consistent with
    % the YY function.
    if Freq(i) == 1
        Per(i) = 1;
    end
    
end

% Try to guess frequency by the highest period found in all the dates passed
% in.
if all(isnan(Freq))
    maxPer = max(Per(~isnan(Per)));
    if ~isempty(maxPer)
        inx = find(maxPer <= freqVec,1,'first');
        if ~isempty(inx)
            Freq(:) = freqVec(inx);
        end
    end
end

end % xParseDates()


%**************************************************************************


function Per = xxRoman2Num(RomanPer)
Per = 1;
list = {'i','ii','iii','iv','v','vi','vii','viii','ix','x','xi','xii'};
inx = strcmpi(RomanPer,list);
if any(inx)
    Per = find(inx,1);
end
end % xxRoman2Num()
