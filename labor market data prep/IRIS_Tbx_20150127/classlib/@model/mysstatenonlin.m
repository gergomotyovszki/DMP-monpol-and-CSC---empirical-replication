function  [This,Ok] = mysstatenonlin(This,Opt)
% mysstatenonlin [Not a public function] Steady-state solver for non-linear models.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

posFixL = Opt.posFixL;
posFixG = Opt.posFixG;
nameBlkL = Opt.nameBlkL;
nameBlkG = Opt.nameBlkG;
eqtnBlk = Opt.eqtnBlk;
blkFunc = Opt.blkFunc;
ixEndgL = Opt.ixEndgL;
ixEndgG = Opt.ixEndgG;
ixZeroL = Opt.ixZeroL;
ixZeroG = Opt.ixZeroG;

%--------------------------------------------------------------------------

Shift = 10;
nAlt = size(This.Assign,3);
Ok = true(1,nAlt);

doRefresh();

% Set the level and growth of optimal policy multipliers to zero. We must
% do this before checking for NaNs in fixed variables.
if Opt.zeromultipliers
    This.Assign(1,This.multiplier,:) = 0;
end

% Check for levels and growth rate fixed to NaNs.
doChkForNans();

lx0 = [];
gx0 = [];

for iAlt = 1 : nAlt
    iOk = true;
    
    % Initialise levels
    %-------------------
    lx = real(This.Assign(1,:,iAlt));
    % Level variables that are set to zero (all shocks).
    lx(ixZeroL) = 0;
    % Assign NaN level initial conditions. First, assign values from the
    % previous iteration, if they exist and option 'reuse=' is `true`.
    ix = isnan(lx) & ixEndgL;
    if Opt.reuse && any(ix) && ~isempty(lx0)
        lx(ix) = lx0(ix);
        ix = isnan(lx) & ixEndgL;
    end
    % Then, if there still some NaNs left, use the option `'nanInit='`
    % to assign them.
    lx(ix) = real(Opt.naninit);
    
    % Initialise growth rates
    %-------------------------
    gx = imag(This.Assign(1,:,iAlt));
    % Variables with zero growth (all variables if 'growth=' false).
    gx(ixZeroG) = 0;
    if any(~ixZeroG)
        % Assign NaN growth initial conditions. First, assign values from
        % the previous iteration, if they exist and option 'reuse=' is
        % `true`.
        ix = isnan(gx) & ixEndgG;
        if Opt.reuse && any(ix) && ~isempty(gx0)
            gx(ix) = gx0(ix);
            ix = isnan(gx) & ixEndgL;
        end
        % Then, if there still some NaNs left, use the option `'NaN='` to assign
        % them.
        gx(ix) = imag(Opt.naninit);
    end
    % Reset zero growth to 1 for log variables.
    gx(This.IxLog & gx == 0) = 1;
        
    % Cycle over individual blocks
    %------------------------------
    nBlk = length(nameBlkL);
    for iBlk = 1 : nBlk
        if isempty(nameBlkL{iBlk}) && isempty(nameBlkG{iBlk})
            continue
        end

        posLx = nameBlkL{iBlk};
        posGx = nameBlkG{iBlk};
        ixLogPlus = Opt.IxLogPlus(posLx);
        ixLogMinus = Opt.IxLogMinus(posLx);
        % Log growth rates are always positive.
        ixGLog = This.IxLog(posGx);
        ixLogPlus = [ixLogPlus,ixGLog]; %#ok<AGROW>
        ixLogMinus = [ixLogMinus,false(size(posGx))]; %#ok<AGROW>
        z0 = [lx(posLx),gx(posGx)];
        z0(ixLogPlus | ixLogMinus) = log(abs(z0(ixLogPlus | ixLogMinus)));
        
        % Test all equations in this block for NaNs and INfs.
        if Opt.warning
            check = blkFunc{iBlk}(lx,gx);
            ix = isnan(check) | isinf(check);
            if any(ix)
                utils.warning('model:mysstatenonlin', ...
                    'This equation evaluates to NaN or Inf: ''%s''.', ...
                    This.eqtn{eqtnBlk{iBlk}(ix)});
            end
        end
        
        % Number of levels and growth rates; used also within doObjFunc().
        nlx = length(posLx);
        ngx = length(posGx); %#ok<NASGU>
        
        % Function handles to equations in this block.
        f = blkFunc{iBlk};
        
        % Solve the block.
        if Opt.ixAssign(iBlk)
            % Plain assignment
            %------------------
            % The vectors `posLx` and `posGx` are each either empty or
            % scalar.
            z = [];
            y0 = f(lx,gx);
            if ~isempty(posLx)
                z = [z,y0]; %#ok<AGROW>
            end
            if ~isempty(posGx)
                xk = lx;
                xk(~This.IxLog) = lx(~This.IxLog) + Shift*gx(~This.IxLog);
                xk(This.IxLog) = lx(This.IxLog) .* gx(This.IxLog).^Shift;
                yk = f(xk,gx);
                % `ixDLog` is a scalar in a plain assignment block.
                if ixGLog
                    z = [z,(yk/y0)^(1/Shift)]; %#ok<AGROW>
                else
                    z = [z,(yk-y0)/Shift]; %#ok<AGROW>
                end
            end
            exitFlag = 1;

        else
            % System of equations
            %---------------------
            solverName = Opt.solver;
            if isfunc(solverName)
                solverName = func2str(solverName);
            end
            switch lower(solverName)
                case 'lsqnonlin'
                    [z,~,~,exitFlag] = ...
                        lsqnonlin(@doObjFunc,z0,[],[],Opt.optimset);
                    if exitFlag == -3
                        exitFlag = 1;
                    end
                case 'fsolve'
                    [z,~,exitFlag] = fsolve(@doObjFunc,z0,Opt.optimset);
                    if exitFlag == -3
                        exitFlag = 1;
                    end
            end
            z(abs(z) <= Opt.optimset.TolX) = 0; %#ok<AGROW>
            z(ixLogPlus) = exp(z(ixLogPlus)); %#ok<AGROW>
            z(ixLogMinus) = -exp(z(ixLogMinus)); %#ok<AGROW>
        end
        
        lx(posLx) = z(1:nlx);
        gx(posGx) = z(nlx+1:end);
        iOk = ~any(isnan(z)) && double(exitFlag) > 0;
    end

    This.Assign(1,:,iAlt) = lx + 1i*gx;
    
    % Check for zero log variables.
    iOk = mychk(This,iAlt,'log') && iOk;
    
    % TODO: Report more details on failed equations and variables.
    if Opt.warning && ~iOk
        utils.warning('model:mysstatenonlin', ...
            'Steady state inaccurate or not returned for some variables.');
    end
    
    % Store current values to initialise next parameterisation.
    lx0 = lx;
    gx0 = gx;
    
    Ok(iAlt) = iOk;
