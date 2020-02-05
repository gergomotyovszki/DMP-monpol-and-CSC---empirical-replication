function f = IRF_proxy_plot_both(VAR,VAR1,VAR1bs,VAR1bs_68,VARci_delta68,VARci_delta95,DATASET,select_IV);

% Min & max axes values
%{
min1=min([min(VAR1bs.irsL,[],1);min(VAR1bs.irsH,[],1)],[],1);
max1=max([max(VAR1bs.irsL,[],1);max(VAR1bs.irsH,[],1)],[],1);
std1=mean([std(VAR1bs.irsL,0,1);std(VAR1bs.irsH,0,1)],1);
%}
min1=min([min(VARci_delta95.irsL,[],1);min(VARci_delta95.irsH,[],1)],[],1);
max1=max([max(VARci_delta95.irsL,[],1);max(VARci_delta95.irsH,[],1)],[],1);
std1=mean([std(VARci_delta95.irsL,0,1);std(VARci_delta95.irsH,0,1)],1);
min1=min1-0.5*std1;
max1=max1+0.5*std1;
FIG.axes=[min1;max1];
    
display= cell2mat(values(VAR.MAP,VAR.select_vars));
%f=figure;
f=figure('units','normalized','outerposition',[0 0 1 1]);
for nvar = 1:length(display)
        if length(display)<7          
        subplot(2,3,nvar),
        elseif length(display)>6
        subplot(2,4,nvar),
        end
        box on

            if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{1}})))==1
            if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR.select_vars{nvar}})))~=1
            VAR1.irs(:,display(nvar))=VAR1.irs(:,display(nvar))/100;
            VAR1bs_68.irsH(:,display(nvar))=VAR1bs_68.irsH(:,display(nvar))/100;
            VAR1bs_68.irsL(:,display(nvar))=VAR1bs_68.irsL(:,display(nvar))/100;
            VAR1bs.irsH(:,display(nvar))=VAR1bs.irsH(:,display(nvar))/100;
            VAR1bs.irsL(:,display(nvar))=VAR1bs.irsL(:,display(nvar))/100;
            VARci_delta68.irsH(:,display(nvar))=VARci_delta68.irsH(:,display(nvar))/100;
            VARci_delta68.irsL(:,display(nvar))=VARci_delta68.irsL(:,display(nvar))/100;
            VARci_delta95.irsH(:,display(nvar))=VARci_delta95.irsH(:,display(nvar))/100;
            VARci_delta95.irsL(:,display(nvar))=VARci_delta95.irsL(:,display(nvar))/100;
            end
            end
        
            xpoints = 1:1:VAR1.irhor;
            p1=plot(VAR1.irs(:,display(nvar)),'LineWidth',2,'Color', 'k'); hold on;
            plot([zeros(VAR1.irhor,1)],'LineWidth',1,'Color',[0.5 0.5 0.5]); hold on;
            
            % Plot Bootstrap SE
            jbfill(xpoints,VAR1bs_68.irsH(:,display(nvar))',VAR1bs_68.irsL(:,display(nvar))',[0.5 0.5 0.5]); hold on; 
            jbfill(xpoints,VAR1bs.irsH(:,display(nvar))',VAR1bs.irsL(:,display(nvar))',[0.8  0.8  0.8]); hold on;
            
            % Plot Delta SE
            plot(VARci_delta68.irsH(:,display(nvar)),'LineWidth',2,'Color', 'm'); hold on;
            plot(VARci_delta68.irsL(:,display(nvar)),'LineWidth',2,'Color', 'm'); hold on;
            plot(VARci_delta95.irsH(:,display(nvar)),'LineWidth',2,'Color', 'm'); hold on;
            plot(VARci_delta95.irsL(:,display(nvar)),'LineWidth',2,'Color', 'm'); 
    
            
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


