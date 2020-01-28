function [AsgnInx,StdcorrInx,ShkInx1,ShkInx2] = mynameindex(AllNames,ENames,Str)
% mynameindex  [Not a public function] Logical index for a single in the Assign or stdcorr vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

nName = length(AllNames);
ne = length(ENames);
nStdcorr = ne*(ne-1)/2;
AsgnInx = false(1,nName);
StdcorrInx = false(1,nStdcorr);
ShkInx1 = false(1,ne);
ShkInx2 = false(1,ne);

if (length(Str) >= 5 && strncmp(Str,'std_',4)) ...
    || (length(Str) >= 9 && strncmp(Str,'corr_',5))
    % Index of a std or corr name in the stdcorr vector.
    [StdcorrInx,ShkInx1,ShkInx2] = theparser.stdcorrindex(ENames,Str);
else
    % Index of a parameter or steady-state name in the Assign vector.
    AsgnInx = strfun.strcmporregexp(AllNames,Str);
end

end