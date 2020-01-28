function Opt = datdefaults(Opt,IsPlot)
% datdefaults  [Not a public function] Set up defaults for date-related opt if they are `@config`.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

try
    IsPlot; %#ok<VUNUS>
catch
    IsPlot = false;
end

%--------------------------------------------------------------------------

cfg = irisconfigmaster('get');

if ~isfield(Opt,'dateformat') || isequal(Opt.dateformat,@config)
    if ~IsPlot
        Opt.dateformat = cfg.dateformat;
    else
        Opt.dateformat = cfg.plotdateformat;
    end
end

if ~isfield(Opt,'freqletters') || isequal(Opt.freqletters,@config)
    Opt.freqletters = cfg.freqletters;
end

if ~isfield(Opt,'months') || isequal(Opt.months,@config)
    Opt.months = cfg.months;
end

if ~isfield(Opt,'standinmonth') || isequal(Opt.standinmonth,@config)
    Opt.standinmonth = cfg.standinmonth;
end

if ~isfield(Opt,'wwday') || isequal(Opt.wwday,@config)
    Opt.wwday = cfg.wwday;
end

end
