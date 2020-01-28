function [Code,Labels,Export,Subs,Comment] ...
    = parse(Code,FileStr,Asgn,Labels,Export,ParentFile,Opt)
% parse  [Not a public function] Run preparser.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

if isempty(Asgn)
    Asgn = struct([]);
end

if isempty(Export)
    Export = struct('FName',{},'Content',{});
end

if isempty(ParentFile)
    ParentFile = '';
end

if isempty(Opt.removecomments)
    Opt.removecomments = {};
end

%--------------------------------------------------------------------------

Comment = ''; %#ok<NASGU>
Subs = struct();

if isempty(FileStr)
    ep = 'Error preparsing input code. ';
else
    FileStr = mosw.sprintf('<a href="matlab:edit %s">%s</a>',FileStr,FileStr);
    if ~isempty(ParentFile)
        FileStr = [ParentFile,' > ',FileStr];
    end
    ep = ['Error preparsing file(s) ',FileStr,'. '];
end

% Convert end of lines.
Code = strfun.converteols(Code);

% Check if there is an initial %% comment line that will be used as comment
% in model objects.
match = regexp(Code,'(?<=^\n*%%)[^\n]+','match','once');
Comment = strtrim(match);

% Read quoted strings 'xxx' and "xxx" and replace them with charcodes.
% The quoted strings must not stretch across mutliple lines.
if isnan(Labels)
    % Initialise the fragileobj object.
    Labels = fragileobj(Code);
end
[Code,Labels] = protectquotes(Code,Labels);

% Remove standard line and block comments.
Code = preparser.removecomments(Code,Opt.removecomments{:});

% Remove triple exclamation point !!!.
% This mark is meant to be used to highlight some bits of the code.
Code = strrep(Code,'!!!','');

% Replace @keywords with !keywords. This is for backward compatibility
% only.
Code = xxPrefix(Code);

% Discard everything after !stop.
pos = strfind(Code,'!stop');
if ~isempty(pos)
    Code = Code(1:pos(1)-1);
end

% Add a white space at the end.
Code = [Code,sprintf('\n')];

% Execute control commands
%--------------------------
% Evaluate and expand the following control commands:
% * !if .. !else .. !elseif .. !end
% * !for .. !do .. !end
% * !switch .. !case ... !otherwise .. !end
% * !export .. !end
[Code,Labels,Export] ...
    = preparser.controls(Code,Asgn,ep,Labels,Export);

% Import external files
%-----------------------

[Code,Labels,Export] = xxImport(Code,Asgn,Labels,Export,FileStr,Opt);

% Expand pseudofunctions
%------------------------

[Code,invalid] = preparser.pseudofunc(Code);
if ~isempty(invalid)
    invalid = xxFormatError(invalid,Labels);
    utils.error('preparser:parse',[ep, ...
        'Invalid pseudofunction: ''%s''.'], ...
        invalid{:});
end

% Expand substitutions $xxx$
%----------------------------
% Expand substitutions in the top file after all imports have been done.
if isempty(ParentFile)
    [Code,Subs,leftover,multiple,undef] ...
        = preparser.substitute(Code);
    if ~isempty(leftover)
        leftover = xxFormatError(leftover,Labels);
        utils.error('preparser:parse',[ep, ...
            'There is a leftover code in a substitutions block: ''%s''.'], ...
            leftover{:});
    end
    if ~isempty(multiple)
        multiple = xxFormatError(multiple,Labels);
        utils.error('preparser:parse',[ep, ...
            'This substitution name is defined more than once: ''%s''.'], ...
            multiple{:});
    end
    if ~isempty(undef)
        utils.error('preparser:parse',[ep, ...
            'This is an unresolved or undefined substitution: ''%s''.'], ...
            undef{:});
    end
end

% Evaluate expressions $(K-1)$
%------------------------------
[Code,invalid] = preparser.pseudosubs(Code,Asgn,Labels);
if ~isempty(invalid)
    invalid = xxFormatError(invalid,Labels);
    utils.error('preparser:parse',[ep, ...
        'Cannot evaluate this expression: ''%s''.'], ...
        invalid{:});
end

% Remove leading and trailing empty lines.
Code = strfun.removeltel(Code);

end


% Subfunctions...


%**************************************************************************


function Code = xxPrefix(Code)
% doprefix  Replace @keywords with !keywords.
Code = regexprep(Code,'@([a-z]\w*)','!$1');
end % xxPrefix()


%**************************************************************************


function [Code,Labels,Export] ...
    = xxImport(Code,Asgn,Labels,Export,ParentFile,Opt)
% doimport  Import external file.
% Call import/include/input files with replacement.
pattern = '(?:!include|!input|!import)\((.*?)\)';
while true
    [tokens,start,finish] = ...
        regexp(Code,pattern,'tokens','start','end','once');
    if isempty(tokens)
        break
    end
    fname = strtrim(tokens{1});
    if ~isempty(fname)
        [impCode,fileStr] = preparser.readfile(fname);
        [impCode,Labels,Export] = preparser.parse(impCode,fileStr, ...
            Asgn,Labels,Export,ParentFile,Opt);
        Code = [Code(1:start-1),impCode,Code(finish+1:end)];
    end
end
end % xxImport()


%**************************************************************************


function C = xxFormatError(C,Labels)
if iscell(C)
    for i = 1 : length(C)
        C{i} = xxFormatError(C{i},Labels);
    end
    return
end
C = restore(C,Labels,'delimiter=',true);
C = regexprep(C,'\s+',' ');
C = strtrim(C);
C = strfun.maxdisp(C,40);
end % xxFormatError()