end

doRefresh();


% Nested functions...


%**************************************************************************


    function doRefresh()
        if ~isempty(This.Refresh) && Opt.refresh
            This = refresh(This);
        end
    end % doRefresh()


%**************************************************************************


    function Y = doObjFunc(P)
        % doobjfunc  This is the objective function for the solver. Evaluate the
        % equations twice, at time t and t+Shift.

        % Delogarithmize log variables (variables in steady-state equations
        % are expected in original levels).
        P(ixLogPlus) = exp(P(ixLogPlus));
        P(ixLogMinus) = -exp(P(ixLogMinus));

        % Split the input vector of unknows into levels and growth rates; nlx is
        % the number of levels in the input vector.
        lx(posLx) = P(1:nlx);
        gx(posGx) = P(nlx+1:end);
        
        % Refresh all dynamic links.
        if ~isempty(This.Refresh)
            doRefresh();
        end
        
        Y = f(lx,gx);
        if any(posGx)
            % Some growth rates need to be calculated. Evaluate the model equations at
            % time t and t+Shift if at least one growth rate is needed.
            xk = lx;
            xk(~This.IxLog) = lx(~This.IxLog) + Shift*gx(~This.IxLog);
            xk(This.IxLog) = lx(This.IxLog) .* gx(This.IxLog).^Shift;
            Y = [Y;f(xk,gx)];
        end

        
        function doRefresh()
            % dorefresh  Refresh dynamic links in each iteration.
            This.Assign(1,:,iAlt) = lx + 1i*gx;
            This = refresh(This,iAlt);
            lx = real(This.Assign(1,:,iAlt));
            gx = imag(This.Assign(1,:,iAlt));
            gx(This.IxLog & gx == 0) = 1;
        end % doRefresh()
    end % doObjFunc()


%**************************************************************************


    function doChkForNans()
        % Check for levels fixed to NaN.
        ixFixL = false(1,length(This.name));
        ixFixL(posFixL) = true;
        nanSstate = any(isnan(real(This.Assign)),3) & ixFixL;
        if any(nanSstate)
            utils.error('model:mysstatenonlin', ...
                ['Cannot fix steady-state level for this variable ', ...
                'because it is NaN: ''%s''.'], ...
                This.name{nanSstate});
        end
        % Check for growth rates fixed to NaN.
        ixFixG = false(1,length(This.name));
        ixFixG(posFixG) = true;
        nanSstate = any(isnan(imag(This.Assign)),3) & ixFixG;
        if any(nanSstate)
            utils.error('model:mysstatenonlin', ...
                ['Cannot fix steady-state growth for this variable ', ...
                'because it is NaN: ''%s''.'], ...
                This.name{nanSstate});
        end
    end % dochkfornans()


end
