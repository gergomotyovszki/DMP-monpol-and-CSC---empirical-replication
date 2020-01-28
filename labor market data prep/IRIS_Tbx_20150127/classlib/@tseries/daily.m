function daily(This)
% daily   Calendar view of a daily tseries object.
%
% Syntax
% =======
%
%     daily(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object with indeterminate frequency whose
% date ticks will be interpreted as Matlab serial date numbers.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% ##### Oct 2014 OBSOLETE and scheduled for removal.
utils.warning('obsolete', ...
    ['Function daily( ) is obsolete, and ', ...
    'will be removed from IRIS in a future release.']);

if datfreq(This.start) ~= 365
    utils.error('tseries:daily', ...
        ['Function daily( ) can be used only on tseries ', ...
        'with daily frequency.']);
end

%--------------------------------------------------------------------------

disp(This);

end
