function publish(InpFile,varargin)
% publish  Publish m-file or model file to PDF.
%
%
% Syntax
% =======
%
%     latex.publish(InpFile)
%     latex.publish(InpFile,...)
%
%
% Input arguments
% ================
%
% * `InpFile` [ char | cellstr ] - Input file name; can be either an
% m-file, a model file, or a cellstr combining a number of them.
%
%
% Options
% ========
%
% General options
% ----------------
%
% * `'cleanup='` [ *`true`* | `false` ] - Delete all temporary files
% (LaTeX and eps) at the end.
%
% * `'closeAll='` [ *`true`* | `false` ] - Close all figure windows at the
% end.
%
% * `'display='` [ *`true`* | `false` ] - Display pdflatex compiler report.
%
% * `'evalCode='` [ *`true`* | `false` ] - Evaluate code when publishing the
% file; the option is only available with m-files.
%
% * `'useNewFigure='` [ `true` | *`false`* ] - Open a new figure window for each
% graph plotted.
%
% Content-related options
% ------------------------
%
% * `'author='` [ char | *empty* ] - Author that will be included on the
% title page.
%
% * `'date='` [ char | *'\today' ] - Publication date that will be included
% on the title page.
%
% * `'event='` [ char | *empty* ] - Event (conference, workshop) that will
% be included on the title page.
%
% * `'figureFrame='` [ `true` | *`false`* ] - Draw frames around figures.
%
% * `'figureScale='` [ numeric | *`1`* ] - Factor by which the graphics
% will be scaled.
%
% * `'figureTrim='` [ numeric | *`[50,200,50,150]`* ] - Trim excessive
% white margines around figures by the specified amount of points left,
% bottom, right, top.
%
% * `'irisVersion='` [ *`true`* | `false` ] - Display the current IRIS version
% in the header on the title page.
%
% * `'lineSpread='` [ numeric | *'auto'*] - Line spacing.
%
% * `'matlabVersion='` - Display the current Matlab version in the header on
% the title page.
%
% * `'numbered='` - [ *`true`* | `false` ] - Number sections.
%
% * `'package='` - [ cellstr | char | *`'inconsolata'`* ] - List of
% packages that will be loaded in the preamble.
%
% * `'paperSize='` -  [ 'a4paper' | *'letterpaper'* ] - Paper size.
%
% * `'preamble='` - [ char | *empty* ] - LaTeX commands
% that will be included in the preamble of the document.
%
% * `'template='` - [ *'paper'* | 'present' ] - Paper-like or
% presentation-like format.
%
% * `'textScale='` - [ numeric | *0.70* ] - Proportion of the paper used for
% the text body.
%
% * `'toc='` - [ *`true`* | `false` ] - Include the table of contents.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('InpFile',@ischar);
pp.parse(InpFile);

% Bkw compatibility.
if ~isempty(varargin) && isempty(varargin{1})
    varargin(1) = [];
end

opt = passvalopt('latex.publish',varargin{:});

if opt.toc && ~opt.numbered
    utils.error('latex', ...
        'Options ''numbered'' and ''toc'' are used inconsistently.');
end

[inputPath,inputTitle,inputExt] = fileparts(InpFile);
texFile = [inputTitle,'.tex'];
OutpFile = fullfile(inputPath,[inputTitle,'.pdf']);
if isempty(inputExt)
    inputExt = '.m';
end

% Old option name.
if ~isempty(opt.deletetempfiles)
    opt.cleanup = opt.deletetempfiles;
end

%--------------------------------------------------------------------------

br = sprintf('\n');

switch lower(opt.template)
    case 'paper'
        template = file2char(fullfile(irisroot(),'+latex','paper.tex'));
        if ~isnumericscalar(opt.linespread)
            opt.linespread = 1.1;
        end
    case 'present'
        template = file2char(fullfile(irisroot(),'+latex','present.tex'));
        if ~isnumericscalar(opt.linespread)
            opt.linespread = 1;
        end
        opt.toc = false;
    otherwise
        template = file2char(opt.template);
        if ~isnumericscalar(opt.linespread)
            opt.linespread = 1;
        end
end
template = strfun.converteols(template);

thisDir = pwd();
wDir = tempname(thisDir);
mkdir(wDir);

% Run input files with compact spacing.
spacing = get(0,'formatSpacing');
set(0,'formatSpacing','compact');

% Create mfile2xml (publish) options. The output directory is assumed to
% always coincide with the input file directory.
m2xmlOpt = struct( ...
    'format','xml', ...
    'outputDir',wDir, ...
    'imageFormat','pdf', ...
    'figureSnapMethod','print', ...
    'createThumbnail',false, ...
    'evalCode',opt.evalcode, ...
    'useNewFigure',opt.usenewfigure);

% Try to copy all tex files to the working directory in case there are
% \input or \include commands.
try %#ok<TRYNC>
    copyfile('*.tex',wDir);
end

