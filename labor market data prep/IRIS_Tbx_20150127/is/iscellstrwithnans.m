function Flag = iscellstrwithnans(X)
% iscellstrwithnans  True if variable is cell array of strings or NaNs.
%
% Syntax 
% =======
%
%     Flag = iscellstrwithnans(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a cell
% array of strings or `NaN`s.
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

try
    isequaln(1,1);
    isequalnFunc = @isequaln;
catch
    isequalnFunc = @isequalwithequalnans;
end

Flag = all(cellfun(@(x) ischar(x) || isequalnFunc(x,NaN),X(:)));

end
