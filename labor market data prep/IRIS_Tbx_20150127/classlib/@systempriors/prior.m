function This = prior(This,Def,PriorFn,varargin)
% prior  Add new prior to system priors object.
%
%
% Syntax
% =======
%
%     S = prior(S,Expr,PriorFn,...)
%     S = prior(S,Expr,[],...)
%
%
% Input arguments
% ================
%
% * `S` [ systempriors ] - System priors object.
%
% * `Expr` [ char ] - Expression that defines a value for which a prior
% density will be defined; see Description for system properties that can
% be referred to in the expression.
%
% * `PriorFn` [ function_handle | empty ] - Function handle returning the
% log of prior density; empty prior function, `[]`, means a uniform prior.
%
%
% Output arguments
% =================
%
% * `S` [ systempriors ] - The system priors object with the new prior
% added.
%
% Options
% ========
%
% * `'lowerBound='` [ numeric | *`-Inf`* ] - Lower bound for the prior.
%
% * `'upperBound='` [ numeric | *`Inf`* ] - Upper bound for the prior.
%
%
% Description
% ============
%
% System properties that can be used in `Expr`
% ---------------------------------------------
%
% * `srf[VarName,ShockName,T]` - Plain shock response function of variables
% `VarName` to shock `ShockName` in period `T`. Mind the square brackets.
%
% * `ffrf[VarName,MVarName,Freq]` - Filter frequency response function of
% transition variables `TVarName` to measurement variable `MVarName` at
% frequency `Freq`. Mind the square brackets.
%
% * `corr[VarName1,VarName2,Lag]` - Correlation between variable
% `VarName1` and variables `VarName2` lagged by `Lag` periods.
%
% * `spd[VarName1,VarName2,Freq]` - Spectral density between
% variables `VarName1` and `VarName2` at frequency `Freq`.
%
% If a variable is declared as a [`log variable`](modellang/logvariables),
% it must be referred to as `log(VarName)` in the above expressions, and
% the log of that variables is returned, e.g.
% `srf[log(VarName),ShockName,T]`. or `ffrf[log(TVarName),MVarName,T]`.
%
% Expressions involving combinations or functions of parameters
% --------------------------------------------------------------
%
% Model parameter names can be referred to in `Expr` preceded by a dot
% (period), e.g. `.alpha^2 + .beta^2` defines a prior on the sum of squares
% of the two parameters (`alpha` and `beta`).
%
%
% Example
% ========
%
% Create a new empty systemprios object based on an existing model.
%
%     s = systempriors(m);
%
% Add a prior on minus the shock response function of variable `ygap` to
% shock `eps` in period 4. The prior density is lognormal with mean 0.3 and
% std deviation 0.05;
%
%     s = prior(s,'-srf[ygap,eps,4]',logdist.lognormal(0.3,0.05));
%
% Add a prior on the gain of the frequency response function of transition
% variable `ygap` to measurement variable 'y' at frequency `2*pi/40`. The
% prior density is normal with mean 0.5 and std deviation 0.01. This prior
% says that we wish to keep the cut-off periodicity for trend-cycle
% decomposition close to 40 periods.
%
%     s = prior(s,'abs(ffrf[ygap,y,2*pi/40])',logdist.normal(0.5,0.01));
%
% Add a prior on the sum of parameters `alpha1` and `alpha2`. The prior is
% normal with mean 0.9 and std deviation 0.1, but the sum is forced to be
% between 0 and 1 by imposing lower and upper bounds.
%
%     s = prior(s,'.alpha1 + .alpha2',logdist.normal(0.9,0.1), ...
%         'lowerBound=',0,'upperBound=',1);
%
% Add a prior saying that the first 16 periods account for at least 90% of
% total variability (cyclicality) in a 40-period response of `ygap` to
% shock `eps`. This prior is meant to suppress secondary cycles in shock
% response functions.
%
%     s = prior(s, ...
%        'sum(abs(srf[ygap,eps,1:16])) / sum(abs(srf[ygap,eps,1:40]))', ...
%        [],'lowerBound=',0.9);
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('S',@(x) isa(x,'systempriors'));
pp.addRequired('Def',@ischar);
pp.addRequired('PriorFunc',@(x) isempty(x) || isfunc(x));
pp.parse(This,Def,PriorFn);

