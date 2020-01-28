function Config = irisconfig(varargin)
% irisconfig  [Not a public function] Default values for IRIS config preferences.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

Config = struct();

% Factory defaults.
%------------------

% Start-up arguments.
Config.startup = varargin;

% Date preferences.
Config.freqletters = 'YHQBMW';
Config.dateformat = struct( ...
    'yy','YF', ...
    'hh','YFP', ...
    'qq','YFP', ...
    'bb','YFP', ...
    'mm','YFP', ...
    'ww','YFP', ...
    'dd','$YYYY-Mmm-DD', ...
    'unspecified','P');
Config.baseyear = 2000; % Base year for deterministic time trends.
% Plot date formats for each frequency: Y, H, Q, B, M, W. Indeterminate
% frequency is simply printed as a number.
Config.plotdateformat = struct( ...
    'yy','Y', ...
    'hh','Y:P', ...
    'qq','Y:P', ...
    'bb','Y:P', ...
    'mm','Y:P', ...
    'ww','Y:P', ...
    'dd','$YYYY-Mmm-DD', ...
    'unspecified','P');
Config.months = { ...
    'January','February','March','April','May','June', ...
    'July','August','September','October','November','December'};
Config.standinmonth = 'first';
Config.wwday = 'Thu';

% Tseries preferences.
Config.tseriesformat = '';
Config.tseriesmaxwspace = 5;

% TeX/LaTeX paths to executables.
% Use `kpswhich` to find TeX components.
[Config.pdflatexpath,folder] = findtexmf('pdflatex');
Config.epstopdfpath = xxLocateFile('epstopdf',folder);

% Empty user data.
Config.userdata = [];

% Execute the user's configuration file.
%---------------------------------------
if exist('irisuserconfig.m','file')
    Config = irisuserconfig(Config);
    Config.userconfigpath = which('irisuserconfig.m');
else
    Config.userconfigpath = '';
end

% Validate.
%----------
% Validate the required options in case the user have modified their
% values.
doValidateConfig();

list = fieldnames(Config.validate);
invalid = {};
missing = {};
for i = 1 : numel(list)
    if isfield(Config,list{i})
        if ~Config.validate.(list{i})(Config.(list{i}));
            invalid{end+1} = list{i}; %#ok<AGROW>
        end
    else
        missing{end+1} = list{i}; %#ok<AGROW>
    end
end

% Report the options that have been assigned invalid values.
if ~isempty(invalid)
    x = struct();
    x.message = sprintf(...
        '\n*** IRIS cannot start because the value supplied for this IRIS option is invalid: ''%s''.', ...
        invalid{:});
    x.identifier = 'iris:config';
    x.stack = dbstack();
    x.stack = x.stack(end);
    error(x);
end

% Report the options that are missing (=have been removed by the user).
if ~isempty(missing)
    x = struct();
    x.message = sprintf(...
        '\n*** IRIS cannot start because this IRIS option is missing from configuration struct: ''%s''.', ...
        missing{:});
    x.identifier = 'iris:config';
    x.stack = dbstack();
    x.stack = x.stack(end);
    error(x);
end

% Options that cannot be customised.
% IRIS root folder.
tmp = pwd();
cd(fileparts(which('irisstartup.m')));
Config.irisroot = pwd();
cd(tmp);

% Read IRIS version. The IRIS version is stored in the root Contents.m
% file, and is displayed by the Matlab ver() command.
x = ver();
ix = strcmp('IRIS Toolbox',{x.Name});
if any(ix)
    Config.version = x(ix).Version;
else
    utils.warning('config:irisconfig', ...
        'Cannot determine the current version of IRIS.');
    Config.version = '???';
end

% User cannot change these properties.
Config.protected = { ...
    'startup', ...
    'userconfigpath', ...
    'irisroot', ...
    'version', ...
    'validate', ...
    'protected', ...
    };


% Nested functions...


%**************************************************************************

    
    function doValidateConfig()
        
        isdateformatstruct = @(X) isstruct(X) ...
            && length(X) == 1 ...
            && all(isfield(X,{'yy','hh','qq','bb','mm','ww','dd','unspecified'}));
        
        Config.validate = struct( ...
            'startup',@iscellstr, ...
            'freqletters', ...
            @(x) (ischar(x) && numel(x) == numel(unique(x)) && numel(x) == 6) ...
            || isequal(x,@config), ...
            'dateformat', ...
            @(x) isequal(x,@config) || ischar(x) || iscellstr(x) ...
            || isdateformatstruct(x), ...
            'plotdateformat', ...
            @(x) isequal(x,@config) || ischar(x) || iscellstr(x) ...
            || isdateformatstruct(x), ...
            'baseyear',@(x) isnumeric(x) && length(x) == 1 && x == round(x), ...
            'months',@(x) (iscellstr(x) && numel(x) == 12) ...
            || isequal(x,@config), ...
            'standinmonth',@(x) (isnumeric(x) && numel(x) == 1 && x > 0) || isequal(x,'first') || isequal(x,'last') ...
            || isequal(x,@config), ...
            ... 'reportpreamble',@ischar, ...
            ... 'publishpreamble',@ischar, ...
            'wwday', ...
            @(x) any(strcmpi(x,{'Mon','Tue','Wed','Thu','Fri','Sat','Sun'})), ...
            'tseriesformat',@ischar, ...
            'tseriesmaxwspace', ...
            @(x) isnumeric(x) && length(x) == 1 && x == round(x) && x > 0, ...
            'pdflatexpath',@ischar, ...
            'epstopdfpath',@ischar ...
            );
    end % doValidateConfig()


end


% Subfunctions...


%**************************************************************************


function FPath = xxLocateFile(File,Folder)
try
    Folder; %#ok<VUNUS>
catch %#ok<CTCH>
    Folder = '';
end

if ~isempty(Folder)
    if ispc()
        list = dir(fullfile(Folder,[File,'.exe']));
    else
        list = dir(fullfile(Folder,File));
    end
else
    list = [];
end

if length(list) == 1
    FPath = fullfile(Folder,list.name);
else
    FPath = findtexmf(File);
end
end % xxLocateFile()
