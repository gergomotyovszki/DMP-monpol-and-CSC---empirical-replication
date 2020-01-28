function disp(This,Name,Disp2DFunc)
% disp  [Not a public function] Disp method for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

try
    Name; %#ok<VUNUS>
catch %#ok<CTCH>
    Name = '';
end

start = This.start;
freq = datfreq(start);

try
    Disp2DFunc; %#ok<VUNUS>
catch %#ok<CTCH>
    if freq == 365
        Disp2DFunc = @xxDisp2dDaily;
    else
        Disp2DFunc = @xxDisp2d;
    end
end

%--------------------------------------------------------------------------

mydispheader(This);

data = This.data;
dataNDim = ndims(data);
config = irisget();
xxDispND(start,data,This.Comment,[],Name,Disp2DFunc,dataNDim,config);

disp@userdataobj(This);
strfun.loosespace();

end


% Subfunctions...


%**************************************************************************


function xxDispND(Start,Data,Comment,Pos,Name,Disp2DFUnc,NDim,Config)
lastDimSize = size(Data,NDim);
nPer = size(Data,1);
tab = sprintf('\t');
sep = sprintf(':  ');
num2StrFunc = @(x) xxNum2Str(x,Config.tseriesformat);
if NDim > 2
    subsref = cell([1,NDim]);
    subsref(1:NDim-1) = {':'};
    for i = 1 : lastDimSize
        subsref(NDim) = {i};
        xxDispND(Start,Data(subsref{:}),Comment(subsref{:}), ...
            [i,Pos],Name,Disp2DFUnc,NDim-1,Config);
    end
else
    if ~isempty(Pos)
        fprintf('%s{:,:%s} =\n',Name,sprintf(',%g',Pos));
        strfun.loosespace();
    end
    if nPer > 0
        X = Disp2DFUnc(Start,Data,tab,sep,num2StrFunc);
        % Reduce the number of white spaces between numbers to 5 at most.
        X = xxReduceSpaces(X,Config.tseriesmaxwspace);
        % Print the dates and data.
        disp(X);
    end
    % Make sure long scalar comments are never displayed as `[1xN char]`.
    if length(Comment) == 1
        if isempty(regexp(Comment{1},'[\r\n]','once'))
            fprintf('\t''%s''\n',Comment{1});
        else
            fprintf('''%s''\n',Comment{1});
        end
        strfun.loosespace();
    else
        strfun.loosespace();
        disp(Comment);
    end
end
end % xxDispND()


%**************************************************************************


function X = xxDisp2d(Start,Data,Tab,Sep,Num2StrFunc)
nPer = size(Data,1);
range = Start + (0 : nPer-1);
dates = strjust(dat2char(range));
if datfreq(range(1)) == 52
    dateFormatW = '$ (Aaa DD-Mmm-YYYY)';
    dates = [dates, ...
        strjust(dat2char(range,'dateFormat=',dateFormatW))];
end
dates = [ ...
    Tab(ones(1,nPer),:), ...
    dates, ...
    Sep(ones(1,nPer),:), ...
    ];
dataChar = Num2StrFunc(Data);
X = [dates,dataChar];
end % xxDisp2DDefault()


%**************************************************************************


function C = xxReduceSpaces(C,Max)
inx = all(C == ' ',1);
s = char(32*ones(size(inx)));
s(inx) = 'S';
s = regexprep(s,sprintf('(?<=S{%g})S',Max),'X');
C(:,s == 'X') = '';
end % xxReduceSpaces().


%**************************************************************************


function C = xxNum2Str(X,Fmt)
if isempty(Fmt)
    C = num2str(X);
else
    C = num2str(X,Fmt);
end
end % xxNum2Str()


%**************************************************************************


function X = xxDisp2dDaily(Start,Data,Tab,Sep,Num2StrFunc)
[nPer,nx] = size(Data);
[startYear,startMonth,startDay] = datevec(Start);
[endYear,endMonth,endDay] = datevec(Start + nPer - 1);

% Pad missing observations at the beginning of the first month
% and at the end of the last month with NaNs.
tmp = eomday(endYear,endMonth);
Data = [nan(startDay-1,nx);Data;nan(tmp-endDay,nx)];

% Start-date and end-date of the calendar matrix.
% startdate = datenum(startyear,startmonth,1);
% enddate = datenum(endyear,endmonth,tmp);

year = startYear : endYear;
nYear = length(year);
year = year(ones(1,12),:);
year = year(:);

month = 1 : 12;
month = transpose(month(ones([1,nYear]),:));
month = month(:);

year(1:startMonth-1) = [];
month(1:startMonth-1) = [];
year(end-(12-endMonth)+1:end) = [];
month(end-(12-endMonth)+1:end) = [];
nPer = length(month);

lastDay = eomday(year,month);
lastDay = lastDay(:).';
X = [];
for t = 1 : nPer
    tmp = nan(nx,31);
    tmp(:,1:lastDay(t)) = transpose(Data(1:lastDay(t),:));
    X = [X;tmp]; %#ok<AGROW>
    Data(1:lastDay(t),:) = [];
end
lastDay = repmat(lastDay,nx,1);
lastDay = lastDay(:).';

% Date string.
rowStart = datenum(year,month,1);
nRow = length(rowStart);
dates = cell(1,1 + nx*nRow);
dates(:) = {''};
dates(2:nx:end) = dat2str(rowStart,'dateFormat=',['$Mmm-YYYY',Sep]);
dates = char(dates);

% Data string.
divider = '    ';
divider = divider(ones(size(X,1)+1,1),:);
dataStr = '';
for i = 1 : 31
    c = Num2StrFunc(X(:,i));
    ixExist = i <= lastDay;
    if any(~ixExist)
        for j = find(~ixExist(:).')
            c(j,:) = strrep(c(j,:),'NaN','  *');
        end
    end
    dataStr = [dataStr, ...
        strjust(char(sprintf('D%g',i),c),'right')]; %#ok<AGROW>
    if i < 31
        dataStr = [dataStr,divider]; %#ok<AGROW>
    end
end

Tab = repmat(Tab,size(dates,1),1);
X = [Tab,dates,dataStr];
end % xxDisp2dDaily()
