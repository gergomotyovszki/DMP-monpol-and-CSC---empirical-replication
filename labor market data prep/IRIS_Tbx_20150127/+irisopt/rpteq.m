function Def = rpteq()
% rpteq  [Not a public function] Default options for rpteq class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

Def.rpteq = { ...
    'assign',struct([ ]),@isstruct, ...
    'saveas','',@ischar, ...
    };

Def.run = { ...
    'dboverlay',false,@(x) islogicalscalar(x) || isstruct(x),...
    'fresh',false,@islogicalscalar,...
    };

end
