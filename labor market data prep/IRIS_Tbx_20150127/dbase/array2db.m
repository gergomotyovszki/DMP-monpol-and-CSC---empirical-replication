function D = array2db(X,Dates,List,IxLog,D)
% array2db  Convert numeric array to database.
%
% Syntax
% =======
%
%     D = array2db(X,Range,List)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Numeric array with individual time series in columns.
%
% * `Dates` [ numeric ] - Vector of dates for individual rows of `X`.
%
% * `List` [ cellstr | char ] - List of names for time series in individual
% columns of `X`.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%#ok<*CTCH>
%#ok<*VUNUS>

try
    IxLog;
catch
    IxLog = [ ];
end

try
    D;
catch
    D = struct();
end

if ischar(List)
    List = regexp(List,'\w+','match');
end

pp = inputParser();
pp.addRequired('X',@isnumeric);
pp.addRequired('Dates',@isnumeric);
pp.addRequired('IxLog',@(x) isempty(x) || islogical(x) || isstruct(x));
pp.addRequired('D',@isstruct);
pp.parse(X,Dates,IxLog,D);

% TODO: Allow for unsorted dates.

%--------------------------------------------------------------------------

nx = size(X,2);
Dates = Dates(:).';
nDates = length(Dates);
minDate = min(Dates);
maxDate = max(Dates);
Range = minDate : maxDate;
nPer = length(Range);
nList = length(List);

posDates = round(Dates - minDate + 1);
isRange = isequal(posDates,1:nPer);

if nx ~= nList
    utils.error('dbase:array2db', ...
        ['Number of columns in input array must match ', ...
        'number of variable names.']);
end

if size(X,1) ~= nDates
    utils.error('dbase:array2db', ...
        ['Number of rows in input array must match ', ...
        'number of periods.']);
end

sizeX = size(X);
ndimsX = length(sizeX);

ref = cell(1,ndimsX);
ref(:) = {':'};
temp = tseries();

for i = 1 : nx
    name = List{i};
    ref{2} = i;
    iX = squeeze(X(ref{:}));
    if doIsLog()
        iX = exp(iX);
    end
    if isRange
        % Continuous range.
        D.(name) = replace(temp,iX,minDate);
    else
        % Vector of dates.
        if i == 1
            iData = nan(size(iX));
            iData(end+1:nPer,:) = NaN;
        end
        iData(posDates,:) = iX;
        D.(name) = replace(temp,iData,minDate);
    end
    
end


% Nested functions...


%**************************************************************************


    function IsLog = doIsLog()
        IsLog = false;
        if isempty(IxLog)
            return
        end
        
        if islogicalscalar(IxLog)
            IsLog = IxLog;
            return
        end
        
        if islogical(IxLog)
            IsLog = IxLog(min(i,end));
            return
        end
        
        if isstruct(IxLog) && isfield(IxLog,name) ...
                && islogicalscalar(IxLog.(name))
            IsLog = IxLog.(name);
            return
        end
    end % doIsLog()
end % main