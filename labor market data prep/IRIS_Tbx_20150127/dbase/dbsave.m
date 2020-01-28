function Saved = dbsave(D,FName,varargin)
% dbsave  Save database as CSV file.
%
% Syntax
% =======
%
%     List = dbsave(D,FName)
%     List = dbsave(D,FName,Dates,...)
%
% Output arguments
% =================
%
% * `List` [ cellstr ] - - List of actually saved database entries.
%
% Input arguments
% ================
%
% * `D` [ struct ] - Database whose tseries and numeric entries will be
% saved.
%
% * `FName` [ char ] - Filename under which the CSV will be saved,
% including its extension.
%
% * `Dates` [ numeric | *`Inf`* ] Dates or date range on which the tseries
% objects will be saved.
%
% Options
% ========
%
% * `'class='` [ *`true`* | false ] - Include a row with class and size
% specifications.
%
% * `'comment='` [ *`true`* | `false` ] - Include a row with comments for tseries
% objects.
%
% * `'decimal='` [ numeric | *empty* ] - Number of decimals up to which the
% data will be saved; if empty the `'format'` option is used.
%
% * `'format='` [ char | *`'%.8e'`* ] - Numeric format that will be used to
% represent the data, see `sprintf` for details on formatting, The format
% must start with a `'%'`, and must not include identifiers specifying
% order of processing, i.e. the `'$'` signs, or left-justify flags, the
% `'-'` signs.
%
% * `'freqLetters='` [ char | *`'YHQBM'`* ] - Five letters to represent the
% five possible date frequencies (annual, semi-annual, quarterly,
% bimonthly, monthly).
%
% * `'matchFreq='` [ `true` | *`false`* ] - Save only the tseries whose
% date frequencies match the input vector of dates, `Dates`.
%
% * `'nan='` [ char | *`'NaN'`* ] - String that will be used to represent
% NaNs.
%
% * `'saveSubdb='` [ `true` | *`false`* ] - Save sub-databases (structs
% found within the struct `D`); the sub-databases will be saved to separate
% CSF files.
%
% * `'userData='` [ char | *'userdata'* ] - Field name from which
% any kind of userdata will be read and saved in the CSV file.
%
% Description
% ============
%
% The data saved include also imaginary parts of complex numbers.
%
% Saving user data with the database
% ------------------------------------
%
% If your database contains field named `'userdata='`, this will be saved
% in the CSV file on a separate row. The `'userdata='` field can be any
% combination of numeric, char, and cell arrays and 1-by-1 structs.
%
% You can use the `'userdata='` field to describe the database or preserve
% any sort of metadata. To change the name of the field that is treated as
% user data, use the `'userData='` option.
%
% Example
% ========
%
% Create a simple database with two time series.
%
%     d = struct();
%     d.x = tseries(qq(2010,1):qq(2010,4),@rand);
%     d.y = tseries(qq(2010,1):qq(2010,4),@rand);
%
% Add your own description of the database, e.g.
%
%     d.userdata = {'My database',datestr(now())};
%
% Save the database as CSV using `dbsave`,
%
%     dbsave(d,'mydatabase.csv');
%
% When you later load the database,
%
%     d = dbload('mydatabase.csv')
%
%     d = 
%
%        userdata: {'My database'  '23-Sep-2011 14:10:17'}
%               x: [4x1 tseries]
%               y: [4x1 tseries]
%
% the database will preserve the `'userdata='` field.
%
% Example
% ========
%
% To change the field name under which you store your own user data, use
% the `'userdata='` option when running `dbsave`,
%
%     d = struct();
%     d.x = tseries(qq(2010,1):qq(2010,4),@rand);
%     d.y = tseries(qq(2010,1):qq(2010,4),@rand);
%     d.MYUSERDATA = {'My database',datestr(now())};
%     dbsave(d,'mydatabase.csv',Inf,'userData=','MYUSERDATA');
%
% The name of the user data field is also kept in the CSV file so that
% `dbload` works fine in this case, too, and returns a database identical
% to the saved one,
%
%     d = dbload('mydatabase.csv')
%
%     d = 
%
%        MYUSERDATA: {'My database'  '23-Sep-2011 14:10:17'}
%                 x: [4x1 tseries]
%                 y: [4x1 tseries]

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

if ~isempty(varargin) && isnumeric(varargin{1})
    Dates = varargin{1};
    varargin(1) = [];
end

try
    Dates;
catch %#ok<CTCH>
    Dates = Inf;
end

% Allow both dbsave(D,FName) and dbsave(FName,D).
if ischar(D) && isstruct(FName)
    [D,FName] = deal(FName,D);
end

% Parse input arguments.
pp = inputParser();
pp.addRequired('D',@isstruct);
pp.addRequired('FName',@ischar);
pp.addRequired('Dates',@isnumeric);
pp.parse(D,FName,Dates);

