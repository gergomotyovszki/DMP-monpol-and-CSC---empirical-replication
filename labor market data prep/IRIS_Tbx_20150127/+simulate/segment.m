function S = segment(S,Opt)
% segment  [Not a public function] Non-linear simulation of one segment.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

realexp = @(x) real(exp(x));
nx = size(S.T,1);
nb = size(S.T,2);
nf = nx - nb;
ne = size(S.Ea,1);
nEqtn = length(S.eqtn);
L = S.L;

% Plain solver
%--------------
if strcmpi(Opt.solver,'plain')
    curr = struct();
    curr.maxDiscrep = [];
    curr.maxDiscrep2 = [];
    curr.maxAddFactor = [];
    curr.maxAddFactor2 = [];
    curr.v = S.v;
    curr.count = NaN;
    
    best = struct();
    best.maxDiscrep = Inf;
    best.maxDiscrep2 = [];
    best.maxAddFactor = Inf;
    best.maxAddFactor2 = [];
    best.v = [];
    best.count = NaN;
    
    while true
        % Simulate and compute discrepancies
        %------------------------------------
        doSimulateDiscrep(curr.v);
        doMaxDiscrep();
        
        % Report
        %--------
        % Report discrepancies in this iteration if requested or if
        % this is the final iteration.
        if Opt.display > 0 && mod(S.Count,Opt.display) == 0
            doReport();
        end
        
        if S.Stop ~= 0
            if curr.maxDiscrep > best.maxDiscrep
                curr = best;
                if Opt.display > 0
                    doReportReverse();
                end
            end
            if Opt.display > 0
                doReport();
                fprintf('\n');
            end
            break
        end
        
        % Update and lambda control
        %---------------------------
        doUpdLambda();
    end
    
    S.v = curr.v;
end


% Optimization Tbx
%------------------
if isfunc(Opt.solver)
    if Opt.display > 0
        Opt.display = 'iter';
    else
        Opt.display = 'none';
    end
    Opt = optim.myoptimopts(Opt);
    v0 = S.v;
    if isequal(Opt.solver,@fsolve)
        [v1,~,exitFlag] = ...
            fsolve(@doSimulateDiscrep,v0,Opt.optimset);
    elseif isequal(Opt.solver,@lsqnonlin)
        [v1,~,~,exitFlag] = ...
            lsqnonlin(@doSimulateDiscrep,v0,[],[],Opt.optimset);
    end
    S.v = v1;
    if exitFlag > 0
        S.Stop = 1;
    else
        S.Stop = -1;
    end
end

% Failed to converge
%--------------------
if S.Stop < 0
    doFailure();
end


% Nested functions...


%**************************************************************************

    
    function D = doSimulateDiscrep(V)
        S.Count = S.Count + 1;
        S.v = V;
        % Simulate linearized system with nonlinear add-factors
        %-------------------------------------------------------
        S = simulate.linear(S,S.NPerNonlin,Opt);
        
        % Evaluate discrepancies
        %------------------------
        range = 1 : S.NPerNonlin; 
        % Set up the vector of [xf;xb] and include initial condition.
        xx = [ [nan(nf,1);S.a0] , S.w(:,range) ];
        xx(nf+1:end,:) = S.U*xx(nf+1:end,:);
        if S.IsDeviation && S.IsAddSstate
            xx = xx + S.XBar;
        end
        
        % Delogarithmise log variables.
        xx(S.IxXLog,:) = realexp(xx(S.IxXLog,:));
        
        % Set up the vector of shocks including initial condition.
        e = [ zeros(ne,1) , S.Ea(:,range)+S.Eu(:,range) ];
        % No measurement variables in the transition equations.
        y = [ ];
        % Get the current parameter values.
        p = S.Assign(1,S.nametype == 4);
        D = zeros(nEqtn,1+S.NPerNonlin);
        nanInx = false(1,nEqtn);
        errMsg = { };
        evalInx = [false,S.QAnch];
        if any(evalInx)
            tVec = find(evalInx);
            % "Absolute time" within the entire nonlinear simulation for sstate
            % references.
            TVec = -S.MinT + S.First + tVec - 2;
            for j = find(S.IxNonlin)
                try
                    dj = S.EqtnN{j}(y,xx,e,p,tVec,L,TVec);
                    nanInx(j) = any(~isfinite(dj));
                    D(j,evalInx) = dj;
                catch Err
                    errMsg{end+1} = S.eqtn{j}; %#ok<AGROW>
                    errMsg{end+1} = Err.message; %#ok<AGROW>
                end
            end
        end
        if ~isempty(errMsg)
            utils.error('simulate:segment', ...
                ['Error evaluating this nonlinear equation: ''%s''.\n ', ...
                '\tUncle says: %s'], ...
                errMsg{:});
        end
        if any(nanInx)
            utils.error('simulate:segment', ...
                ['This nonlinear equation produces ', ...
                'NaN or Inf: ''%s''.'], ...
                S.eqtn{nanInx});
        end
        D = D(S.IxNonlin,2:end);
        S.discrep = D;
    end % doSimulateDiscrep()


