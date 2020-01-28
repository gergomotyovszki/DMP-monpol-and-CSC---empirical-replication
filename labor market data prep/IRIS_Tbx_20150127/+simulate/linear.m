function S = linear(S,NPer,Opt)
% linear  [Not a public function] Linear simulation.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(NPer,Inf)
    NPer = size(S.Ea,2);
end

allAnch = [S.YAnch;S.XAnch];
S.LastExg = max([ 0, find(any(allAnch,1),1,'last') ]);

if S.LastExg == 0
    
    % Plain simulation
    %------------------
    isDev = Opt.deviation;
    isNonlin = true;
    [S.y,S.w] = simulate.plainlinear(S, ...
        S.a0,S.Ea,S.Eu,NPer,isDev,isNonlin);
    
else
    
    % Simulation with exogenised variables
    %--------------------------------------
    % Position of last anticipated and unanticipated endogenised shock.
    S.LastEndgA = utils.findlast(S.EaAnch);
    S.LastEndgU = utils.findlast(S.EuAnch);
    % Exogenised simulation.
    % Plain simulation first.
    isDev = Opt.deviation;
    isNonlin = true;
    [S.y,S.w] = simulate.plainlinear(S, ...
        S.a0,S.Ea,S.Eu,S.LastExg,isDev,isNonlin);
    % Compute multiplier matrices in the first round only. No
    % need to re-calculate the matrices in the second and further
    % rounds of non-linear simulations.
    if S.Count == 0
        S.M = [ ...
            simulate.multipliers(S,true), ...
            simulate.multipliers(S,false), ...
            ];
    end
    
    % Back out add-factors and add them to shocks.
    S = simulate.exogenise(S);
    
    % Re-simulate with shocks added.
    isDev = Opt.deviation;
    isNonlin = true;
    [S.y,S.w] = simulate.plainlinear(S, ...
        S.a0,S.Ea,S.Eu,NPer,isDev,isNonlin);
end

end
