function export(This)
% export  Save carry-around files to disk file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

E = This.Export;
if isempty(E) || ~isstruct(E)
    return
end

n = length(E);
thisDir = pwd();
deleted = false(1,n);
file = cell(1,n);
br = sprintf('\n');
stamp = [ ...
    '% IRIS carry-around file exported on ',datestr(now()),br, ...
    ];
for i = 1 : n
    c = E(i).Content;
    file{i} = fullfile(thisDir,E(i).FName);
    if exist(file{i},'file')
        deleted(i) = true;
    end
    c = [stamp,br,c]; %#ok<AGROW>
    char2file(c,file{i});
end

if any(deleted)
    utils.warning('userdataobj:export', ...
        ['This file has been deleted when creating a carry-around file ', ...
        'with the same name: ''%s''.'], ...
        file{deleted});
end
rehash();

end