opt = passvalopt('systempriors.prior',varargin{:});

%--------------------------------------------------------------------------

Def0 = Def;

% Parse system function names.
[This,Def] = xxParseSystemFunctions(This,Def);

% Parse references to parameters and steady-state values of variables.
Def = xxParseNames(This,Def);

try
    % ##### MOSW
    This.Eval{end+1} = mosw.str2func( ...
        ['@(srf,ffrf,cov,corr,pws,spd,Assign,stdcorr) ',Def]);
catch %#ok<CTCH>
    xxThrowError(Def0);
end

This.PriorFn{end+1} = PriorFn;

This.UserString{end+1} = Def0;

This.LowerBnd(end+1) = opt.lowerbound;
This.UpperBnd(end+1) = opt.upperbound;
if This.LowerBnd(end) >= This.UpperBnd(end)
    utils.error('systempriors:prior', ...
        'Lower bound (%g) must be lower than upper bound (%g).', ...
        This.lowerBound(end),This.upperBound(end));
end

end


% Subfunctions...


%**************************************************************************


function [This,Def] = xxParseSystemFunctions(This,Def)
% Replace variable names in the system function definition `Def`
% with the positions in the respective matrices (the positions are
% function-specific), and update the (i) number of simulated periods, (ii)
% FFRF frequencies, (iii) ACF lags, and (iv) XSF frequencies that need to be
% computed.

% Remove all blank space; this may not be, in theory, proper as the user
% moight have specified a string with blank spaces inside the definition
% string, but this case is quite unlikely, and we make sure to explain this
% in the help.
Def = regexprep(Def,'\s+','');

%allFunc = fieldnames(This.SystemFn);
%allFunc = sprintf('%s|',allFunc{:});
%allFunc(end) = '';

while true
    % The system function names `srf`, `ffrf`, `cov`, `corr`, `pws`,
    % `spd` are case insensitive.
    [start,open] = regexpi(Def,'\<([a-zA-Z]+)\>\[','start','end','once');
    if isempty(open)
        break
    end
    close = strfun.matchbrk(Def,open);
    if isempty(close)
        xxThrowError(Def(start:end));
    end
    funcName = Def(start:open-1);
    funcArgs = Def(open+1:close-1);
    if ~isfield(This.SystemFn,funcName)
        utils.error('systempriors:prior', ...
            'This is not a valid system prior function name: ''%s''.', ...
            funcName);
    end
    [This,replace,isError] = xxReplaceSystemFunc(This,funcName,funcArgs);
    if isError
        xxThrowError(Def(start:close));
    end
    Def = [Def(1:start-1),replace,Def(close+1:end)];
end

end % xxParseSystemFunctions()


%**************************************************************************


function [This,C,IsErr] = xxReplaceSystemFunc(This,FuncName,ArgStr)
C = '';
IsErr = false;

% Retrieve the system function struct for convenience.
s = This.SystemFn.(FuncName);

tok = regexp(ArgStr,'(.*?),(.*?),(.*)','once','tokens');
if isempty(tok)
    tok = regexp(ArgStr,'(.*?),(.*?)','once','tokens');
    if ~isempty(tok)
        tok{end+1} = s.defaultPageStr;
    end
end
if length(tok) ~= 3
    IsErr = true;
    return
end

rowName = tok{1};
colName = tok{2};
% `page` can be a scalar or a vector of pages.
page = eval(tok{3});
if ~all(isfinite(page)) || ~s.validatePage(page)
    IsErr = true;
    return
end

