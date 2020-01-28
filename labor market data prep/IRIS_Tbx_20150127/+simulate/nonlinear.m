function [S,ExitFlag,Discrep,AddFact] = nonlinear(S,Opt)
% nonlinear  [Not a public function] Split non-linear simulation into segments of unanticipated
% shocks, and simulate one segment at a time.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(S.Z,1);
nx = size(S.T,1);
nb = size(S.T,2);
nf = nx - nb;
ne = size(S.Ea,1);
nPer = size(S.Ea,2);
lambda0 = Opt.lambda;
nn = sum(S.IxNonlin);

S0 = S;

% Store anticipated and unanticipated shocks outside S and remove them from
% S; they will be supplied in S for a segment specific range in each step.
ea = S.Ea;
eu = S.Eu;
S.Ea = [];
S.Eu = [];

lastEa = max([ 0, find(any(ea ~= 0,1),1,'last') ]);
nPerMax = max( nPer , S.segment(end)+S.NPerNonlin-1 );

% Store all anchors outside S and remove them from S; they will be supplied
% in S for a segment specific range in each step.
yAnch = S.YAnch;
xAnch = S.XAnch;
eaAnch = S.EaAnch;
euAnch = S.EuAnch;
weightsA = S.WghtA;
weightsU = S.WghtU;
yTune = S.YTune;
xTune = S.XTune;
isAAnch = any(eaAnch(:) ~= 0);
isUAnch = any(euAnch(:) ~= 0);

S.YAnch = [];
S.XAnch = [];
S.EaAnch = [];
S.EuAnch = [];
S.WghtA = [];
S.WghtU = [];
S.YTune = [];
S.XTune = [];

% If the last simulated period in the last segment goes beyond `nPer`, we
% expand the below arrays accordingly, so that it is easier to set up their
% segment-specific version in S.
if nPer < nPerMax
    ea(:,end+1:nPerMax) = 0;
    eu(:,end+1:nPerMax) = 0;
    if isAAnch || isUAnch
        yAnch(:,end+1:nPerMax) = false;
        xAnch(:,end+1:nPerMax) = false;
        eaAnch(:,end+1:nPerMax) = false;
        euAnch(:,end+1:nPerMax) = false;
        weightsA(:,end+1:nPerMax) = 0;
        weightsU(:,end+1:nPerMax) = 0;
        yTune(:,end+1:nPerMax) = NaN;
        xTune(:,end+1:nPerMax) = NaN;
    end
end

% Arrays reported in nonlinear simulations.
yRpt = zeros(ny,0);
wRpt = zeros(nx,0);
eaRpt = zeros(ne,0);
euRpt = zeros(ne,0);

% Correction vector for nonlinear equations.
S.v = zeros(nn,0);

nSgm = length(S.segment);

ExitFlag = zeros(1,nSgm);
AddFact = nan(nn,nPerMax,nSgm);
Discrep = nan(nn,nPer);