%**************************************************************************
 

    function doMaxDiscrep()
        % Maximum discrepancy and max addfactor.
        curr.maxDiscrep2 = max(abs(S.discrep),[],2);
        curr.maxDiscrep = max(curr.maxDiscrep2);
        curr.maxAddFactor2 = max(abs(curr.v),[],2);
        curr.maxAddFactor = max(curr.maxAddFactor2);
        if curr.maxDiscrep < best.maxDiscrep
            best = curr;
            best.count = S.Count;
        end
        if ~isfinite(curr.maxDiscrep)
            S.Stop = -2;
        elseif curr.maxDiscrep <= Opt.tolerance
            S.Stop = 1;
        elseif S.Count >= Opt.maxiter;
            S.Stop = -1;
        end
    end % doMaxDiscrep()


%**************************************************************************


    function doUpdLambda()
        if curr.maxDiscrep < Opt.upperbound*best.maxDiscrep %...
            %|| S.maxAddFactor < upperBound*S.histMinAddFactor
            addV = S.discrep;
            if ~Opt.fillout
                addV(abs(addV) <= Opt.tolerance) = 0;
            end
            addV = S.lambda .* addV;
            curr.v = curr.v - addV;
        else
            % If the current discrepancy is `upperBound` times the historical minimum
            % (or more), reverse the process to the historical minimum, and reduce
            % `lambda`.
            curr = best;
            S.lambda = S.lambda * Opt.reducelambda;
            if Opt.display > 0
                doReportReverse();
                doReportLambdaReduction();
            end
        end        
    end % doUpdLambda()
    

%**************************************************************************


    function doReport()
        % doReport  Report one nonlin simulation iteration.
        maxDiscrepEqtn = ...
            findnaninf(curr.maxDiscrep2,curr.maxDiscrep,1,'first');
        maxAddFactorEqtn = ....
            findnaninf(curr.maxAddFactor2,curr.maxAddFactor,1,'first');
        if S.Count == 0 && S.Stop == 0
            % This is the very first report line printed. Print the
            % header first.
            fprintf(...
                '%16s %6.6s %12.12s %-20.20s %7.7s %12.12s %-20.20s\n',...
                'Segment#NPer','Iter','Max.discrep','Equation','Lambda', ...
                'Max.addfact','Equation' ...
                );
        end
        count = sprintf(' %5g',S.Count);
        if S.Stop ~= 0
            count = strrep(count,' ','=');
        end
        lambda = sprintf('%7g',S.lambda);
        maxDiscrep = sprintf('%12g',curr.maxDiscrep);
        maxDiscrepLabel = S.label{maxDiscrepEqtn};
        maxDiscrepLabel = strfun.ellipsis(maxDiscrepLabel,20);
        maxAddFactor = sprintf('%12g',curr.maxAddFactor);
        maxAddFactorLabel = S.label{maxAddFactorEqtn};
        maxAddFactorLabel = strfun.ellipsis(maxAddFactorLabel,20);
        % Print current report line.
        fprintf(...
            '%s %s %s %s %s %s %s\n',...
            S.segmentString,count, ...
            maxDiscrep,maxDiscrepLabel,lambda, ...
            maxAddFactor,maxAddFactorLabel ...
            );
    end % doReport()


%**************************************************************************

    
    function doReportReverse()
        fprintf('  Reversing to iteration %g.\n', ...
            best.count);
    end % doReportReverse()


%**************************************************************************

    
    function doReportLambdaReduction()
        fprintf('  Reducing lambda to %g.\n', ...
            S.lambda);
    end % doReportLambdaReduction()


%**************************************************************************


    function doFailure()
        if Opt.error
            % @@@@@ MOSW
            msgFunc = @(varargin) utils.error(varargin{:});
        else
            % @@@@@ MOSW
            msgFunc = @(varargin) utils.warning(varargin{:});
        end
        
        switch S.Stop
            case -1
                msgFunc('model', ...
                    ['Non-linear simulation #%g, segment %s, ', ...
                    'reached max number of iterations ', ...
                    'without convergence.'], ...
                    S.iLoop,strtrim(S.segmentString));
            case -2
                msgFunc('model', ...
                    ['Non-linear simulation #%g, segment %s, ', ...
                    'crashed at Inf, -Inf, or NaN.'], ...
                    S.iLoop,strtrim(S.segmentString));
        end
    end % doFailure()
end
