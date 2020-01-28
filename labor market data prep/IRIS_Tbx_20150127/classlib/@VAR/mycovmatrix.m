function Cov = mycovmatrix(This,Alt)
% mybmatrix  [Not a public function] Cov matrix of reduced-form residuals.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

try
    Alt; %#ok<VUNUS>
catch
    Alt = ':';
end

%--------------------------------------------------------------------------

Cov = This.Omega(:,:,Alt);

end
