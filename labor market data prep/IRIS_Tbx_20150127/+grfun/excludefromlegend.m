function excludefromlegend(h)
% excludefromlegend  [Not a public function] Exclude graphic object from legend.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

for i = h(:)'
    try %#ok<TRYNC>
        if true % ##### MOSW
            set(get(get(i,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','off');
        else
            setappdata(i,'ExcludeFromLegend',true); %#ok<UNRCH>
        end
    end
end

end
