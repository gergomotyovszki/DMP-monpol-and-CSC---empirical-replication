function hdataassign(This,Pos,Data)
% hdataassign  [Not a public function] Assign currently processed data to hdataobj.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

% hdataassign( HData, Cols, {Y,X,E,...} )

%--------------------------------------------------------------------------

nPack = length(This.Id);
nData = length(Data);

for i = 1 : min(nPack,nData)
    
    if isempty(Data{i})
        continue
    end
    
    X = Data{i};
    nPer = size(X,2);
    if This.IsVar2Std
        doVar2Std();
    end
    
    % Permute X from nName-nPer-nCol to nPer-nCol-nName.
    X = permute(X,[2,3,1]);
    
    realId = real(This.Id{i});
    imagId = imag(This.Id{i});
    maxLag = -min(imagId);
    t = maxLag + (1 : nPer);
    
    if This.IncludeLag && maxLag > 0
        % Each variable has been allocated an (nPer+maxLag)-by-nCol array. Get
        % pre-sample data from auxiliary lags.
        for j = find(imagId < 0)
            jLag = -imagId(j);
            This.Data.( This.Name{realId(j)} ) ...
                (maxLag+1-jLag,Pos) = X(1,:,j);
        end
        % Assign current dates.
        for j = find(imagId == 0)
            This.Data.( This.Name{realId(j)} )(t,Pos) = X(:,:,j);
        end
    else
        % Assign current dates only.
        for j = find(imagId == 0)
            This.Data.( This.Name{realId(j)} )(:,Pos) = X(:,:,j);
        end
    end
end


% Nested functions...


%**************************************************************************


    function doVar2Std()
        % doVar2Std  Convert vectors of vars to vectors of stdevs.
        if isempty(X)
            return
        end
        tol = 1e-15;
        ixNeg = X < tol;
        if any(ixNeg(:))
            X(ixNeg) = 0;
        end
        X = sqrt(X);
    end % doVar2Std()
end