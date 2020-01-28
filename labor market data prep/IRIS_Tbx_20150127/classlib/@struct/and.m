function S = and(S1,S2)
% and  Concatenate database entries in 2nd dimension.
%
% Syntax
% =======
%
%     S = S1 & S2
%
% Input arguments
% ================
%
% * `S1`, `S2` [ struct ] - Input databases whose entries will be
% concatenated in 2nd dimension.
%
% Output arguments
% =================
%
% * `S` [ struct ] - Output database created by horizontally concatenating
% entries that are present in both `S1` and `S2`.
%
% Description
% ============
%
% Example
% ========
%
%     s1 = struct();
%     s1.a = 1;
%     s1.b = tseries(1:10,1);
%     s1.c = 'a';
%     s1.x = 100;
%
%     s2 = struct();
%     s2.a = 2;
%     s2.b = tseries(5:20,2);
%     s2.c = 'b';
%     s1.y = 200;
%
%     s = s1 & s2
%     ans = 
%         a: [1 2]
%         b: [20x2 tseries]
%         c: 'ab'

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

if isempty(S1)
    S = S2;
    return
elseif isempty(S2)
    S = S1;
    return
end

%--------------------------------------------------------------------------

S = dbfun( @(X1,X2) cat(2,X1,X2), S1, S2 );

end
