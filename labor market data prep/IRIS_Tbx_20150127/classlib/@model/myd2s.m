function This = myd2s(This,Opt)
% myd2s  [Not a public function] Create derivative-to-system convertor.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = sum(This.nametype==1);
nxx = sum(This.nametype==2);
ne = sum(This.nametype==3);
n = ny + nxx + ne;
t0 = find(This.Shift==0);

% Find max lag `minSh`, and max lead, `maxSh`, for each transition
% variable.
minSh = zeros(1,nxx);
maxSh = zeros(1,nxx);
doMinMaxShift();

% System IDs. These will be used to construct solution IDs.
This.systemid{1} = find(This.nametype==1);
This.systemid{3} = find(This.nametype==3);
This.systemid{2} = zeros(1,0);
This.systemid{4} = zeros(1,0);
This.systemid{5} = find(This.nametype==5);
for k = max(maxSh) : -1 : min(minSh)
    % Add transition variables with this shift.
    This.systemid{2} = [This.systemid{2}, ...
        ny+find(k >= minSh & k < maxSh) + 1i*k];
end

nx = length(This.systemid{2});
nu = sum(imag(This.systemid{2}) >= 0);
np = nx - nu;

This.d2s = struct();

% Pre-allocate vectors of positions in derivative matrices
%----------------------------------------------------------
This.d2s.y_ = zeros(1,0);
This.d2s.xu1_ = zeros(1,0);
This.d2s.xu_ = zeros(1,0);
This.d2s.xp1_ = zeros(1,0);
This.d2s.xp_ = zeros(1,0);
This.d2s.e_ = zeros(1,0);

% Pre-allocate vectors of positions in unsolved system matrices
%---------------------------------------------------------------
This.d2s.y = zeros(1,0);
This.d2s.xu1 = zeros(1,0);
This.d2s.xu = zeros(1,0);
This.d2s.xp1 = zeros(1,0);
This.d2s.xp = zeros(1,0);
This.d2s.e = zeros(1,0);

% Transition variables
%----------------------
This.d2s.y_ = (t0-1)*n + find(This.nametype==1);
This.d2s.y = 1 : ny;

% Delete double occurences. These emerge whenever a variable has maxshift >
% 0 and minshift < 0.
This.d2s.remove = false(1,nu);
for i = 1 : nu
    This.d2s.remove(i) = ...
        any(This.systemid{2}(i)-1i == This.systemid{2}(nu+1:end)) ...
        || (Opt.removeleads && imag(This.systemid{2}(i)) > 0);
end

% Unpredetermined variables
%---------------------------
for i = 1 : nu
    id = This.systemid{2}(i);
    if imag(id) == minSh(real(id)-ny)
        This.d2s.xu_(end+1) = (imag(id)+t0-1)*n + real(id);
        This.d2s.xu(end+1) = i;
    end
    This.d2s.xu1_(end+1) = (imag(id)+t0+1-1)*n + real(id);
    This.d2s.xu1(end+1) = i;
end

% Predetermined variables
%-------------------------
for i = 1 : np
    id = This.systemid{2}(nu+i);
    if imag(id) == minSh(real(id)-ny)
        This.d2s.xp_(end+1) = (imag(id)+t0-1)*n + real(id);
        This.d2s.xp(end+1) = nu + i;
    end
    This.d2s.xp1_(end+1) = (imag(id)+t0+1-1)*n + real(id);
    This.d2s.xp1(end+1) = nu + i;
end

% Shocks
%--------
This.d2s.e_ = (t0-1)*n + find(This.nametype==3);
This.d2s.e = 1 : ne;

% Dynamic identity matrices
%---------------------------
This.d2s.ident1 = zeros(0,nx);
This.d2s.ident = zeros(0,nx);
for i = 1 : nx
    id = This.systemid{2}(i);
    if imag(id) ~= minSh(real(id)-ny)
        aux = zeros(1,nx);
        aux(This.systemid{2} == id-1i) = 1;
        This.d2s.ident1(end+1,1:end) = aux;
        aux = zeros(1,nx);
        aux(i) = -1;
        This.d2s.ident(end+1,1:end) = aux;
    end
end

% Solution IDs
%--------------
nx = length(This.systemid{2});
nb = sum(imag(This.systemid{2}) < 0);
nf = nx - nb;

This.solutionid = {...
    This.systemid{1}, ...
    [This.systemid{2}(~This.d2s.remove),1i+This.systemid{2}(nf+1:end)], ...
    This.systemid{3}, ...
    This.systemid{4}, ...
    This.systemid{5}, ...
    };


% Nested functions...


%**************************************************************************


    function doMinMaxShift()
        % List of variables requested by user to be in backward-looking vector.
        if isequal(Opt.makebkw,@auto)
            ixMakeBkw = false(1,nxx);
        elseif isequal(Opt.makebkw,@all)
            ixMakeBkw = true(1,nxx);
        else
            ixMakeBkw = myselect(This,2,Opt.makebkw);
        end
        
        % Reshape `occur` to neqtn -by- nxx -by- nt.
        occur = This.occur;
        nt = size(occur,2)/length(This.name);
        if issparse(occur)
            occur = full(occur);
            occur = reshape(occur,[size(occur,1),length(This.name),nt]);
        end
        
        isNonlin = any(This.IxNonlin);
        for ii = 1 : nxx
            namePos = ny + ii;
            findOcc = find(any(occur(This.eqtntype==2,namePos,:),1)) - t0;
            findOcc = findOcc(:).';
            
            % Minimum and maximum shifts
            %----------------------------
            minSh(ii) = min([0,findOcc]);
            maxSh(ii) = max([0,findOcc]);
            % User requests adding one lead to all fwl variables.
            if Opt.addlead && maxSh(ii) > 0
                maxSh(ii) = maxSh(ii) + 1;
            end
            
            % Leads in nonlinear equations
            %------------------------------
            % Add one lead to fwl variables in equations marked for non-linear
            % simulations if the max lead of that variable occurs in one of those
            % equations.
            if isNonlin && maxSh(ii) > 0
                ixEqtn = This.eqtntype==2 & This.IxNonlin;
                % Maximum shift referred to in nonlinear equations.
                maxOccur = ...
                    max(find(any(occur(ixEqtn,namePos,:),1)) - t0);
                if maxOccur == maxSh(ii)
                    maxSh(ii) = maxSh(ii) + 1;
                end
            end
            
            % Lags in measurement variables
            %-------------------------------
            % If `x(t-k)` occurs in measurement equations then add k-1 lag.
            findOcc = find(any(occur(This.eqtntype==1,namePos,:),1)) - t0;
            findOcc = findOcc(:).';
            if ~isempty(findOcc)
                minSh(ii) = min( minSh(ii), min(findOcc)-1 );
            end
            
            % Request for backward-looking variable
            %---------------------------------------
            % If user requested this variable to be in the backward-looking vector,
            % make sure `minSh(i)` is at least -1.
            if ixMakeBkw(ii) && minSh(ii) == 0
                minSh(ii) = -1;
            end
            
            % Static variable
            %-----------------
            % If `minSh(i)` == `maxSh(i)` == 0, add an artificial lead to treat the
            % variable as forward-looking (to reduce state space), and to guarantee
            % that all variables will have `maxShift > minShift`.
            if minSh(ii) == maxSh(ii)
                maxSh(ii) = 1;
            end
        end 
    end % doMinMaxShift()
end