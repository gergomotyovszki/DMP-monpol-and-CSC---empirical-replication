function This = reduce(This,varargin)
% reduce  [Not a public function] Reduce algebraic expressions if possible.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

persistent SYDNEY;
if isnumeric(SYDNEY)
    SYDNEY = sydney();
end

% @@@@@ MOSW
template = SYDNEY;

%--------------------------------------------------------------------------

% This.lookahead = [];
nArg = length(This.args);

if isempty(This.Func)
    if isnumeric(This.args)
        % This is a number. Do nothing.
        return
    elseif islogical(This.args)
        % This is a logical index indicating a particular derivative among
        % multiple derivatives. You cannot run reduce without the second
        % input argument in that case.
        if isempty(varargin)
            This.args = double(This.args);
            return
        end
        k = varargin{1};
        if k == find(This.args)
            This.Func = '';
            This.args = 1;
        else
            This.Func = '';
            This.args = 0;
        end
        return
    elseif ischar(This.args)
        % This is a variable name. Do nothing.
        return
    else
        utils.error('sydney', ...
            'Cannot run reduction before differentation.');
    end
end

% Reduce all arguments first.
for i = 1 : length(This.args)
    This.args{i} = reduce(This.args{i},varargin{:});
end

if strcmp(This.Func,'sydney.d')
    % This is diff of an external function.
    return
end

% {
% Reduce a*(x/a), (x/a)*a to x.
if strcmp(This.Func,'times');
    doCancelTimes();
end
% }

% {
% Reduce a/(x*a), a/(a*x) to 1/x, (x*a)/a, (a*x)/a to x.
if strcmp(This.Func,'rdivide')
    doCancelRdivide();
end
% }

% Evaluate the function if all arguments are numeric.
if ~isempty(This.Func) && iscell(This.args) && ~isempty(This.args)
    allNumeric = true;
    args = cell(1,nArg);
    for i = 1 : nArg
        allNumeric = allNumeric && isnumeric(This.args{i}.args);
        if ~allNumeric
            break
        end
        args{i} = This.args{i}.args;
    end
    if allNumeric
        % Evaluate multiple plus; the arguments are guaranteed to be the same size
        % at this point.
        if strcmp(This.Func,'plus')
            x = sum([args{:}],2);
            This.Func = '';
            This.args = x;
            return
        else
            try
                This.args = builtin(This.Func,args{:});
                This.Func = '';
                return
            catch %#ok<CTCH>
                try
                    This.args = feval(This.Func,args{:});
                    This.Func = '';
                    return
                catch
                    utils.error('sydney:reduce', ...
                        ['Cannot evaluate numerical component ', ...
                        'of sydney expression.']);
                end
            end
        end
    end
end

switch This.Func
    case 'uplus'
        doUplus();
    case 'uminus'
        doUminus();
    case 'plus'
        doPlus();
    case 'minus'
        doMinus();
    case 'times'
        doTimes();
    case 'rdivide'
        doRdivide();
    case 'power'
        doPower();
    case 'exp'
        doExpLog();
    case 'log'
        doLogExp();
end

% Convert nested plus to multiple plus.
if strcmp(This.Func,'plus')
    args = {};
    nArg = length(This.args);
    for iArg = 1 : nArg
        if strcmp(This.args{iArg}.Func,'plus')
            args = [args,This.args{iArg}.args]; %#ok<AGROW>
        else
            args = [args,This.args(iArg)]; %#ok<AGROW>
        end
    end
    This.args = args;
end


