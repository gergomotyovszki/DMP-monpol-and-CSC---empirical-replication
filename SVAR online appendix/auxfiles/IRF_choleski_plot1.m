function f = IRF_choleski_plot1(DATASET,tstart,tend,nlags,shock_first,shock,controls,CI_both);


%--------------------------------------------------------------------------
% ESTIMATION

% Order variables
if shock_first == 1;
    VAR3.select_vars                                  = shock;
    VAR3.select_vars(:,end+1:end+length(controls))    = controls;
elseif shock_first == 0;
    VAR3.select_vars                                  = controls;
    VAR3.select_vars(:,end+1:end+1)                   = shock;
end
VAR3a.vars          = DATASET.TSERIES(:,cell2mat(values(DATASET.MAP,VAR3.select_vars)));
nvars               = size(VAR3a.vars,2);


%Delete rows with missing values
toremove = any(isnan(VAR3a.vars), 2);
VAR3a.vars = VAR3a.vars(~toremove,:);


Nobs = length(VAR3a.vars);

VAR3.vars = VAR3a.vars;

% Lag length selection
maxlag=12;
ENDO=VAR3.vars;
[totnobs nvars]=size(ENDO);

% VAR estimation
% c_case  = 0 no const; 1 const ; 2 const&trend; 3 const&trend^2; (default = 1)
c_case=2; % with constant
VARout = VARmodel(VAR3.vars,nlags,c_case);

% IRFs: Choleski Identification
nhor   = 48;    % Horizon
nboot  = 100;  % Number of Bootstrap Samples (equals 10000 in the paper)
clevel = 68;    % Bootstrap Percentile Shown
[IRF, IRF_opt]         = VARir(VARout,nhor,'oir',1);
[INF,SUP,MED]          = VARirband(VARout,IRF_opt,nboot,clevel);
[INF_95,SUP_95,MED_95] = VARirband(VARout,IRF_opt,nboot,95);

res_str = (IRF_opt.invA(1,:)*VARout.residuals')';

%% Plot VAR (confidence first)

close all;

%figure(1)
f=figure('units','normalized','outerposition',[0 0 1 1]);
    xpoints = 1:1:nhor;
    
    if shock_first == 1;
        
    % Rescale
    jj = nvars;
    if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR3.select_vars{1}})))==1
    if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR3.select_vars{jj}})))~=1
            MED(:,jj,1)=MED(:,jj,1)/100;
            INF(:,jj,1)=INF(:,jj,1)/100;
            SUP(:,jj,1)=SUP(:,jj,1)/100;
            if CI_both == 1;
                INF_95(:,jj,1)=INF_95(:,jj,1)/100;
                SUP_95(:,jj,1)=SUP_95(:,jj,1)/100;
            end
    end
    end
    
    plot([-MED(:,jj,1)],'LineWidth',1,'Color','k'); hold on; 
    plot([zeros(nhor,1)],'LineWidth',1,'Color',[0.5 0.5 0.5]); hold on;
    jbfill(xpoints,-INF(:,jj,1)',-SUP(:,jj,1)',[0.5 0.5 0.5]); 
    
    if CI_both == 1;
        hold on;jbfill(xpoints,-INF_95(:,jj,1)',-SUP_95(:,jj,1)',[0.8  0.8  0.8]); 
    end
       
    elseif shock_first == 0;
        
    % Rescale
    jj = 1;
    if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR3.select_vars{nvars}})))==1
    if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR3.select_vars{jj}})))~=1
            MED(:,jj,1)=MED(:,jj,1)/100;
            INF(:,jj,1)=INF(:,jj,1)/100;
            SUP(:,jj,1)=SUP(:,jj,1)/100;
            if CI_both == 1;
                INF_95(:,jj,1)=INF_95(:,jj,1)/100;
                SUP_95(:,jj,1)=SUP_95(:,jj,1)/100;
            end
    end
    end    

    plot([-MED(:,jj,nvars)],'LineWidth',1,'Color',[0 0 0.5]); hold on; 
    plot([zeros(nhor,1)],'LineWidth',1,'Color',[0.5 0.5 0.5]); hold on;
    jbfill(xpoints,-INF(:,jj,nvars)',-SUP(:,jj,nvars)',[0.5 0.5 0.5]); 
    if CI_both == 1;
        hold on;jbfill(xpoints,-INF_95(:,jj,nvars)',-SUP_95(:,jj,nvars)',[0.8  0.8  0.8]); 
    end
    
    end
    
        % Axis labels
        axis tight;
        set(gca, 'FontSize', 14);
        xl=xlabel('months');
        if DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR3.select_vars{jj}})))==1
            yl=ylabel('percent');
            elseif DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR3.select_vars{jj}})))==2
            yl=ylabel('percentage points'); 
            elseif DATASET.UNIT(cell2mat(values(DATASET.MAP,{VAR3.select_vars{jj}})))==0
            yl=ylabel('levels'); 
        end
        set([xl,yl], 'FontName', 'AvantGarde','FontSize',16);
    
    
    title(DATASET.FIGLABELS{cell2mat(values(DATASET.MAP,{VAR3.select_vars{jj}}))},'FontSize',16);
    
    

    
end

