function [Ans,Flag,Query] = specget(This,Query)
% specget  [Not a public function] GET method for modelobj objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Call superclass `specget` first.
[Ans,Flag,Query] = specget@userdataobj(This,Query);
if Flag
    return
end

Ans = [];
Flag = true;

nAlt = size(This.Assign,3);
ne = sum(This.nametype==3);

switch lower(Query)
    
    case 'file'
        Ans = This.FName;
        
    case {'name','list'}
        Ans = This.name;
        
    case {'ylist','xlist','elist','plist','glist'}
        type = find(Query(1) == 'yxepg');
        Ans = This.name(This.nametype == type);
        
    case {'ydescript','xdescript','edescript','pdescript','gdescript'}
        inx = find(Query(1) == 'yxepg');
        Ans = This.namelabel(This.nametype == inx);

    case {'yalias','xalias','ealias','palias','galias'}
        inx = find(Query(1) == 'yxepg');
        Ans = This.namealias(This.nametype == inx);
        
    case 'descript'
        Ans = cell2struct(This.namelabel,This.name,2);

    case 'alias'
        Ans = cell2struct(This.namealias,This.name,2);
        
    case 'param'
        % Plain parameters.
        asgn = This.Assign(1,This.nametype == 4,:);
        asgnList = This.name(This.nametype == 4);
        % Std errors.
        [stdList,std] = mygetstd(This);
        % Corr coefficients.
        isNonzeroOnly = true;
        [corrList,corr] = mygetcorr(This,isNonzeroOnly);
        % Combine everything and build output struct.
        pValues = permute([asgn,std,corr],[2,3,1]);
        list = [asgnList,stdList,corrList];
        Ans = cell2struct( num2cell(pValues,2), list(:), 1 );
        
    case 'std'
        [~,~,Ans] = mygetstd(This);
        
    case {'corr','nonzerocorr'}
        isNonzeroOnly = strcmpi(Query,'nonzerocorr');
        [~,~,Ans] = mygetcorr(This,isNonzeroOnly);
        
    case 'stdlist'
        elist = This.name(This.nametype == 3);
        Ans = strcat('std_',elist);
        
    case 'corrlist'
        Ans = mygetcorr(This);
        
    case 'stdcorrlist'
        elist = This.name(This.nametype == 3);
        Ans = strcat('std_',elist);
        Ans = [Ans,mygetcorr(This)];
        
    case {'log','islog'}
        Ans = struct();
        for iType = find(This.nametype <= 3);
            Ans.(This.name{iType}) = This.IxLog(iType);
        end
        
    case {'loglist'}
        Ans = This.name(This.IxLog & This.nametype ~= 4);
        
    case {'nonloglist'}
        Ans = This.name(~This.IxLog & This.nametype ~= 4);
        
    case {'covmat','omega'}
        Ans = omega(This);
        
    case {'stdvec'}
        Ans = permute(This.stdcorr(1,1:ne,:),[2,3,1]);
        
    case {'stdcorrvec'}
        Ans = permute(This.stdcorr,[2,3,1]);
        
    case {'nalt'}
        Ans = nAlt;
        
    case {'nametype'}
        Ans = This.nametype;
                
    case {'torigin','baseyear'}
        Ans = This.BaseYear;
        if isempty(Ans)
            Ans = irisget('baseYear');
        end
        
    case 'build'
        Ans = This.Build;

    % Equations
    %-----------
    
    case {'eqtn'}
%         maxType = max(This.eqtntype);
%         Ans = cell(1,maxType);
%         for iType = 1 : maxType
%             Ans{iType} = This.eqtn(This.eqtntype == iType);
%         end
        Ans = This.eqtn;

    case {'yeqtn','xeqtn'}
        type = find(Query(1) == 'yx');
        Ans = This.eqtn(This.eqtntype == type);
                
    % Equation labels and aliases
    %-----------------------------

    case {'label','eqtnalias'}
        if strcmp(Query,'label')
            prop = 'eqtnlabel';
        else
            prop = 'eqtnalias';
        end
        Ans = This.(prop);

    case {'xlabel','ylabel'}
        type = find(Query(1) == 'yx');
        Ans = This.eqtnlabel(This.eqtntype == type);

    case {'xeqtnalias','yeqtnalias'}
        type = find(Query(1) == 'yx');
        Ans = This.eqtnalias(This.eqtntype == type);
        
    otherwise
        Flag = false;
        
end

end