% Produce XMLDOMs.
copy = xxPrepareToPublish([inputTitle,inputExt]);
% Only m-files can be published with `'evalCode='` true.
if isequal(inputExt,'.m')
    m2xmlOpt.evalCode = opt.evalcode;
else
    m2xmlOpt.evalCode = false;
end
% Switch off warnings produced by the built-in publish when conversion
% of latex equations to images fails.
ss = warning();
warning('off');%#ok<WNOFF>
% Publish the m-file into an xml file and read the file in again as xml
% object.
xmlFile = publish([inputTitle,inputExt],m2xmlOpt);
warning(ss);
xmlDoc = xmlread(xmlFile);
char2file(copy,[inputTitle,inputExt]);


% Reset spacing.
set(0,'formatSpacing',spacing);

% Switch to the working directory so that `xml2tex` can find the graphics
% files.
cd(wDir);
try
    body = '';
    [tex,author,event] = latex.xml.xml2tex(xmlDoc,opt);
    if isempty(opt.author) && ischar(author)
        opt.author = author;
    end
    if isempty(opt.author) && ischar(event)
        opt.event = event;
    end
    tex = xxDocSubs(tex,opt);
    char2file(tex,texFile);
    body = [body,'\input{',texFile,'}',br];
    
    template = strrep(template,'$body$',body);
    template = xxDocSubs(template,opt);
    
    char2file(template,'main.tex');
    latex.compilepdf('main.tex');
    copyfile('main.pdf',OutpFile);
    movefile(OutpFile,thisDir);
catch Err
    utils.warning('latex:publish', ...
        ['Error producing PDF.\n', ...
        '\tUncle says: %s'], ...
        Err.message);
end

cd(thisDir);
if opt.cleanup
    rmdir(wDir,'s');
end

if opt.closeall
    close('all');
end

end


% Subfunctions...


%**************************************************************************


function C = xxDocSubs(C,Opt)
br = sprintf('\n');
C = strrep(C,'$papersize$',Opt.papersize);

% Author.
Opt.author = strtrim(Opt.author);
if ischar(Opt.author) && ~isempty(Opt.author)
    C = strrep(C,'$author$',['\byauthor ',Opt.author]);
elseif ischar(Opt.event) && ~isempty(Opt.event)
    C = strrep(C,'$author$',['\atevent ',Opt.event]);
else
    C = strrep(C,'$author$','');
end

C = strrep(C,'$date$',Opt.date);
C = strrep(C,'$textscale$',sprintf('%g',Opt.textscale));

% Figures.
C = strrep(C,'$figurescale$',sprintf('%g',Opt.figurescale));
C = strrep(C,'$figuretrim$',sprintf('%gpt ',Opt.figuretrim));
if Opt.figureframe
    C = strrep(C,'$figureframe$','\fbox');
else
    C = strrep(C,'$figureframe$','');
end

% Matlab and IRIS versions.
if Opt.matlabversion
    v = version();
    v = strrep(v,' ','');
    v = regexprep(v,'(.*)\s*\((.*?)\)','$2');
    C = strrep(C,'$matlabversion$', ...
        ['Matlab: ',v]);
else
    C = strrep(C,'$matlabversion$','');
end
if Opt.irisversion
    C = strrep(C,'$irisversion$', ...
        ['IRIS: ',irisversion()]);
else
    C = strrep(C,'$irisversion$','');
end

% Packages.
if ~isempty(Opt.package)
    c1 = '';
    if ischar(Opt.package)
        Opt.package = {Opt.package};
    end
    npkg = length(Opt.package);
    for i = 1 : npkg
        pkg = Opt.package{i};
        if isempty(strfind(pkg,'{'))
            c1 = [c1,'\usepackage{',pkg,'}']; %#ok<AGROW>
        else
            c1 = [c1,'\usepackage',pkg]; %#ok<AGROW>
        end
        c1 = [c1,br]; %#ok<AGROW>
    end
    C = strrep(C,'$packages$',c1);
else
    C = strrep(C,'$packages$','');
end

C = strrep(C,'$preamble$',Opt.preamble);
if Opt.numbered
    C = strrep(C,'$numbered$','');
else
    C = strrep(C,'$numbered$','*');
end
linespread = sprintf('%g',Opt.linespread);
C = strrep(C,'$linespread$',linespread);
end % xxDocSubs()


%**************************************************************************


function Copy = xxPrepareToPublish(File)
% xxpreparetopublish  Remove formats not recognised by built-in publish.
c = file2char(File);
Copy = c;
% Replace %... and %%% with %%% ...
c = regexprep(c,'^%[ \t]*\.\.\.\s*$','%% ...','lineanchors');
c = regexprep(c,'^%%%[ \t]*(?=\n)$','%% ...','lineanchors');
% Remove underlines % ==== with 4+ equal signs.
c = regexprep(c,'^% ?====+','%','lineanchors');
% Remove underlines % ---- with 4+ equal signs.
c = regexprep(c,'^% ?----+','%','lineanchors');
% Replace ` with |.
c = strrep(c,'`','|');
char2file(c,File);
end % xxPrepareToPublish()
