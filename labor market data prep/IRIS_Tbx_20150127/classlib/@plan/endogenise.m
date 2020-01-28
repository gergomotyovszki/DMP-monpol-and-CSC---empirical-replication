function This = endogenise(This,List,Dates,Sigma)
% endogenise  Endogenise shocks or re-endogenise variables at the specified dates.
%
% Syntax
% =======
%
%     P = endogenise(P,List,Dates)
%     P = endogenise(P,Dates,List)
%     P = endogenise(P,List,Dates,Sigma)
%     P = endogenise(P,Dates,List,Sigma)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `List` [ cellstr | char ] - List of shocks that will be endogenised, or
% list of variables that will be re-endogenise.
%
% * `Dates` [ numeric ] - Dates at which the shocks or variables will be
% endogenised.
%
% * `Sigma` [ `1` | `1i` | numeric ] - Anticipation mode (real or
% imaginary) for endogenized shocks, and their numerical weight (used
% in underdetermined simulation plans); if omitted, `Sigma = 1`.
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new information on endogenised
% shocks included.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    Sigma; 
catch 
    Sigma = 1;
end

if isnumeric(List) && (ischar(Dates) || iscellstr(Dates))
    [List,Dates] = deal(Dates,List);
end

% Parse required input arguments.
pp = inputParser();
pp.addRequired('List',@(x) ischar(x) || iscellstr(x));
pp.addRequired('Dates',@isnumeric);
pp.addRequired('Weight', ...
    @(x) isnumericscalar(x) && ~(real(x) ~=0 && imag(x) ~=0) ...
    && real(x) >= 0 && imag(x) >= 0);
pp.parse(List,Dates,Sigma);

% Convert char list to cell of str.
if ischar(List)
    List = regexp(List,'[A-Za-z]\w*','match');
end

if isempty(List)
    return
end

%--------------------------------------------------------------------------

[Dates,outOfRange] = mydateindex(This,Dates);

if ~isempty(outOfRange)
    % Report invalid dates.
    utils.error('plan:endogenise', ...
        'Dates out of simulation plan range: %s.', ...
        dat2charlist(outOfRange));
end

nList = numel(List);
valid = true(1,nList);

for i = 1 : nList
    % Try to endogenise a shock.
    inx = strcmp(This.NList,List{i});
    if any(inx)
        if Sigma == 0
            % Re-exogenise the shock again.
            This.NAnchReal(inx,Dates) = false;
            This.NAnchImag(inx,Dates) = false;
            This.NWghtReal(inx,Dates) = 0;
            This.NWghtImag(inx,Dates) = 0;            
        elseif real(Sigma) > 0
            % Real endogenised shocks.
            This.NAnchReal(inx,Dates) = true;
            This.NWghtReal(inx,Dates) = Sigma;
        elseif imag(Sigma) > 0
            % Imaginary endogenised shocks.
            This.NAnchImag(inx,Dates) = true;
            This.NWghtImag(inx,Dates) = Sigma;
        end
    else
        % Try to re-endogenise an endogenous variable.
        inx = strcmp(This.XList,List{i});
        if any(inx)
            This.XAnch(inx,Dates) = false;
        else
            % Neither worked.
            valid(i) = false;
        end
    end
end

% Report invalid names.
if any(~valid)
    utils.error('plan:endogenise', ...
        'Cannot endogenise this name: ''%s''.', ...
        List{~valid});
end

end
