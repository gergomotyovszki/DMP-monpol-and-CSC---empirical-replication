function This = myparse(This,S,varargin)
% myparse  [Not a public function] Parser for rpteq objects.
%
% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

nEqtn = length(S.EqtnLhs);

ixValid = true(1,nEqtn);
for i = 1 : nEqtn
    ixValid(i) = isvarname(S.EqtnLhs{i});
end
if any(~ixValid)
    utils.error('rpteq:myparse', ...
        'This is not a valid name on LHS of reporting equation: ''%s''.', ...
        S.EqtnLhs{~ixValid});
end

This.UsrEqtn = S.eqtn;
This.NameLhs = S.EqtnLhs;
This.Label = S.eqtnlabel;
This.MaxSh = S.MaxSh;
This.MinSh = S.MinSh;

eqtnRhs = S.EqtnRhs;

% Add prefix `?` and suffix `(:,t)` to names (or names with curly braces)
% not followed by opening bracket or dot and not preceded by exclamation
% mark. The result is `?x#` or `?x{@-k}#`.
eqtnRhs = regexprep(eqtnRhs, ...
    '(?<!!)(\<[a-zA-Z]\w*\>(\{.*?\})?)(?![\(\.])','?$1#');

% Vectorise *, /, \, ^ operators.
eqtnRhs = strfun.vectorise(eqtnRhs);

% Make list of all names occuring on RHS.
nameRhs = regexp(eqtnRhs,'(?<=\?)\w+','match');
nameRhs = [ nameRhs{:} ];

This.EqtnRhs = eqtnRhs;
This.NameRhs = unique(nameRhs);

This.NaN = nan(1,nEqtn);
for i = 1 : nEqtn
    try
        x = str2num(S.SstateRhs{i}); %#ok<ST2NM>
        if isnumericscalar(x)
            This.NaN(i) = x;
        end
    end
end

end