rowPos = find(strcmp(rowName,s.rowName));
colPos = find(strcmp(colName,s.colName));
doChkRowColNames();

try
    
    % Add all pages requested by the user.
    pagePosString = '';
    for iPage = page(:).'
        pagePos = find(s.page == iPage);
        if isempty(pagePos)
            doAddPage();
        end
        if ~isempty(pagePosString)
            pagePosString = [pagePosString,',']; %#ok<AGROW>
        end
        pagePosString = [pagePosString,sprintf('%g',pagePos)]; %#ok<AGROW>
    end
    if length(page) ~= 1
        pagePosString = ['[',pagePosString,']'];
    end
    
    C = sprintf('%s(%g,%g,%s)',FuncName,rowPos,colPos,pagePosString);
    
    % Update the system function struct.
    This.SystemFn.(FuncName) = s;
    
catch %#ok<CTCH>
    IsErr = true;
    return
end


    function doAddPage()
        switch lower(FuncName)
            case {'srf'}
                s.page = 1 : iPage;
                s.activeInput(colPos) = true;
            case {'cov','corr'}
                s.page = 0 : iPage;
                s.activeInput(colPos) = true;
                % Keep pages and active inputs for `cov` and `corr`
                % identical.
                This.SystemFn.cov.page = s.page;
                This.SystemFn.corr.page = s.page;
                This.SystemFn.cov.activeInput = s.activeInput;
                This.SystemFn.corr.activeInput = s.activeInput;
            case {'ffrf'}
                s.page(end+1) = iPage;
            case {'pws','spd'}
                s.page{end+1} = iPage;
                % Keep pages and active inputs for `pws` and `spd`
                % identical.
                This.SystemFn.pws.page = s.page;
                This.SystemFn.spd.page = s.page;
                This.SystemFn.pws.activeInput = s.activeInput;
                This.SystemFn.spd.activeInput = s.activeInput;
        end
        % Whatever the system function, the current page is now included
        % as the last one in the list of pages.
        pagePos = length(s.page);
    end % doAddPage()


    function doChkRowColNames()
        if isempty(rowPos)
            utils.error('systempriors:prior', ...
                'This is not a valid row name: ''%s''.', ...
                rowName);
        end
        if isempty(colPos)
            utils.error('systempriors:prior', ...
                'This is not a valid column name: ''%s''.', ...
                colName);
        end        
    end % doChkRowColNames()
end % xxReplaceSystemFunc()


%**************************************************************************


function Def = xxParseNames(This,Def)
% xxParseNames  Parse references to parameters and steady-state values of variables.
invalid = {};
eNames = This.Names(This.NameTypes==3);

% Dot-references to the names of variables, shocks and parameters names
% (must not be followed by an opening round bracket).
ptn = '\.(\<[a-zA-Z]\w*\>(?![\[\(]))';
if true % ##### MOSW
    replaceFunc = @doReplace; %#ok<NASGU>
    Def = regexprep(Def,ptn,'${replaceFunc($1)}');
else
    Def = mosw.dregexprep(Def,ptn,@doReplace,1); %#ok<UNRCH>
end

if ~isempty(invalid)
    utils.error('systempriors:prior', ...
        'This is not a valid parameter or steady-state name: ''%s''.', ...
        invalid{:});
end


    function C1 = doReplace(C0)
        C1 = '';
        [ixAssign,iXStdcorr] = modelobj.mynameindex(This.Names,eNames,C0);
        if any(ixAssign)
            C1 = sprintf('Assign(1,%g)',find(ixAssign));
        elseif any(iXStdcorr)
            C1 = sprintf('stdcorr(1,%g)',find(iXStdcorr));
        else
            invalid{end+1} = C0;
        end
    end % doReplace()


end % xxParseNames()


%**************************************************************************


function xxThrowError(Str)
utils.error('systempriors:prior', ...
    'Error parsing the definition string: ''%s''.', ...
    Str);
end % xxThrowError()
