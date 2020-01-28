function [Obj,Lik,PP,SP] = objfunc(X,This,Data,Pri,EstOpt,LikOpt)
% objfunc  [Not a public function] Evaluate minus log posterior.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.
    
%--------------------------------------------------------------------------

Obj = 0; % Minus log posterior.
Lik = 0; % Minus log data likelihood.
PP = 0; % Minus log parameter prior.
SP = 0; % Minus log system prior.

isLik = EstOpt.evallik;
isPPrior = EstOpt.evalpprior && any(Pri.priorindex);
isSPrior = EstOpt.evalsprior && ~isempty(Pri.sprior);

% Evaluate parameter priors.
if isPPrior
    PP = estimateobj.myevalpprior(X,Pri);
    Obj = Obj + PP;
end

% Update model with new parameter values; do this before evaluating the
% system priors.
if isLik || isSPrior
    isThrowErr = strcmpi(EstOpt.nosolution,'error');
    [This,UpdateOk] = myupdatemodel(This,X,Pri,EstOpt,isThrowErr);
    if ~UpdateOk
        Obj = Inf;
    end
end

% Evaluate system priors.
if isfinite(Obj) && isSPrior
    % The function `evalsystempriors` returns minus log density.
    SP = evalsystempriors(This,Pri.sprior);
    Obj = Obj + SP;
end

% Evaluate data likelihood.
if isfinite(Obj) && isLik
    % Evaluate minus log likelihood; no data output is required.
    Lik = LikOpt.minusLogLikFunc(This,Data,[],LikOpt);
    % Sum up minus log priors and minus log likelihood.
    Obj = Obj + Lik;
end

isValid = isnumeric(Obj) && length(Obj) == 1 ...
    && isfinite(Obj) && imag(Obj) == 0;
if ~isValid
    if isnumeric(EstOpt.nosolution)
        penalty = EstOpt.nosolution;
    else
        penalty = 1e10;
    end
    Obj = penalty;
end

% Make sure Obj is a double, otherwise Optim Tbx will complain.
Obj = double(Obj);

end
