function D = reporting(This,varargin)
% reporting  Evaluate reporting equations from within model object.
%
% Syntax
% =======
%
%     D = reporting(M,D,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object with reporting equations.
%
% * `D` [ struct ] - Input database that will be used to evaluate the
% reporting equations.
%
% * `Range` [ numeric ] - Date range on which the reporting equations will
% be evaluated.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with reporting variables.
%
% Options
% ========
%
% See [`rpteq/run`](rpteq/run) for options available.
%
% Description
% ============
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

D = run(This.Reporting,varargin{:});

end
