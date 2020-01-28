function Def = theparser()
% theparser  [Not a public function] Default options for theparser objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

Def.parse = { ...
    'multiple',false,@islogicalscalar, ...
    'sstateonly',false,@islogicalscalar, ...
    };

end
