function This = rpteq(This)
% rpteq [Not a public function] Initialise theta parser object for rpteq class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

% 1 - Reporting equations.
This.BlkName{end+1} = '!reporting_equations';
This.NameType(end+1) = 1;
This.IxNameBlk(end+1) = false;
This.IxStdcorrBasis(end+1) = false;
This.IxStdcorrAllowed(end+1) = false;
This.IxEqtnBlk(end+1) = true;
This.IxLogBlk(end+1) = false;
This.IxLoggable(end+1) = false;
This.IxEssential(end+1) = true;
This.BlkRegExpRep{end+1} = { ...
    '\|','!!'; ...
    };

% Alternative names.
This.AltBlkName = [ This.AltBlkName; { } ];

% Alternative names with warning.
This.AltBlkNameWarn = [ This.AltBlkNameWarn; { ...
    '!outside','!reporting_equations'; ...
    '!equations:reporting','!reporting_equations'; ...
    '!reporting','!reporting_equations'; ...
    } ];

% Other keywords -- do not throw an error message for these.
This.OtherKey = [ This.OtherKey, { } ];

% Order in which values assigned to names will be evaluated in assign().
This.AssignBlkOrd = [ This.AssignBlkOrd, { } ];

end
