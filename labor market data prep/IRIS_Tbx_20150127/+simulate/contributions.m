function S = contributions(S,NPer,Opt)
% contributions  Compute contributions of shocks, init cond & const, and nonlinearities.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(S.Z,1);
nx = size(S.T,1);
nb = size(S.T,2);
ne = size(S.Ea,1);
if isequal(NPer,Inf)
    NPer = size(S.Ea,2);
end

S.y = zeros(ny,NPer,ne+2);
S.w = zeros(nx,NPer,ne+2); % := [xf;alp]

% Store input shocks.
ea0 = S.Ea;
eu0 = S.Eu;

% Pre-allocate space for output contributions.
S.Ea = zeros(size(ea0,1),size(ea0,2),ne+2);
S.Eu = zeros(size(eu0,1),size(eu0,2),ne+2);

% Contributions of individual shocks.
isDev = true;
isNonlin = false;
for ii = 1 : ne
    S.Ea(ii,:,ii) = ea0(ii,:);
    S.Eu(ii,:,ii) = eu0(ii,:);
    [S.y(:,:,ii),S.w(:,:,ii)] = simulate.plainlinear(S, ...
        zeros(nb,1),S.Ea(:,:,ii),S.Eu(:,:,ii),NPer,isDev,isNonlin);
end

% Contribution of initial condition and constant; no shocks included.
isDev = Opt.deviation;
isNonlin = false;
[S.y(:,:,ne+1),S.w(:,:,ne+1)] = simulate.plainlinear(S, ...
    S.a0,[],[],NPer,isDev,isNonlin);

% Leave the contributions of nonlinearities zeros.

end