for iSgm = 1 : nSgm
    % The segment dates are defined by `first` to `last`, a total of `nper1`
    % periods. These are the dates that will be added to the output data.
    % However, the actual range to be simulated can be longer because
    % `lastnonlin` (the number of non-linearised periods) may go beyond `last`.
    % The number of periods simulated is `nper1max`.
    first = S.segment(iSgm);
    S.First = first;
    if iSgm < nSgm
        lastRpt = S.segment(iSgm+1) - 1;
    else
        lastRpt = nPer;
    end
    % Last period simulated in a non-linear mode.
    lastNonlin = first + S.NPerNonlin - 1;
    % Last period simulated.
    lastSim = max([lastRpt,lastNonlin,lastEa]);
    % Number of periods reported in the final output data.
    nPerRep = lastRpt - first + 1;
    % Number of periods simulated.
    nPerSim = lastSim - first + 1;
    nPerChopOff = min(nPerRep,S.NPerNonlin);
    
    % Prepare shocks: Combine anticipated shocks on the whole segment with
    % unanticipated shocks in the initial period.
    range = first : lastSim;
    S.Ea = ea(:,range);
    S.Eu = [ eu(:,first) , zeros(ne,nPerSim-1) ];
    
    % Prepare anchors: Anticipated and unanticipated endogenised shocks cannot
    % be combined in non-linear simulations. If there is no anchors, we can
    % leave the fields empty.
    if isAAnch
        S.YAnch = yAnch(:,range);
        S.XAnch = xAnch(:,range);
        S.EaAnch = eaAnch(:,range);
        S.EuAnch = false(size(S.EaAnch));
        S.WghtA = weightsA(:,range);
        S.WghtU = zeros(size(S.WghtA));
        S.YTune = yTune(:,range);
        S.XTune = xTune(:,range);
    elseif isUAnch
        S.YAnch = [yAnch(:,first),false(ny,nPerSim-1)];
        S.XAnch = [xAnch(:,first),false(nx,nPerSim-1)];
        S.EuAnch = [euAnch(:,first),false(ne,nPerSim-1)];
        S.EaAnch = false(size(S.EuAnch));
        S.WghtU = [weightsU(:,first),zeros(ne,nPerSim-1)];
        S.WghtA = zeros(size(S.WghtU));
        S.YTune = [yTune(:,first),nan(ny,nPerSim-1)];
        S.XTune = [xTune(:,first),nan(nx,nPerSim-1)];
    end
    
    % Reset counters and flags.
    S.Stop = 0;
    S.Count = -1;
    S.lambda = lambda0;
    
    % Re-use addfactors from the previous segment.
    S.v(:,end+1:S.NPerNonlin) = 0;
    
    % Create segment string.
    s = sprintf('%g:%g[%g]#%g',...
        S.zerothSegment+first, ...
        S.zerothSegment+lastRpt, ...
        S.zerothSegment+lastSim, ...
        S.NPerNonlin);
    S.segmentString = sprintf('%16s',s);
    
    % Simulate this segment
    %-----------------------
    S = simulate.segment(S,Opt);
    S = simulate.linear(S,nPerSim,Opt);
    
    % Store results in temporary arrays.
    yRpt = [yRpt,S.y(:,1:nPerRep)]; %#ok<AGROW>
    wRpt = [wRpt,S.w(:,1:nPerRep)]; %#ok<AGROW>
    eaRpt = [eaRpt,S.Ea(:,1:nPerRep)]; %#ok<AGROW>
    euRpt = [euRpt,S.Eu(:,1:nPerRep)]; %#ok<AGROW>
    
    % Update initial condition for next segment.
    S.a0 = S.w(nf+1:end,nPerRep);
    
    % Report diagnostic output arguments.
    Discrep(:,first+(0:nPerChopOff-1)) = S.discrep(:,1:nPerChopOff);
    ExitFlag = [ExitFlag,S.Stop]; %#ok<AGROW>
    AddFact(:,first+(0:size(S.v,2)-1),iSgm) = S.v;
    
    % Remove add-factors within the current segment's reported range. Any
    % add-factors going beyond the reported range end will be used as starting
    % values in the next segment. Note that `u` can be shorter than `nper1`.
    S.v(:,1:nPerChopOff) = [];
    
    % Update progress bar.
    if ~isempty(S.progress)
        update(S.progress, ...
            ((S.iLoop-1)*nSgm+iSgm)/(S.NLoop*nSgm));
    end
end

% Populate simulated data.
S.y = yRpt;
S.w = wRpt;
S.Ea = eaRpt;
S.Eu = euRpt;

% Restore fields temporarily deleted.
S.YAnch = S0.YAnch;
S.XAnch = S0.XAnch;
S.EaAnch = S0.EaAnch;
S.EuAnch = S0.EuAnch;
S.WghtA = S0.WghtA;
S.WghtU = S0.WghtU;
S.YTune = S0.YTune;
S.XTune = S0.XTune;

end
