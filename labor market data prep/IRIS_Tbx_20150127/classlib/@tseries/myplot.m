function [SpecInp,Opt,Ax,H,Rng,Data,XCoor,UsrRng,Freq] ...
    = myplot(NSpecInp,Func,varargin)
% myplot  [Not a public function] Master plot function for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% If the caller supplies empty `Func`, the graph will not be actually
% rendered. This is a dry call to `myplot` used from within `plotyy`.

% User-specified handle to axes. Otherwise, the gca will be used. Make
% sure this complies with future Matlab graphics implementation where
% handles will no longer be numerics.
if length(varargin{1}) == 1 && ishghandle(varargin{1})
    Ax = varargin{1}(1);
    varargin(1) = [];
elseif ~isempty(Func)
    Ax = gca();
else
    % Empty `Fund` means mimic plotting without producing an axes object.
    Ax = [];
end

% User-defined range. Otherwise the entire range of the tseries object
% will be plotted. A cell array is passed in by the `plotyy` function to
% also indicate the other axes' range that must be comprised by the current
% one.
if isnumeric(varargin{1})
    comprise = [];
    Rng = varargin{1};
    varargin(1) = [];
elseif iscell(varargin{1}) && length(varargin{1}) == 2 ...
        && all(cellfun(@isnumeric,varargin{1}))
    comprise = varargin{1}{2};
    Rng = varargin{1}{1};
    varargin(1) = [];
else
    comprise = [];
    Rng = Inf;
end
Rng = Rng(:).';
UsrRng = Rng;

% Tseries object that will be plotted.
X = varargin{1};
varargin(1) = [];

% Fetch and ignore special inputs, and pass them back to the caller.
SpecInp = varargin(1:NSpecInp);
varargin(1:NSpecInp) = [];

% Resize input time series to input range if needed.
if ~all(isinf(Rng))
    if ~all( freqcmp(X,Rng) )
        utils.error('tseries:myplot', ...
            ['Date frequency mismatch between ', ...
            'input range and input time series.']);
    end
    X = resize(X,Rng);
end

flag = true;
plotSpecs = {};
if length(varargin) == 1 && ischar(varargin{1})
    plotSpecs = varargin(1);
    varargin(1) = [];
end
[Opt,varargin] = passvalopt('tseries.myplot',varargin{:});

% In shortcut line specification, we allow for date format to be
% included after a |.
if ~isempty(plotSpecs)
    inx = find(plotSpecs{1} == '|',1);
    if ~isempty(inx)
        Opt.dateformat = plotSpecs{1}(inx+1:end);
        plotSpecs{1} = plotSpecs{1}(1:inx-1);
    end
end

if ~flag
    utils.error('tseries:myplot','Incorrect type of input argument(s).');
end

%--------------------------------------------------------------------------

X.data = X.data(:,:);
[~,nx] = size(X.data);
Rng = specrange(X,Rng);

H = [];
if isempty(Rng)
    utils.warning('tseries:myplot', ...
        'No graph displayed because date range is empty.');
    return
end

Freq = datfreq(Rng(1));

% If hold==on, make sure the new range comprises thes existing dates if
% the existing graph is a tseries graph.
if ~isempty(Func) ...
        && ~isempty(Rng) && strcmp(get(Ax,'nextPlot'),'add') ...
        && isequal(getappdata(Ax,'tseries'),true)
    oldFreq = getappdata(Ax,'freq');
    if (oldFreq == 365 && Freq ~= 365) ...
            || (oldFreq ~= 365 && Freq == 365)
        utils.error('tseries:myplot', ...
            'Cannot combined daily and non-daily tseries in one graph.');
    end
    % Original x-axis limits.
    if isequal(getappdata(Ax,'xLimAdjust'),true)
        xLim0 = getappdata(Ax,'trueXLim');
    else
        xLim0 = get(Ax,'xLim');
    end
    Rng = doMergeRange(Rng([1,end]),xLim0);
end

