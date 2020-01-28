function C = char(This)
% char  Print sydney object as text string expression.
%
% Syntax
% =======
%
%     C = char(Z)
%
% Input arguments
% ================
%
% * `Z` [ sydney ] - Sydney object.
%
% Output arguments
% =================
%
% * `C` [ char ] - Text string with an expression representing the input
% sydney object.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

precPlus = {'le','lt','ge','gt','eq'};
precTimes = [{'rdivide','plus','minus'},precPlus];
precUminus = [{'times'},precTimes];

%--------------------------------------------------------------------------

if isempty(This.Func)
    % Atomic value.
    C = myatomchar(This);
    return
end

if strcmp(This.Func,'sydney.d')
    % Derivative of an external function.
    C = ['sydney.d(@',This.numd.Func];
    wrt = sprintf(',%g',This.numd.wrt);
    wrt = ['[',wrt(2:end),']'];
    C = [C,',',wrt];
    for i = 1 : length(This.args)
        C = [C,',',xxArgs2Char(This.args{i})]; %#ok<AGROW>
    end
    C = [C,')'];
    return
end

nArg = length(This.args);

if strcmp(This.Func,'plus')
    doPlus();
    return
end

if strcmp(This.Func,'times')
    doTimes();
    return
end

if nArg == 1
    c1 = xxArgs2Char(This.args{1});
    switch This.Func
        case 'uplus'
            C = c1;
        case 'uminus'
            if ischar(This.args{1}.Func) ...
                    && any(strcmp(This.args{1}.Func,precUminus))
                c1 = ['(',c1,')'];
            end
            C = ['-',c1];
        otherwise
            C = [This.Func,'(',c1,')'];
    end
elseif nArg == 2
    c1 = xxArgs2Char(This.args{1});
    c2 = xxArgs2Char(This.args{2});
    isFinished = false;
    switch This.Func
        case 'minus'
            sign = '-';
        case 'rdivide'
            sign = '/';
        case 'power'
            sign = '^';
        case 'lt'
            sign = '<';
        case 'le'
            sign = '<=';
        case 'gt'
            sign = '>';
        case 'ge'
            sign = '>=';
        case 'eq'
            sign = '==';
        otherwise
            C = [This.Func,'(',c1,',',c2,')'];
            isFinished = true;
    end
    if ~isFinished
        if ~isempty(This.args{1}.Func) ...
                && ~strcmp(This.args{1}.Func,'sydney.d')
            c1 = ['(',c1,')'];
        end
        if ~isempty(This.args{2}.Func) ...
                && ~strcmp(This.args{2}.Func,'sydney.d')
            c2 = ['(',c2,')'];
        end
        C = [c1,sign,c2];
    end
else
    C = [This.Func,'(',];
    C = [C,xxArgs2Char(This.args{1})];
    for i = 2 : nArg
        C = [C,',',xxArgs2Char(This.args{i})]; %#ok<AGROW>
    end
    C = [C,')'];
end

if true % ##### MOSW
    % Do nothing.
else
    % Replace `++` and `--` with `+`.
    C = mosw.ppmm(C); %#ok<UNRCH>
end


% Nested functions...


%**************************************************************************
    
    
    function doPlus()
        C = '';
        for iiArg = 1 : nArg
            sign = '+';
            a = This.args{iiArg};
            if strcmp(a.Func,'uminus')
                c = xxArgs2Char(a.args{1});
                if ischar(a.args{1}.Func) ...
                        && any(strcmp(a.args{1}.Func,precUminus))
                    c = ['(',c,')']; %#ok<AGROW>
                end
                sign = '-';
            elseif isempty(a.Func) && isnumeric(a.args) ...
                    && all(a.args < 0)
                a1 = a;
                a1.args = -a1.args;
                c = myatomchar(a1);
                sign = '-';
            else
                c = xxArgs2Char(a);
                if any(strcmp(a.Func,precPlus))
                    c = ['(',c,')']; %#ok<AGROW>
                end
            end
            C = [C,sign,c]; %#ok<AGROW>
        end
        if C(1) == '+'
            C(1) = '';
        end
    end % doPlus()


%**************************************************************************

    
    function doTimes()
        C = '';
        for iiArg = 1 : nArg
            sign = '*';
            a = This.args{iiArg};
            c = xxArgs2Char(a);
            if any(strcmp(a.Func,precTimes))
                c = ['(',c,')']; %#ok<AGROW>
            end
            C = [C,sign,c]; %#ok<AGROW>
        end
        if C(1) == '*'
            C(1) = '';
        end
    end % doTimes()


end


% Subfunctions...


%**************************************************************************


function C = xxArgs2Char(X)
if isa(X,'sydney')
    C = char(X);
elseif isfunc(X)
    C = ['@',func2str(X)];
elseif ischar(X)
    C = ['''',X,''''];
else
    utils.error('sydney:char', ...
        'Invalid type of function argument in a sydney expression.');
end
end % xxArgs2Char()