% Parse options.
opt = passvalopt('dbase.dbsave',varargin{:});

% Run Dates/datdefaults to substitute the default (irisget) date format
% options for `@config`.
opt = datdefaults(opt);

% Set up the formatting string.
if isempty(opt.decimal)
    format = opt.format;
else
    format = ['%.',sprintf('%g',opt.decimal),'f'];
end

%--------------------------------------------------------------------------

if isequal(Dates,Inf)
    Dates = dbrange(D);
    if iscell(Dates)
        utils.error('dbase:dbsave', ...
            'Cannot save database with mixed date frequencies.');
    end
else
    Dates = Dates(:)';
    if ~isempty(Dates) && any(~freqcmp(Dates))
        utils.error('dbase:dbsave', ...
            'Input date vector must have homogenous date frequency.');
    end
end

usrFreq = datfreq(Dates(1));

% Create saving struct.
o = struct();

% Handle userdata first, and remove them from the database so that they are
% not processed as a regular field.
if ~isempty(opt.userdata) && isfield(D,opt.userdata)
    o.userdata = D.(opt.userdata);
    o.userdatafieldname = opt.userdata;
    D = rmfield(D,opt.userdata);
end

% Handle custom delimiter
o.delimiter = opt.delimiter;

List = fieldnames(D).';

% Initialise the data matrix as a N-by-1 vector of NaNs to mimic the Dates.
% This first column will fill in all entries.
data = nan(length(Dates),1);

nameRow = {};
classRow = {};
commentRow = {};
ixSaved = false(size(List));
ixSubdb = false(size(List));

for i = 1 : numel(List)
    
    name = List{i};
    
    if istseries(D.(name))
        iFreq = freq(D.(name));
        if opt.matchfreq && usrFreq ~= iFreq
            continue
        end
        iData = D.(name)(Dates);
        iComment = comment(D.(name));
        ixSaved(i) = true;
        iClass = 'tseries';
    elseif isnumeric(D.(name))
        iData = D.(name);
        iComment = {''};
        ixSaved(i) = true;
        iClass = class(D.(name));
    elseif isstruct(D.(name))
        ixSubdb(i) = true;
        continue
    else
        continue
    end
    
    iData = double(iData);
    tmpSize = size(iData);
    iData = iData(:,:);
    [tmpRows,tmpCols] = size(iData);
    if tmpCols == 0
        continue
    elseif tmpCols > 1
        iComment(end+1:tmpCols) = {''};
    end
    
    % Add data, expand first dimension if necessary.
    nRows = size(data,1);
    if nRows < tmpRows
        data(end+1:tmpRows,:) = NaN;
    elseif size(data,1) > tmpSize(1)
        iData(end+1:nRows,:) = NaN;
    end
    data = [data,iData]; %#ok<*AGROW>
    nameRow{end+1} = List{i};
    classRow{end+1} = [iClass,xxPrintSize(tmpSize)];
    commentRow(end+(1:tmpCols)) = iComment;
    if tmpCols > 1
        nameRow(end+(1:tmpCols-1)) = {''};
        classRow(end+(1:tmpCols-1)) = {''};
    end
    
end

% Remove the pretend date column.
data(:,1) = [];

Saved = List(ixSaved);

% We need to remove double quotes from the date format string because the
% double quotes are used to delimit the CSV cells.
o.dates = dat2str(Dates(:),opt);
o.dates = strrep(o.dates,'"','');

o.data = data;
o.namerow = nameRow;
o.nanstring = opt.nan;
o.format = format;
if opt.comment
    o.commentrow = commentRow;
end
if opt.class
    o.classrow = classRow;
end

xxSaveCsvData(o,FName);

% Save sub-databases.
if opt.savesubdb && any(ixSubdb)
    doSaveSubdb();
end


% Nested functions...


%**************************************************************************


    function doSaveSubdb()
        [fPath,fTit,fExt] = fileparts(FName);
        for ii = find(ixSubdb)
            iiName = List{ii};
            iiFName = fullfile(fPath,[fTit,'_',iiName],fExt);
            saved = dbsave(D.(iiName),iiFName,Dates,varargin{:});
            Saved{end+1} = saved;
        end
    end % doSaveSubdb()
end


% Subfunctions...


%**************************************************************************


function C = xxPrintSize(S)
% xxPrintSize  Print the size of the saved variable in the format
% 1-by-1-by-1 etc.
C = [sprintf('%g',S(1)),sprintf('-by-%g',S(2:end))];
C = ['[',C,']'];
end % xxPrintSize()


%**************************************************************************


function xxSaveCsvData(O,FName)
nameRow = O.namerow;
dates = O.dates;
data = O.data;

if isfield(O,'delimiter')
    delimiter = O.delimiter;
else
    delimiter = ',';
end
fstr = [delimiter,'"%s"'];

