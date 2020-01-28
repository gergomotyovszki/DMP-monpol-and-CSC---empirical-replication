function Inx = myselect(This,Type,Select)
% myselect  [Not a public function] Convert user name selection to logical index.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

switch Type
    case {'y',1}
        ixType = This.nametype==1;
        typeString = 'measurement variable';
    case {'x',2}
        ixType = This.nametype==2;
        typeString = 'transition variable';
    case {'e',3}
        ixType = This.nametype==3;
        typeString = 'shock';
    case {'p',4}
        ixType = This.nametype==4;
        typeString = 'parameter';
    otherwise
        utils.error('model:myselect', ...
            'Invalid type of model object name.');
end
n = sum(ixType);

if isempty(Select)
    Inx = false(n,1);
    
elseif islogical(Select)
    Inx = Select(:);
    if length(Inx) < n
        Inx(end+1:n) = false;
    elseif length(Inx) > n
        Inx = Inx(1:n);
    end
    
elseif ~isempty(Select) && (ischar(Select) || iscellstr(Select))
    pos = [];
    if ischar(Select)
        Select = regexp(Select,'\w+','match');
    end
    Select = regexprep(Select,'log\((.*?)\)','$1');
    if iscellstr(Select)
        [pos,notFound] = strfun.findnames(This.name(ixType),Select);
        if ~isempty(notFound)
            utils.error('model:myselect', ...
                ['This is not a valid ',typeString,' name ', ...
                'in the model object: ''%s''.'], ...
                notFound{:});
        end
    end
    Inx = false(n,1);
    Inx(pos) = true;
end

end
