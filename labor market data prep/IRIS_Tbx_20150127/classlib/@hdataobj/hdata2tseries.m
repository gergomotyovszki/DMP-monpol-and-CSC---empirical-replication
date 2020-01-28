function D = hdata2tseries(This)
% hdata2tseries  [Not a public function] Convert hdataobj data to a tseries database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

template = tseries();
realexp = @(x) real(exp(x));

D = struct();

for i = 1 : length(This.Id)

    if isempty(This.Id{i})
        continue
    end
    
    realId = real(This.Id{i});
    imagId = imag(This.Id{i});
    maxLag = -min(imagId);

    if This.IncludeLag && maxLag > 0
        xRange = This.Range(1)-maxLag : This.Range(end);
    else
        xRange = This.Range(1) : This.Range(end);
    end
    xStart = xRange(1);
    nXPer = length(xRange);
    
    for j = sort(realId(imagId == 0))
        name = This.Name{j};
        
        if ~isfield(This.Data,name)
            continue
        end
        sn = size(This.Data.(name));
        if sn(1) ~= nXPer
            doThrowInternal();
        end
        if This.IxLog(j)
            This.Data.(name) = realexp(This.Data.(name));
        end
        
        % Create a new database entry.
        D.(name) = template;
        D.(name) = mystamp(D.(name));
        D.(name).start = xStart;
        D.(name).data = This.Data.(name);
        s = size(D.(name).data);
        D.(name).Comment = repmat({''},[1,s(2:end)]);
        D.(name) = mytrim(D.(name));
        if isempty(This.Contributions)
            c = This.Label{j};
        else
            c = utils.concomment(name, ...
                This.Contributions,This.IxLog(j));
        end
        D.(name) = comment(D.(name),c);
        
        % Free memory.
        This.Data.(name) = [];
    end
    
end

if This.IncludeParam
    list = fieldnames(This.ParamDb);
    for i = 1 : length(list)
    	D.(list{i}) = This.ParamDb.(list{i});
    end
end


% Nested functions...


%**************************************************************************


    function doThrowInternal()
        utils.error('hdataobj:hdata2tseries','#Internal');
    end % doThrowInternal()


end
