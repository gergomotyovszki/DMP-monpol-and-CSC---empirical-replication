function This = stdscale(This,Factor)
% stdscale  Rescale all std deviations by the same factor.
%
% Syntax
% =======
%
%     This = stdscale(This,Factor)
%
% Input arguments
% ================
%
% * `This` [ model ] - Model object whose std deviations will be rescaled.
%
% * `Factor` [ numeric ] - Factor by which all std deviations in the model
% object `This` will be rescaled.
%
% Output arguments
% =================
%
% * `This` [ model ] - Model object with all of std deviations rescaled.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

Factor = Factor(:);

nFactor = length(Factor);
nAlt = size(This.Assign,3);
ne = sum(This.nametype == 3);

if all(Factor == 1)
    return
elseif all(Factor == 0)
    This.stdcorr(1,1:ne,:) = 0;
    return
end

if nFactor == 1
    This.stdcorr(1,1:ne,:) = This.stdcorr(1,1:ne,:)*Factor;
else
    Factor = Factor(1:nAlt);
    Factor = permute(Factor,[3,2,1]);
    Factor = Factor(:,ones([1,ne]),:);
    This.stdcorr(1,1:ne,:) = This.stdcorr(1,1:ne,:) .* Factor;
end

end
