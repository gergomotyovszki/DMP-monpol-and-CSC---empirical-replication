function S = exogenise(S)
% exogenise  [Not a public function] Compute add-factors to endogenised shocks.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

nx = size(S.T,1);
nb = size(S.T,2);
nf = nx - nb;
ne = size(S.Ea,1);
nPer = size(S.Ea,2);

% Convert w := [xf;a] vector to x := [xf;xb] vector.
x = S.w;
x(nf+1:end,:) = S.U*x(nf+1:end,:);

% Compute prediction errors.
% pe : = [ype(1);xpe(1);ype(2);xpe(2);...].
pe = [];
for t = 1 : S.LastExg
    pe = [pe; ...
        S.YTune(S.YAnch(:,t),t)-S.y(S.YAnch(:,t),t); ...
        S.XTune(S.XAnch(:,t),t)-x(S.XAnch(:,t),t); ...
        ]; %#ok<AGROW>
end

% Compute add-factors that need to be added to the current shocks.
if size(S.M,1) == size(S.M,2)
    
    % Exactly determined system
    %---------------------------
    upd = S.M \ pe;

else
    
    % Underdetermined system (larger number of shocks)
    %--------------------------------------------------
    d = [ ...
        S.WghtA(S.EaAnch); ...
        S.WghtU(S.EuAnch) ...
        ].^2;
    nd = length(d);
    P = spdiags(d,0,nd,nd);
    upd = simulate.updatemean(S.M,P,pe);
    
end

nnzEa = nnz(S.EaAnch(:,1:S.LastEndgA));
ixEa = S.EaAnch(:,1:S.LastEndgA);
ixEu = S.EuAnch(:,1:S.LastEndgU);

if issparse(S.Ea)
    [row,col] = find(ixEa);
    addEa = sparse(row,col,upd(1:nnzEa),ne,nPer);
    S.Ea = S.Ea + addEa;
else
    addEa = zeros(ne,S.LastEndgA);
    addEa(ixEa) = upd(1:nnzEa);
    S.Ea(:,1:S.LastEndgA) = S.Ea(:,1:S.LastEndgA) + addEa;
end

addEu = zeros(ne,S.LastEndgU);
addEu(ixEu) = upd(nnzEa+1:end);
S.Eu(:,1:S.LastEndgU) = S.Eu(:,1:S.LastEndgU) + addEu;

end