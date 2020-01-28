function dispuserdata(This)
% dispuserdata  [Not a public function] Display userdata.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.UserData)
    msg = 'empty';
else
    tmpSize = sprintf('%gx',size(This.UserData));
    tmpSize(end) = '';
    msg = sprintf('[%s %s]',tmpSize,class(This.UserData));
end
fprintf('\tuser data: %s\n',msg);

if isempty(This.Export) || ~isstruct(This.Export)
    n = 0;
else
    n = length(This.Export);
end
msg = sprintf('[%g]',n);
fprintf('\texport files: %s\n',msg); 

end
