function Flag = mychk(This,IAlt,varargin)
% mychk  [Not a public function] Check for missing or inconsistent values assigned within the model object.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(IAlt,Inf)
    IAlt = 1 : size(This.Assign,3);
end

for i = 1 : length(varargin)
    switch varargin{i}
        case 'log'
            realSmall = getrealsmall();
            lvl = real(This.Assign(1,:,IAlt));
            ixLogZero = This.IxLog & any(abs(lvl) <= realSmall,3);
            Flag = ~any(ixLogZero);
            if ~Flag
                utils.warning('model:mychk',...
                    ['Steady state for this log variable ', ...
                    'is numerically close to zero: ''%s''.'], ...
                    This.name{ixLogZero});
            end
            
        case 'parameters'
            % Throw warning if some parameters are not assigned.
            [~,list] = isnan(This,'parameters',IAlt);
            Flag = isempty(list);
            if ~Flag
                utils.warning('model:mychk', ...
                    'This parameter is not assigned: ''%s''.', ...
                    list{:});
            end
            
        case 'sstate'
            % Throw warning if some steady states are not assigned.
            [~,list] = isnan(This,'sstate',IAlt);
            Flag = isempty(list);
            if ~Flag
                utils.warning('model:mychk', ...
                    ['Steady state is not available ', ...
                    'for this variable: ''%s''.'], ...
                    list{:});
            end
            
    end
end

end
