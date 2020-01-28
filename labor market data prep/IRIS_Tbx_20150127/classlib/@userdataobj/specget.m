function [Ans,Flag,Query] = specget(This,Query)
% specget  [Not a public function] GET method for userdataobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

Ans = [];
Flag = true;

switch Query
    
    case {'carryon','carryaround','export'}
        Ans = This.Export;
        
    otherwise
        Flag = false;
        
end

end
