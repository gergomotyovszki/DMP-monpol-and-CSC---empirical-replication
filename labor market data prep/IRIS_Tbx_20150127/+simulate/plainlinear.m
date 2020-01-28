function [Y,W] = plainlinear(S,A0,Ea,Eu,NPer,IsDev,IsNonlin)
% plainlinear  [Not a public function] Plain linear simulation.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% TODO: Simplify treatment of ea and eu.

%#ok<*VUNUS>
%#ok<*CTCH>

% The input struct S must at least include
%
% * First-order system matrices: T, R, K, Z, H, D
% * Effect of nonlinear equations: Q, v
%

%--------------------------------------------------------------------------

% First-order solution matrices.
T = S.T;
R = S.R;
K = S.K;
Z = S.Z;
H = S.H;
D = S.D;

ny = size(Z,1);
nx = size(T,1);
nb = size(T,2);
nf = nx - nb;
ne = max( size(Ea,1), size(Eu,1) );
R0 = R(:,1:ne);
colR = size(R,2);
isShkSparse = issparse(Ea);

if IsDev
    K(:) = 0;
    D(:) = 0;
end

Y = nan(ny,NPer);
W = nan(nx,NPer); % W := [xf;alp].

lastA = max([ 0, find(any(Ea ~= 0,1),1,'last') ]);
lastU = max([ 0, find(any(Eu ~= 0,1),1,'last') ]);

% Nonlinear add-factors.
IsNonlin = IsNonlin && ~isempty(S.v) && ~isempty(S.Q);
if IsNonlin
    Q = S.Q;
    v = S.v;
    lastN = max([ 0, find(any(any(v ~= 0,3),1),1,'last') ]);
    colQ = size(Q,2);
end

% Transition variables
%----------------------
wt = [ zeros(nf,1); A0 ];
for t = 1 : NPer
    wt = T*wt(nf+1:end) + K;
    if lastA > 0
        eat = Ea(:,t:t+lastA-1);
        eat = eat(:);
        nAdd = colR - size(eat,1);
        if isShkSparse
            eat = [ eat; sparse(nAdd,1) ]; %#ok<AGROW>
        else
            eat = [ eat; zeros(nAdd,1) ]; %#ok<AGROW>
        end
        wt = wt + R*eat;
        lastA = lastA - 1;
    end
    if lastU > 0
        wt = wt + R0*Eu(:,t);
        lastU = lastU - 1;
    end
    if IsNonlin && lastN > 0
        vt = v(:,t:t+lastN-1);
        vt = vt(:);
        nAdd = colQ - size(vt,1);
        vt = [ vt; zeros(nAdd,1) ]; %#ok<AGROW>
        wt = wt + Q*vt;
        lastN = lastN - 1;
    end
    W(:,t) = wt;
end

% Mesurement variables
%----------------------
if ny > 0
    Y = Z*W(nf+1:end,1:NPer);
    if ~isempty(Ea)
        Y = Y + H*Ea(:,1:NPer);
    end
    if ~isempty(Eu)
        Y = Y + H*Eu(:,1:NPer);
    end
    if ~IsDev && any(D(:) ~= 0)
        Y = Y + D(:,ones(1,NPer));
    end
end

end