if isfield(O,'commentrow')
    commentRow = O.commentrow;
else
    commentRow = {};
end
isCommentRow = ~isempty(commentRow);

if isfield(O,'classrow')
    classRow = O.classrow;
else
    classRow = {};
end
isClassRow = ~isempty(classRow);

if isfield(O,'unitrow')
    unitRow = O.unitrow;
else
    unitRow = {};
end
isUnitRow = ~isempty(unitRow);

if isfield(O,'nanstring')
    nanString = O.nanstring;
else
    nanString = 'NaN';
end
isNanString = ~strcmpi(nanString,'NaN');

if isfield(O,'format')
    format = O.format;
else
    format = '%.8e';
end

if isfield(O,'highlight')
    highlight = O.highlight;
else
    highlight = [];
end
isHighlight = ~isempty(highlight);

isUserData = isfield(O,'userdata');

%--------------------------------------------------------------------------

% Create an empty buffer.
c = '';
br = sprintf('\n');

% Write database user data.
if isUserData
    userData = utils.any2str(O.userdata);
    userData = strrep(userData,'"','''');
    c = [c,'"Userdata[',O.userdatafieldname,'] ->"',delimiter,'"',userData,'"',br];
end

% Write name row.
if isHighlight
    nameRow = [{''},nameRow];
end
c = [c,'"Variables ->"',xxPrintCharCells(nameRow)];

% Write comments.
if isCommentRow
    if isHighlight
        commentRow = [{''},commentRow];
    end
    c = [c,br,'"Comments ->"',xxPrintCharCells(commentRow)];
end

% Write units.
if isUnitRow
    if isHighlight
        unitRow = [{''},unitRow];
    end
    c = [c,br,'"Units ->"',xxPrintCharCells(unitRow)];
end

% Write classes.
if isClassRow
    if isHighlight
        classRow = [{''},classRow];
    end
    c = [c,br,'"Class[Size] ->"',xxPrintCharCells(classRow)];
end

% Create cellstr with date strings.
nDates = length(dates);

% Handle escape characters.
dates = strrep(dates,'\','\\');
dates = strrep(dates,'%','%%');

% Create format string fot the imaginary parts of data; they need to be
% always printed with a plus or minus sign.
iFormat = [format,'i'];
if isempty(strfind(iFormat,'%+')) && isempty(strfind(iFormat,'%0+'))
    iFormat = strrep(iFormat,'%','%+');
end

% Find columns that have at least one non-zero imag. These column will
% be printed as complex numbers.
nRow = size(data,1);
nCol = size(data,2);

% Combine real and imag columns in an extended data matrix.
xData = zeros(nRow,2*nCol);
xData(:,1:2:end) = real(data);
iData = imag(data);
xData(:,2:2:end) = iData;

% Find imag columns and create positions of zero-only imag columns that
% will be removed.
iCol = any(iData ~= 0,1);
removeCol = 2*(1 : nCol);
removeCol(iCol) = [];
% Check for the occurence of imaginary NaNs.
isImagNan = any(isnan(iData(:)));
% Remove zero-only imag columns from the extended data matrix.
xData(:,removeCol) = [];
% Create a sequence of formats for one line.
formatLine = cell(1,nCol);
% Format string for columns that have imaginary numbers.
formatLine(iCol) = {[delimiter,format,iFormat]};
% Format string for columns that only have real numbers.
formatLine(~iCol) = {[delimiter,format]};
formatLine = [formatLine{:}];

% We must create a format line for each date because the date strings
% vary.
br = sprintf('\n');
formatData = '';
for i = 1 : size(data,1)
    if i <= nDates
        thisDate = ['"',dates{i},'"'];
    else
        thisDate = '"NaN"';
    end
    if isHighlight
        if i <= nDates && highlight(i)
            thisDate = [thisDate,delimiter,'"***"'];
        else
            thisDate = [thisDate,delimiter,'""'];
        end
    end
    formatData = [formatData,br,thisDate,formatLine];
end
cc = sprintf(formatData,xData.');

% NaNi is never printed with the leading sign. Replace NaNi with +NaNi. We
% should also control for the occurence of NaNi in date strings but we
% don't as this is quite unlikely (and would not be easy).
if isImagNan
    cc = strrep(cc,'NaNi','+NaNi');
end

% Replace NaNs in the date/data matrix with a user-supplied string. We
% don't protect NaNs in date strings; these too will be replaced.
if isNanString
    cc = strrep(cc,'NaN',nanString);
end

% Splice the headings and the data, and save the buffer. No need to put
% a line break between `c` and `cc` because that the `cc` does start
% with a line break.
char2file([c,cc],FName);


    function S = xxPrintCharCells(C)
        S = '';
        if isempty(C) || ~iscellstr(C)
            return
        end
        S = sprintf(fstr,C{:});
    end % xxPrintCharCells()


end % xxSaveCsvData()
