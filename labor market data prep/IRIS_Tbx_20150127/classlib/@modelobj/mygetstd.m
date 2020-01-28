function [List,Values,S] = mygetstd(This)
% mygetstd  [Not a public function] Return names and values of std errors.
%
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

ne = sum(This.nametype == 3);
Values = This.stdcorr(1,1:ne,:);
List = This.name(This.nametype == 3);
List = strcat('std_',List);
if nargout > 2
    pData = permute(Values,[2,3,1]);
    S = cell2struct(num2cell(pData,2),List(:),1);
end

end
