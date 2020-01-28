function [Ep,Wp] = errorparsing(This)
% errorparsing  [Not a public function] Create "Error parsing" message.
%
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

fname = specget(This,'file');

Ep = mosw.sprintf( ...
    'Error parsing file(s) <a href="matlab: edit %s">%s</a>. ', ...
    strrep(fname,' & ',' '),fname);

Wp = mosw.sprintf( ...
    'Warning parsing file(s) <a href="matlab: edit %s">%s</a>. ', ...
    strrep(fname,' & ',' '),fname);

end
