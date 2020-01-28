function [Ans,Flag,Query] = specget(This,Query)
% specget  [Not a public function] GET method for rpteq objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Call superclass `specget` first.
[Ans,Flag,Query] = specget@userdataobj(This,Query);
if Flag
    return
end

Ans = [];
Flag = true;

switch Query

    case {'filename','fname','file'}
        Ans = This.FName;

    case {'lhsnames','lhslist'}
        Ans = This.NameLhs;
        
    case {'rhsnames','rhslist'}
        Ans = This.NameRhs;
        
    case {'equation','equations','eqtn','eqtns'}
        Ans = This.UsrEqtn;
        
    case {'rhs'}
        Ans = This.EqtnRhs;

    case {'label','labels'}
        Ans = This.Label;
        
    otherwise
        Flag = false;
        
end

end
