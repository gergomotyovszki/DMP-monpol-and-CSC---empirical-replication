function [Code,FileStr] = readfile(FileList)
% readfile  [Not a public function] Read and combine input files.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(FileList)
    FileList = {FileList};
end

Code = '';
FileStr = '';
br = sprintf('\n');
nFileList = length(FileList);
for i = 1 : nFileList
    Code = [Code,file2char(FileList{i})]; %#ok<AGROW>
    FileStr = [FileStr,FileList{i}]; %#ok<AGROW>
    if i < nFileList
        Code = [Code,br]; %#ok<AGROW>
        FileStr = [FileStr,' & ']; %#ok<AGROW>
    end
end

end