% Make sure the new range and `userrange` both comprise the `comprise`
% dates; this is used in `plotyy`.
if ~isempty(comprise)
    Rng = doMergeRange(Rng,comprise);
    if ~isequal(UsrRng,Inf)
        UsrRng = doMergeRange(UsrRng,comprise);
    end
end

Data = mygetdata(X,Rng);
XCoor = dat2dec(Rng,Opt.dateposition);

if isempty(Func)
    return
end

% Do the actual plot.
set(Ax,'xTickMode','auto','xTickLabelMode','auto');
[H,isTimeAxis] = doPlot();

if isequal(Opt.xlimmargin,true) ...
        || (ischar(Opt.xlimmargin) ...
        && strcmpi(Opt.xlimmargin,'auto') ...
        && isanyfunc(Func,{'bar','barcon'}))
    setappdata(Ax,'xLimAdjust',true);
    peer = getappdata(Ax,'graphicsPlotyyPeer');
    if ~isempty(peer)
        setappdata(peer,'xLimAdjust',true);
    end
end

% `Time` can be `NaN` when the input tseries is empty.
try
    isTimeNan = isequaln(XCoor,NaN);
catch %#ok<CTCH>
    % Old syntax.
    isTimeNan = isequalwithequalnans(XCoor,NaN); %#ok<FPARK>
end

% Set up the x-axis with proper dates. Do not do this if `time` is NaN,
% which happens with empty tseries.
if isTimeAxis && ~isTimeNan
    setappdata(Ax,'tseries',true);
    setappdata(Ax,'freq',Freq);
    setappdata(Ax,'range',Rng);
    setappdata(Ax,'datePosition',Opt.dateposition);
    mydatxtick(Ax,Rng,XCoor,Freq,UsrRng,Opt);
end

% Perform user supplied function.
if ~isempty(Opt.function)
    Opt.function(H);
end

% Make the y-axis tight.
if Opt.tight
    grfun.yaxistight(Ax);
end

% Datatip cursor
%----------------
% Store the dates within each plotted object for later retrieval by
% datatip cursor.
for ih = H(:).'
    setappdata(ih,'dateLine',Rng);
end

if true % ##### MOSW
    % Use IRIS datatip cursor function in this figure; in `utils.datacursor',
    % we also handle cases where the current figure includes both tseries and
    % non-tseries graphs.
    obj = datacursormode(gcf());
    set(obj,'UpdateFcn',@utils.datacursor);
else
    % Do nothing.
end


% Nested functions...


%**************************************************************************


    function Range = doMergeRange(Range,Comprise)
        % first = dec2dat(Comprise(1),Freq,Opt.dateposition);
        first = Range(1);
        % Make sure ranges with different frequencies are merged
        % properly.
        while dat2dec(first-1,Opt.dateposition) >= Comprise(1)
            first = first - 1;
        end
        % last = dec2dat(Comprise(end),Freq,Opt.dateposition);
        last = Range(end);
        while dat2dec(last+1,Opt.dateposition) <= Comprise(end)
            last = last + 1;
        end
        Range = first : last;
    end % doMergeRange()


%**************************************************************************


    function [H,IsTimeAxis] = doPlot()
        FuncStr = Func;
        if isfunc(FuncStr)
            FuncStr = func2str(FuncStr);
        end
        switch FuncStr
            case {'scatter'}
                if nx ~= 2
                    utils.error('tseries:myplot', ...
                        ['Scatter plot input data must have ', ...
                        'exactly two columns.']);
                end
                H = scatter(Ax,Data(:,1),Data(:,2),plotSpecs{:});
                if ~isempty(varargin)
                    set(H,varargin{:});
                end
                IsTimeAxis = false;
            case {'barcon'}
                % Do not pass `plotspecs` but do pass user options.
                H = tseries.mybarcon(Ax,XCoor,Data,varargin{:});
                IsTimeAxis = true;
            otherwise
                DataInf = grfun.myreplacenancols(Data,Inf);
                H = feval(Func,Ax,XCoor,DataInf,plotSpecs{:});
                if ~isempty(varargin)
                    set(H,varargin{:});
                end
                IsTimeAxis = true;
        end
    end % doPlot()


end
