function f = IRF_proxy_plotsec(VAR,VAR1,VAR1bs,VAR1bs_68,DATASET,select_IV);

% Min & max axes values
min1=min([min(VAR1bs.irsL,[],1);min(VAR1bs.irsH,[],1)],[],1);
max1=max([max(VAR1bs.irsL,[],1);max(VAR1bs.irsH,[],1)],[],1);
std1=mean([std(VAR1bs.irsL,0,1);std(VAR1bs.irsH,0,1)],1);
min1=min1-0.5*std1;
max1=max1+0.5*std1;
FIG.axes=[min1;max1];
%display= cell2mat(values(VAR.MAP,VAR.select_vars));

display =[1:4];
%f=figure;
f=figure('units','normalized','outerposition',[0 0 1 1]);
display2 = cell2mat(values(VAR.MAP,VAR.select_vars));
for nvar = 3:6 % 3:length for sectors
        if length(display)<6
        subplot(1,4,nvar-2), % 1,6 for sectors
        end
        box on
            
            
            if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{1}})))==1
            if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar-2}})))~=1
            VAR1.irs(:,display(nvar-2))=VAR1.irs(:,display(nvar-2))/100;
            VAR1bs_68.irsH(:,display(nvar-2))=VAR1bs_68.irsH(:,display(nvar-2))/100;
            VAR1bs_68.irsL(:,display(nvar-2))=VAR1bs_68.irsL(:,display(nvar-2))/100;
            VAR1bs.irsH(:,display(nvar-2))=VAR1bs.irsH(:,display(nvar-2))/100;
            VAR1bs.irsL(:,display(nvar-2))=VAR1bs.irsL(:,display(nvar-2))/100;

            end
            end
       
            xpoints = 1:1:VAR1.irhor;
            p1=plot(VAR1.irs(:,display2(nvar)),'LineWidth',2,'Color', 'k'); hold on;
            plot([zeros(VAR1.irhor,1)],'LineWidth',1,'Color',[0.5 0.5 0.5]); hold on;
            jbfill(xpoints,VAR1bs_68.irsH(:,display2(nvar))',VAR1bs_68.irsL(:,display2(nvar))',[0.5 0.5 0.5]); hold on; 
            jbfill(xpoints,VAR1bs.irsH(:,display2(nvar))',VAR1bs.irsL(:,display2(nvar))',[0.8  0.8  0.8]); 
            
            ti=title( DATASET.FIGLABELS{cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}}))},'FontSize',24);
            axis tight;
            set(gca, 'FontSize', 16);
            xl=xlabel('months');
            if nvar == 1;  
            l1 = {DATASET.FIGLABELS{cell2mat(values(DATASET.MAP,{select_IV{1}}))}};
            l=legend([p1],l1);
            set([l], 'FontName', 'AvantGarde','FontSize',16,'Location','NorthWest');
            end
            
            if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}})))==1
            yl=ylabel('percent');
            elseif DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}})))==2
            yl=ylabel('percentage points'); 
            elseif DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}})))==0
            yl=ylabel('levels'); 
            end
               
            set([xl,yl], 'FontName', 'AvantGarde','FontSize',20);
          
end



