function disp(This)
% disp  [Not a public function] Display method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.EqtnRhs)
    fprintf('\tempty rpteq object\n');
else
    fprintf('\trpteq object\n');
end
fprintf('\tnumber of equations: [%g]\n',length(This.EqtnRhs));

disp@userdataobj(This);
disp(' ');


end
