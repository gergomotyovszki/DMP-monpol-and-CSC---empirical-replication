function plot_2ebands(x,y,y_se,axis_font_size,title_font_size,slabel,str_color)

plot(x,y,str_color,'LineWidth',3);
hold on;
  plot(x,y-y_se,'-- w','LineWidth',0.001);
  plot(x,y+y_se,'-- w','LineWidth',0.001);
  plot(x,y-2*y_se,': w','LineWidth',0.001);
  plot(x,y+2*y_se,': w','LineWidth',0.001);
hold off;
ax = gca;  % This gets axis limits for current plot (must be open)
x_lim = ax.XLim;
y_lim = ax.YLim;
xlim([0 size(x,1)-1]);
ax.FontSize = axis_font_size;
xu = y-y_se;
xl = y+y_se;
hold on;
for t = 1:size(x,1)-1;
  patch([x(t) x(t) x(t+1) x(t+1)],[xl(t) xu(t) xu(t+1) xl(t+1)],str_color,'EdgeColor','none');
  alpha(0.3);
end;
xu = y-2*y_se;
xl = y+2*y_se;
hold on;
for t = 1:size(x,1)-1;
  patch([x(t) x(t) x(t+1) x(t+1)],[xl(t) xu(t) xu(t+1) xl(t+1)],str_color,'EdgeColor','none');
  alpha(0.1);
end;
plot(x,y,str_color,'LineWidth',3);;
title(slabel,'fontsize',title_font_size);
hold off;

end

