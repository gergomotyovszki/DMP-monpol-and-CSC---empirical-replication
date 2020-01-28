function [List,Values,S] = mygetcorr(This,IsNonzeroOnly)
% mygetcorr  [Not a public function] Return names and values of corr coefficients in stdcorr vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

try
    IsNonzeroOnly; %#ok<VUNUS>
catch
    IsNonzeroOnly = false;
end

%--------------------------------------------------------------------------

ne = sum(This.nametype == 3);
nAlt = size(This.Assign,3);
pos = tril(ones(ne),-1) == 1;
R = zeros(ne,ne,nAlt);
for iAlt = 1 : nAlt
    iR = zeros(ne);
    iCorr = This.stdcorr(1,ne+1:end,iAlt);
    iR(pos) = iCorr;
    R(:,:,iAlt) = iR;
end

if IsNonzeroOnly
    [occRow,occCol] = find(any(R ~= 0,3));
else
    [occRow,occCol] = find(pos);
end

eList = This.name(This.nametype == 3);
nOcc = length(occRow);
List = cell(1,nOcc);
for iOcc = 1 : length(occRow)
    name = ['corr_',eList{occCol(iOcc)},'__',eList{occRow(iOcc)}];
    List{iOcc} = name;
end

if nargout <= 1
    return
end

Values = zeros(1,nOcc,nAlt);
for iOcc = 1 : nOcc
    Values(1,iOcc,:) = R(occRow(iOcc),occCol(iOcc),:);
end

if nargout <= 2
    return
end

S = struct();
for iOcc = 1 : nOcc
    name = List{iOcc};
    S.(name) = permute(R(occRow(iOcc),occCol(iOcc),:),[2,3,1]);
end

end

