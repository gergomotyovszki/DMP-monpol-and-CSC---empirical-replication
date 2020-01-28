function EstOpt = myoptimopts(EstOpt)
% myoptimoptions  [Not a public function] Set up Optim Tbx options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

solverName = EstOpt.solver;
if iscell(solverName)
    solverName = solverName{1};
end
if isfunc(solverName)
    solverName = func2str(solverName);
end

switch lower(solverName)
    case 'pso'
        if strcmpi(EstOpt.nosolution,'error')
            utils.warning('estimateobj:myoptimopts', ...
                ['Global optimization algorithm, ', ...
                'switching from ''noSolution=error'' to ', ...
                '''noSolution=penalty''.']);
            EstOpt.nosolution = 'penalty';
        end
    case {'fmin','fmincon','fminunc','lsqnonln','fsolve'}
        switch lower(solverName)
            case {'lsqnonlin','fsolve'}
                algorithm = 'levenberg-marquardt';
            otherwise
                algorithm = 'active-set';
        end
        oo = optimset( ...
            'Algorithm',algorithm, ...
            'GradObj','off', ...
            'Hessian','off', ...
            'LargeScale','off');
        try %#ok<TRYNC>
            oo = optimset(oo,'Display',EstOpt.display);
        end
        try %#ok<TRYNC>
            oo = optimset(oo,'MaxIter',EstOpt.maxiter);
        end
        try %#ok<TRYNC>
            oo = optimset(oo,'MaxFunEvals',EstOpt.maxfunevals);
        end
        try %#ok<TRYNC>
            oo = optimset(oo,'TolFun',EstOpt.tolfun);
        end
        try %#ok<TRYNC>
            oo = optimset(oo,'TolX',EstOpt.tolx);
        end
        if ~isempty(EstOpt.optimset) && iscell(EstOpt.optimset) ...
                && iscellstr(EstOpt.optimset(1:2:end))
            temp = EstOpt.optimset;
            temp(1:2:end) = strrep(temp(1:2:end),'=','');
            oo = optimset(oo,temp{:});
        end
        EstOpt.optimset = oo;
    otherwise
        % Do nothing.
end

end
