function X = ppmm(X)
% ppmm  [Not a public function] Replace ++ and -- with +.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

while true
    n0 = length(X);
    X = regexprep(X,'\+\+','+');
    X = regexprep(X,'\-\-','+');
    if length(X) == n0
        break
    end
end

end

