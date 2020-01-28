function [Flag,Test] = isstationary(This,varargin)
% isstationary  True if model or specified combination of variables is stationary.
%
% Syntax
% =======
%
%     Flag = isstationary(M)
%     Flag = isstationary(M,TName)
%     Flag = isstationary(M,TLinComb)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `TName` [ char ] - Name of a transition variable.
%
% * `Expn` [ char ] - Text string defining a linear combination of
% transition variables; log variables need to be enclosed in `log(...)`.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the model (if called without a
% second input argument) or the specified transition variable or
% combination of transition variables (if called with a second input
% argument) is stationary.
%
% Description
% ============
%
% Example
% ========
%
% In the following examples, `m` is a solved model object with two of its
% transition variables named `X` and `Y`; the latter is a log variable:
%
%     isstationary(m)
%     isstationary(m,'X')
%     isstationary(m,'log(Y)')
%     isstationary(m,'X - 0.5*log(Y)')
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

eigValTol = This.Tolerance(1);
if isempty(This.solution{1})
    Flag = NaN;
    return
end

if isempty(varargin)
    % Called flag = isstationary(model).
    nb = size(This.solution{1},2);
    Test = permute(abs(This.eigval(1,1:nb,:)),[1,3,2]);
    Flag = all(Test < 1-eigValTol,2);
else
    % Called [Flag,Test] = isstationary(M,Expn).
    Expn = varargin{1};
    [Flag,Test] = xxIsCointegrated(This,Expn);
end

end


% Subfunctions...


%**************************************************************************


function [Flag,Test] = xxIsCointegrated(This,Expn)
realSmall = getrealsmall();
[nx,nb,nAlt] = size(This.solution{1});
nf = nx - nb;

% Get the vector of coefficients describing the tested linear combination.
% Normalize the vector of coefficients by the largest coefficient.
xVec = myvector(This,'x');
[w,~,isValid] = preparser.lincomb2vec(Expn,xVec);
if ~isValid || all(w == 0)
    utils.error('model:isstationary', ...
        ['This is not a valid linear combination of ', ...
        'transition variables: ''%s''.'], ...
        Expn);
end
w = w / max(w);

Flag = false(1,nAlt);
Test = cell(1,nAlt);
for iAlt = 1 : nAlt
    Tf = This.solution{1}(1:nf,:,iAlt);
    U = This.solution{7}(:,:,iAlt);
    nUnit = mynunit(This,iAlt);
    Test{iAlt} = w*[Tf(:,1:nUnit);U(:,1:nUnit)];
    Flag(iAlt) = all(abs(Test{iAlt}) <= realSmall);
end
end % xxIsCointegrated()
