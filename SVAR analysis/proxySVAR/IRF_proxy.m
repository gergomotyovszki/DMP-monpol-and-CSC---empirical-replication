
function f = IRF_proxy(DATASET,tstart,tend,IV,nlags,shock,baseline_var,plot_irf)
VARoptions.plot_irf         = plot_irf;        % plot IRFs 0=no plot, 1=single, 2=plot overlay

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
[Nobs, nvars] = size(VAR.vars);
Z_tilde = VAR.vars;
%% Proxy VAR Estimation
nboot      = 1000;  % Number of Bootstrap Samples (equals 10000 in the paper)
clevel     = 95;    % Bootstrap Percentile Shown 1
clevel2   =68;    % Bootstrap Percentile Shown 2
VAR.irhor  = 48;
VAR.p      = nlags;  
VAR.DET    = ones(length(VAR.vars),1); % Deterministic Terms
% VAR specification 
%%%%%%%%%%%%%%%%%%%%
 VAR.proxies = DATASET.TSERIES(:,cell2mat(values(DATASET.MAP,{IV{1}})));
 VAR.proxies = VAR.proxies(~toremove,:);
 % Point estimate
 VAR1                  = doProxySVAR_single_trend(VAR,DATASET);
  
 % F-statistic
 disp('F statistic:');
 disp(VAR1.Fval);

 % Plot Impulse Responses
if VARoptions.plot_irf == 1
         
    % Bootstrapped standard errors
        VAR1_95                = doProxySVARbootstrap_single(VAR1,nboot,clevel,DATASET);
        VAR1_68             = doProxySVARbootstrap_single(VAR1,nboot,clevel2,DATASET);
        IRF_proxy_plot(VAR,VAR1,VAR1_95,VAR1_68,DATASET,IV)
       %  IRF_proxy_plotsec(VAR,VAR1,VAR1_95,VAR1_68,DATASET,IV)

 end

 disp('Finished running')
 

