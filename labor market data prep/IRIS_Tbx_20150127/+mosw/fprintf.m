function fprintf(Msg,varargin)
% fprintf  [Not a public function] Workaround for Octave's fprintf.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------


if true % ##### MOSW
    fprintf(Msg,varargin{:});
else
    % Remove HTML tags from `Message`.
    Msg = mosw.sprintf(Msg,varargin{:}); %#ok<UNRCH>
    fprintf('%s',Msg);
end

end
