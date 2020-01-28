function mydatxtick(H,Range,Time,Freq,UserRange,Opt)
% mydatxtick  [Not a public function] Set up x-axis for tseries object graphs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

if length(H) > 1
    for iH = H(:).'
        mydatxtick(iH,Time,Freq,UserRange,Opt);
    end
    return
end

%--------------------------------------------------------------------------

try
    if isequaln(Time,NaN)
        return
    end
catch
    if isequalwithequalnans(Time,NaN) %#ok<DISEQN>
        return
    end
end

% Does the axies object have a plotyy peer? Set the peer's xlim-related
% properties the same as in H; do not though set its xtick-related
% properties.
peer = getappdata(H,'graphicsPlotyyPeer');

isZero = Freq == 0;
isWeekly = Freq == 52;
isDaily = Freq == 365;

% Determine x-limits first.
firstDate = [];
lastDate = [];
xLim = [];
doXLim();

% Allow temporarily auto ticks and labels.
set(H, ...
    'xTickMode','auto', ...
    'xTickLabelMode','auto');

xTick = get(H(1),'xTick');
xTickDates = [];

if isZero || isDaily
    doXTickZeroDaily();
else
    doXTick();
end

% Adjust x-limits if the graph includes bars.
doXLimAdjust();


% Nested functions...


%**************************************************************************

    
    function doXLim()
        if isequal(UserRange,Inf)
            if isZero
                firstDate = Range(1);
                lastDate = Range(end);
                xLim = [firstDate,lastDate];
            elseif isWeekly
                firstDate = Range(1);
                lastDate = Range(end);
                xLim = [Time(1),Time(end)];
            elseif isDaily
                % First day in first plotted month to last day in last plotted month.
                firstDate = datbom(Range(1));
                lastDate = dateom(Range(end));
                xLim = [firstDate,lastDate];
            else
                % First period in first plotted year to last period in last plotted year.
                firstDate = datcode(Freq,floor(Time(1)),1);
                lastDate = datcode(Freq,floor(Time(end)),Freq);
                xLim = dat2dec([firstDate,lastDate],Opt.dateposition);
            end
        else
            firstDate = UserRange(1);
            lastDate = UserRange(end);
            xLim = dat2dec([firstDate,lastDate],Opt.dateposition);
        end
        set([H,peer], ...
            'xLim',xLim, ...
            'xLimMode','manual');
    end % doXLim()


%**************************************************************************
    
    
    function doXTick()
        if isequal(Opt.datetick,Inf)
            utils.error('dates:mydatxtick', ...
                ['Inf is an obsolete value for the option ''dateTick=''. ', ...
                'Use @auto instead.']);
        elseif isequal(Opt.datetick,@auto)
            % Determine step and xTick.
            % Step is number of periods.
            % If multiple axes handles are passed in (e.g. plotyy) use just
            % the first one to get xTick but set the properties for both
            % eventually.
            if length(xTick) > 1
                step = max(1,round(Freq*(xTick(2) - xTick(1))));
            else
                step = 1;
            end
            xTickDates = firstDate : step : lastDate;
        elseif isnumeric(Opt.datetick)
            xTickDates = Opt.datetick;
        elseif ischar(Opt.datetick)
            tempRange = firstDate : lastDate;
            [~,tempPer] = dat2ypf(tempRange);
            switch lower(Opt.datetick)
                case 'yearstart'
                    xTickDates = tempRange(tempPer == 1);
                case 'yearend'
                    xTickDates = tempRange(tempPer == Freq);
                case 'yearly'
                    match = tempPer(1);
                    if Freq == 52 && match == 53
                        match = 52;
                        xTickDates = tempRange(tempPer == match);
                        xTickDates = [tempRange(1),xTickDates];
                    else
                        xTickDates = tempRange(tempPer == match);
                    end
            end
        end
        xTick = dat2dec(xTickDates,Opt.dateposition);
        doSetXTickLabel();
    end % doXTick()


%**************************************************************************
   
    
    function doXTickZeroDaily()
        % Make sure the xTick step is not smaller than 1.
        if isequal(Opt.datetick,Inf)
            utils.error('dates:mydatxtick', ...
                ['Inf is an obsolete value for the option ''dateTick=''. ', ...
                'Use @auto instead.']);
        elseif isequal(Opt.datetick,@auto)
            % Do nothing.
        else
            xTick = Opt.datetick;
        end
        if any(diff(xTick) < 1)
            xTick = xTick(1) : xTick(end);
        end
        xTickDates = xTick;
        doSetXTickLabel();
    end % doXTickZeroDaily()


%**************************************************************************

    
    function doSetXTickLabel()
        set(H, ...
            'xTick',xTick, ...
            'xTickMode','manual');
        % Set xTickLabel.
        Opt = datdefaults(Opt,true);
        % Default value for '.plotDateFormat' is a struct with a different
        % date format for each date frequency. Fetch the right date format
        % now, and pass it into `dat2str()`.
        if isstruct(Opt.dateformat)
            Opt.dateformat = mydateformat(Opt.dateformat,Freq);
        end
        if Freq == 0 && strcmp(Opt.dateformat,'P')
            return
        end
        xTickLabel = dat2str(xTickDates,Opt);
        set(H, ...
            'xTickLabel',xTickLabel, ...
            'xTickLabelMode','manual');
    end % doSetXTickLabel()


%**************************************************************************
  
    
    function doXLimAdjust()
        % Expand x-limits for bar graphs, or make sure they are kept wide if a bar
        % graph is added a non-bar plot.
        if isequal(getappdata(H,'xLimAdjust'),true)
            if Freq == 0 || Freq == 365
                xLimAdjust = 0.5;
            else
                xLimAdjust = 0.5/Freq;
            end
            xLim = get(H,'xLim');
            set([H,peer],'xLim',xLim + [-xLimAdjust,xLimAdjust]);
            setappdata(H,'trueXLim',xLim);
            if ~isempty(peer)
                setappdata(peer,'trueXLim',xLim);
            end
        end
    end % doXLimAdjust()


end
