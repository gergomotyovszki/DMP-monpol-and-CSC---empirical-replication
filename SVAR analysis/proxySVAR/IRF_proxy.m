
function f = IRF_proxy(DATASET,tstart,tend,IV,nlags,shock,baseline_var,plot_irf,method)

VARoptions.plot_irf         = plot_irf;        % plot IRFs 0=no plot, 1=single, 2=plot overlay
VARoptions.method           = method;          % 1 = Bootstrap; 

%% Data 
tbeg            =1979; %where the data starts originally not necessarily coincides with sample beginning
DATASET.TSERIES=DATASET.TSERIES((tstart-tbeg)*12+1:(tend-tbeg)*12+12,:);

Nobs = size(DATASET.TSERIES,2);
% Selected variables
VAR.select_vars                                     = shock;
VAR.select_vars(:,end+1:end+length(baseline_var))   = baseline_var;
VAR.vars             = DATASET.TSERIES(:,cell2mat(values(DATASET.MAP,VAR.select_vars)));
VAR.MAP              = containers.Map([VAR.select_vars],[1:size(VAR.vars,2)]);
% Delete rows with missing values
toremove = any(isnan(VAR.vars), 2);
VAR.vars = VAR.vars(~toremove,:);
% 
[Nobs, nvars] = size(VAR.vars);
Z = VAR.vars;
for jj = 1:1:nvars;
Z_tilde(:,cell2mat(values(VAR.MAP,{VAR.select_vars{jj}})))=Z(:,cell2mat(values(VAR.MAP,{VAR.select_vars{jj}})));
end
VAR.vars = VAR.vars;
%
% Lag length selection
maxlag=20;
c_case=1;
[totnobs, nvars]=size(VAR.vars);
[AIC, HQ, BIC]=selectIC(VAR.vars,maxlag,nvars,totnobs);
[mval_BIC, nLag_BIC]=min(BIC);
[mval_AIC, nLag_AIC]=min(AIC);
[mval_HQ, nLag_HQ]=min(HQ);
disp('selected lag length based on AIC')
disp(nLag_AIC)
disp('selected lag length based on HQ')
disp(nLag_HQ)
disp('selected lag length based on BIC')
disp(nLag_BIC) 


%% Proxy VAR Estimation

nboot      = 1000;  % Number of Bootstrap Samples (equals 10000 in the paper)
clevel     = 95;    % Bootstrap Percentile Shown
VAR.irhor  = 48;
VAR.p      = nlags;  
VAR.DET    = ones(length(VAR.vars),1); % Deterministic Terms
 
% VAR specification 
%%%%%%%%%%%%%%%%%%%%

 VAR.proxies = DATASET.TSERIES(:,cell2mat(values(DATASET.MAP,{IV{1}})));
 VAR.proxies = VAR.proxies(~toremove,:);
 
 % Point estimate
 VAR1                  = doProxySVAR(VAR,DATASET);
 

 % F-statistic
 disp('F statistic:');
 disp(VAR1.Fval);

 
 % Plot Impulse Responses
if VARoptions.plot_irf == 1
         
    % Bootstrapped standard errors
    if VARoptions.method == 1;
        VAR1_95                = doProxySVARbootstrap_single(VAR1,nboot,clevel,DATASET);
        VAR1_68             = doProxySVARbootstrap_single(VAR1,nboot,68,DATASET);
        IRF_proxy_plot(VAR,VAR1,VAR1_95,VAR1_68,DATASET,IV)
    
    % Delta method for standard errors
    elseif VARoptions.method == 2;
        VAR1_68    = doProxySVARci(VAR1,68,3);
        VAR1_95    = doProxySVARci(VAR1,95,3);
        IRF_proxy_plot_delta(VAR,VAR1,VAR1_68,VAR1_95,DATASET,IV);

    % BOTH standard error methods
    elseif VARoptions.method == 3;
        VAR1bs              = doProxySVARbootstrap_single(VAR1,nboot,clevel,DATASET);
        VAR1bs_68           = doProxySVARbootstrap_single(VAR1,nboot,68,DATASET);
        VARci_delta68       = doProxySVARci(VAR1,68,3);
        VARci_delta95       = doProxySVARci(VAR1,95,3);
        IRF_proxy_plot_both(VAR,VAR1,VAR1bs,VAR1bs_68,VARci_delta68,VARci_delta95,DATASET,IV);
    end
 
 end


 disp('Finished running')
 