% Nested functions...


    function doUplus()
        if isequal(This.args{1}.args,0)
            This.Func = '';
            This.args = 0;
        elseif isnumeric(This.args{1}.args)
            This.Func = '';
            This.args = This.args{1}.args;
        end
    end % doUplus()


    function doUminus()
        if isequal(This.args{1}.args,0)
            This.Func = '';
            This.args = 0;
        elseif isnumeric(This.args{1}.args)
            This.Func = '';
            This.args = -This.args{1}.args;
        end
    end % doUminus()


    function doPlus()
        nnArg = length(This.args);
        keep = true(1,nnArg);
        for iiArg = 1 : nnArg
            keep(iiArg) = ~isequal(This.args{iiArg}.args,0);
        end
        if sum(keep) == 1
            This = This.args{keep};
        else
            This.args(~keep) = [];
        end
    end % doPlus()


    function doMinus()
        if isequal(This.args{1}.args,0)
            This.Func = 'uminus';
            This.args = This.args(2);
        elseif isequal(This.args{2}.args,0)
            This = This.args{1};
        end
    end % doMinus()


    function doTimes()
        isWrap = isUminusWrapper();
        if isequal(This.args{1}.args,0) || isequal(This.args{2}.args,0)
            % 0*x or x*0
            This.Func = '';
            This.args = 0;
            return
        end
        if isequal(This.args{1}.args,1)
            % 1*x.
            This = This.args{2};
        elseif isequal(This.args{2}.args,1)
            % x*1.
            This = This.args{1};
        elseif isequal(This.args{1}.args,-1)
            % (-1)*x.
            This.Func = 'uminus';
            This.args = This.args(2);
        elseif isequal(This.args{2}.args,-1)
            % x*(-1).
            This.Func = 'uminus';
            This.args = This.args(1);
        end
        if isWrap
            doWrapInUminus();
        end
    end % doTimes()


    function doRdivide()
        isWrap = isUminusWrapper();
        if isequal(This.args{1}.args,0)
            % 0/x.
            This.Func = '';
            This.args = 0;
            return
        elseif isequal(This.args{2}.args,1)
            % x/1.
            This = This.args{1};
        end
        if isWrap
            doWrapInUminus();
        end
    end % doRdivide()


    function doPower()
        if isequal(This.args{2}.args,0) || isequal(This.args{1}.args,1)
            % x^0 or 1^x.
            This.Func = '';
            This.args = 1;
        elseif isequal(This.args{1}.args,0)
            % 0^x but not 0^0 (caught in the block).
            This.Func = '';
            This.args = 0;
        elseif isequal(This.args{2}.args,1)
            % x^1.
            This = This.args{1};
        end
    end % doPower()


    function isWrapUminus = isUminusWrapper()
        % Count the uminus and negative numeric arguments. If there is at least
        % one, remove every uminus and convert negatives into positives. If the
        % total of occurences is an even number, we're done. If the total of
        % occurences is odd, wrap the final result in uminus.
        isWrapUminus = false;
        nnArg = length(This.args);
        isUminus = false(1,nnArg);
        for ii = 1 : nnArg
            a = This.args{ii};
            isUminus(ii) = isequal(a.Func,'uminus') ...
                || (isnumeric(a.args) && all(a.args < 0));
        end
        if any(isUminus)
            for ii = find(isUminus)
                if isnumeric(This.args{ii}.args)
                    This.args{ii}.args = -This.args{ii}.args;
                else
                    This.args{ii} = This.args{ii}.args{1};
                end
            end
            nu = sum(isUminus);
            isWrapUminus = ( nu/2 ~= round(nu/2) );
        end
    end % isUminusWrapper.


    function doWrapInUminus()
        x = This;
        This = template;
        This.Func = 'uminus';
        This.args = {x};
    end % doWrapInUminus()


    function doCancelTimes()
        if isequal(This.args{2}.Func,'rdivide')
            % Reduce a*(x/a) to x.
            if isequal(This.args{1},This.args{2}.args{2})
                This = This.args{2}.args{1};
            end
        elseif isequal(This.args{1}.Func,'rdivide')
            % Reduce (x/a)*a to x.
            if isequal(This.args{2},This.args{1}.args{2})
                This = This.args{1}.args{1};
            end
        end
    end % doCancelTimes()


    function doCancelRdivide()
        if isequal(This.args{2}.Func,'times')
            if isequal(This.args{1},This.args{2}.args{1})
                % Reduce a/(a*x) to 1/x.
                z1 = template;
                z1.args = 1;
                z1.lookahead = false;
                z2 = This.args{2}.args{2};
                This = template;
                This.Func = 'rdivide';
                This.args = {z1,z2};
                This.lookahead = [false,any(z2.lookahead)];
            elseif isequal(This.args{1},This.args{2}.args{2})
                % Reduce a/(x*a) to 1/x.
                z1 = template;
                z1.args = 1;
                z1.lookahead = false;
                z2 = This.args{2}.args{1};
                This = template;
                This.Func = 'rdivide';
                This.args = {z1,z2};
                This.lookahead = [false,any(z2.lookahead)];
            end
        elseif isequal(This.args{1}.Func,'times')
            if isequal(This.args{2},This.args{1}.args{2})
                % Reduce (x*a)/a to x.
                This = This.args{1}.args{1};
            elseif isequal(This.args{2},This.args{1}.args{1})
                % Reduce (a*x)/a to x.
                This = This.args{1}.args{2};
            end
        end
    end % doCancelTimes()


    function doLogExp()
        if isequal(This.args{1}.Func,'exp')
            This = This.args{1}.args{1};
        end
    end % doLogExp()


    function doExpLog()
        if isequal(This.args{1}.Func,'log')
            This = This.args{1}.args{1};
        end
    end % doExpLog()


end
