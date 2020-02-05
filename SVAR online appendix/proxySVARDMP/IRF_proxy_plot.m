function f = IRF_proxy_plot(VAR,VAR1,VAR1bs,VAR1bs_68,DATASET,select_IV);

% Min & max axes values
min1=min([min(VAR1bs.irsL,[],1);min(VAR1bs.irsH,[],1)],[],1);
max1=max([max(VAR1bs.irsL,[],1);max(VAR1bs.irsH,[],1)],[],1);
std1=mean([std(VAR1bs.irsL,0,1);std(VAR1bs.irsH,0,1)],1);
min1=min1-0.5*std1;
max1=max1+0.5*std1;
FIG.axes=[min1;max1];
    
display= cell2mat(values(VAR.MAP,VAR.select_vars));
%f=figure;
f=figure('units','normalized','outerposition',[0 0 1 1]);
for nvar = 1:length(display)% 3:length for sectors
        if length(display)<7          
        subplot(2,3,nvar),
        elseif length(display)>6
        subplot(2,4,nvar), % 1,6 for sectors
        end
        box on
            
            %p1=plot(VAR1.irs(:,display(nvar)),'-','MarkerSize',4,'LineWidth',2,'Color',[0 0 0.5]); hold on;
            %plot(VAR1bs.irsH(:,display(nvar)),'LineWidth',1,'Color', [0 0 0.5],'LineStyle','--'); hold on;
            %plot(VAR1bs.irsL(:,display(nvar)),'LineWidth',1,'Color', [0 0 0.5],'LineStyle','--'); hold on;
            %axis([0.75 VAR1.irhor FIG.axes(1,nvar) FIG.axes(2,nvar)]);
            %hline(0,'k-')
            
            if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{1}})))==1
            if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}})))~=1
            VAR1.irs(:,display(nvar))=VAR1.irs(:,display(nvar))/100;
            VAR1bs_68.irsH(:,display(nvar))=VAR1bs_68.irsH(:,display(nvar))/100;
            VAR1bs_68.irsL(:,display(nvar))=VAR1bs_68.irsL(:,display(nvar))/100;
            VAR1bs.irsH(:,display(nvar))=VAR1bs.irsH(:,display(nvar))/100;
            VAR1bs.irsL(:,display(nvar))=VAR1bs.irsL(:,display(nvar))/100;
            end
            end
        
            xpoints = 1:1:VAR1.irhor;
            p1=plot(VAR1.irs(:,display(nvar)),'LineWidth',2,'Color', 'k'); hold on;
            plot([zeros(VAR1.irhor,1)],'LineWidth',1,'Color',[0.5 0.5 0.5]); hold on;
            jbfill(xpoints,VAR1bs_68.irsH(:,display(nvar))',VAR1bs_68.irsL(:,display(nvar))',[0.5 0.5 0.5]); hold on; 
            jbfill(xpoints,VAR1bs.irsH(:,display(nvar))',VAR1bs.irsL(:,display(nvar))',[0.8  0.8  0.8]); 
            
            ti=title( DATASET.FIGLABELS{cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}}))},'FontSize',18);
            axis tight;
            set(gca, 'FontSize', 16);
            xl=xlabel('months');
            if nvar == 1;  
            l1 = {DATASET.FIGLABELS{cell2mat(values(DATASET.MAP,{select_IV{1}}))}};
            l=legend([p1],l1);
            set([l], 'FontName', 'AvantGarde','FontSize',14,'Location','NorthWest');
            end
            
            if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}})))==1
            yl=ylabel('percent');
            elseif DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}})))==2
            yl=ylabel('percentage points'); 
            elseif DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}})))==0
            yl=ylabel('levels'); 
            end
               
            set([xl,yl], 'FontName', 'AvantGarde','FontSize',18);
          
end





