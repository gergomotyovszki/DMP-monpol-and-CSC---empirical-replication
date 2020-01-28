function [Z,C,IsValid] = lincomb2vec(S,Vec)
% lincomb2vec  [Not a public function] Convert a string with a linear combination of variables to a coefficient vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~iscell(S)
    S = {S};
end
S = S(:).';

ns = length(S);
nVec = length(Vec);

Vec = regexptranslate('escape',Vec);
for i = 1 : nVec
    S = regexprep(S,['\<',Vec{i},'\>(?!\{)'],sprintf('x(%g)',i));
end

Z = zeros(ns,nVec);
C = zeros(ns,1);
IsValid = true(1,ns);
for i = 1 : ns
    try
        [Z(i,:),C(i)] = xxLinComb2Vec(S{i},nVec);
    catch
        IsValid(i) = false;
    end
end

end


% Subfunctions...


%**************************************************************************


function [Z,C] = xxLinComb2Vec(S,NVec)
f = mosw.str2func(['@(x)',S]);
x = zeros(1,NVec);
try
    C = f(x);
catch %#ok<CTCH>
    C = NaN;
end
Z = nan(1,NVec);
for i = 1 : NVec
    x = zeros(1,NVec);
    x(i) = 1;
    Z(i) = f(x) - C;
end
end % xxLinComb2Vec()
