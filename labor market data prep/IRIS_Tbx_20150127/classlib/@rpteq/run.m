function Outp = run(This,Inp,Dates,varargin)
% run  Evaluate reporting equations (rpteq) object.
%
%
% Syntax
% =======
%
%     Outp = run(Q,Inp,Range,...)
%
%
% Input arguments
% ================
%
% * `Q` [ char ] - Reporting equations (rpteq) object.
%
% * `Inp` [ struct ] - Input database that will be used to evaluate the
% reporting equations.
%
% * `Dates` [ numeric ] - Dates at which the reporting equations will be
% evaluated; `Dates` does not need to be a continuous date range.
%
%
% Output arguments
% =================
%
% * `Outp` [ struct ] - Output database with reporting variables.
%
%
% Options
% ========
%
% * `'dbOverlay='` [ `true` | *`false`* | struct ] - If `true`, the LHS
% output data will be combined with data from the input database (or a
% user-supplied database).
%
% * `'fresh='` [ `true` | *`false`* ] - If `true`, only LHS variables will
% be included in the output database, `Outp`; if `false` the output
% database will also include all entries from the input database, `Inp`.
%
%
% Description
% ============
%
% Reporting equations are always evaluated non-simultaneously, i.e.
% equation by equation, for each period.
%
%
% Example
% ========
%
% Note the differences in the three output databases, `d1`, `d2`, `d3`,
% depending on the options `'dbOverlay='` and `'fresh='`.
%
%     >> q = rpteq({ ...
%         'a = c * a{-1}^0.8 * b{-1}^0.2;', ...
%         'b = sqrt(b{-1});', ...
%         })
% 
%     q =
%         rpteq object
%         number of equations: [2]
%         comment: ''
%         user data: empty
%         export files: [0]
%
%     >> d = struct();
%     >> d.a = tseries();
%     >> d.b = tseries();
%     >> d.a(qq(2009,4)) = 0.76;
%     >> d.b(qq(2009,4)) = 0.88;
%     >> d.c = 10;
%     >> d
%
%     d = 
%         a: [1x1 tseries]
%         b: [1x1 tseries]
%         c: 10
%
%     >> d1 = run(q,d,qq(2010,1):qq(2011,4))
%
%     d1 = 
%         a: [8x1 tseries]
%         b: [8x1 tseries]
%         c: 10
%
%     >> d2 = run(q,d,qq(2010,1):qq(2011,4),'dbOverlay=',true)
%
%     d2 = 
%         a: [9x1 tseries]
%         b: [9x1 tseries]
%         c: 10
%
%     >> d3 = run(q,d,qq(2010,1):qq(2011,4),'fresh=',true)
% 
%     d3 = 
%         a: [8x1 tseries]
%         b: [8x1 tseries]
% 

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

opt = passvalopt('rpteq.run',varargin{:});

%--------------------------------------------------------------------------

eqtnRhs = This.EqtnRhs;
nEqtn = length(eqtnRhs);
nNameRhs = length(This.NameRhs);
Dates = Dates(:).';
minDate = min(Dates);
maxDate = max(Dates);
maxSh = This.MaxSh;
minSh = This.MinSh;
xRange = minDate+minSh : maxDate+maxSh;
nXPer = length(xRange);

D = struct();

% Convert tseries names to arrays, remove time subscript placeholders `#`
% from non-tseries names.
ixFound = false(1,nNameRhs);
ixTseries = false(1,nNameRhs);
ixValid = false(1,nNameRhs);
for i = 1 : nNameRhs
    name = This.NameRhs{i};
    isField = isfield(Inp,name);
    ixFound(i) = isField || any(strcmp(name,This.NameLhs));
    if ~isField
        continue
    end
    ixTseries(i) = isa(Inp.(name),'tseries');
    if ixTseries(i)
        D.(name) = rangedata(Inp.(name),xRange);
        continue
    end
    ixValid(i) = isnumeric(Inp.(name)) && size(Inp.(name),1) == 1;
    if ixValid(i)
        D.(name) = Inp.(name);
        eqtnRhs = regexprep(eqtnRhs,['\?',name,'#'],['?',name]);
    end
end

if any(~ixFound)
    utils.error('rpteq:run', ...
        'This name not found in input database: ''%s''.', ...
        This.NameRhs{~ixFound});
end

% Pre-allocate LHS time series not supplied in input database.
for i = 1 : nEqtn
    name = This.NameLhs{i};
    if ~isfield(D,name)
        D.(name) = nan(nXPer,1);
    end
end

eqtnRhs = strrep(eqtnRhs,'?','D.');
eqtnRhs = regexprep(eqtnRhs,'\{@(.*?)\}#','(t$1,:)');
eqtnRhs = strrep(eqtnRhs,'#','(t,:)');

% Positions of input dates in first dimension.
timePos = Dates-minDate+1 - minSh;

fn = cell(1,nEqtn);
for i = 1 : nEqtn
    fn{i} = mosw.str2func(['@(D,t)',eqtnRhs{i}]);
end

% Evaluate equations recursively period by period.
for t = timePos
    for iEq = 1 : nEqtn
        name = This.NameLhs{iEq};
        lhs = D.(name);
        try
            x = fn{iEq}(D,t);
        catch %#ok<CTCH>
            x = NaN;
        end
        if size(x,1) > 1
            x = NaN;
        end
        x( isnan(x) ) = This.NaN(iEq);
        if length(x) > 1 && ndims(lhs) == 2 && size(lhs,2) == 1  %#ok<ISMAT>
            newSize = size(x);
            lhs = repmat(lhs,[1,newSize(2:end)]);
        end
        lhs(t,:) = x;
        D.(name) = lhs;
    end
end

Outp = struct();
if ~opt.fresh
    Outp = Inp;
end

if isstruct(opt.dboverlay)
    Inp = opt.dboverlay;
    opt.dboverlay = true;
end

templ = tseries();
for i = 1 : nEqtn
    name = This.NameLhs{i};
    data = D.(name)(-minSh+1:end-maxSh,:);
    cmt = This.Label{i};
    Outp.(name) = replace(templ,data,minDate,cmt);
    if opt.dboverlay && isfield(Inp,name)
        Outp.(name) = [ Inp.(name) ; Outp.(name) ];
    end 
end

end
