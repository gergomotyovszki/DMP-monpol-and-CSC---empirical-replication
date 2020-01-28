function [D,IsDev] = zerodb(This,Range,varargin)
% zerodb  Create model-specific zero-deviation database.
%
% Syntax
% =======
%
%     [D,IsDev] = zerodb(M,Range)
%     [D,IsDev] = zerodb(M,Range,NCol)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the zero database will be
% created.
%
% * `Range` [ numeric ] - Intended simulation range; the zero database will
% be created on a range that also automatically includes all the necessary
% lags.
%
% * `NCol` [ numeric ] - Number of columns for each variable; the input
% argument `NCol` can be only used on models with one parameterisation.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Database with a tseries object filled with zeros for
% each linearised variable, a tseries object filled with ones for each
% log-linearised variables, and a scalar or vector of the currently
% assigned values for each model parameter.
%
% * `IsDev` [ `true` ] - The second output argument is always `true`, and
% can be used to set the option `'deviation='` in
% [`model/simulate`](model/simulate).
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% zerodb, sstatedb

pp = inputParser();
pp.addRequired('M',@ismodel);
pp.addRequired('Range',@isnumeric);
pp.parse(This,Range);

%--------------------------------------------------------------------------

IsDev = true;
D = mysourcedb(This,Range,varargin{:},'deviation=',IsDev);

end
