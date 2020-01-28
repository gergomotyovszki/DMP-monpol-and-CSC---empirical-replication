function Per = month2per(Month,Freq)
% month2per  [Not a public function] Convert month to lower-freq period.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

Per = ceil(Month.*Freq./12);

end
