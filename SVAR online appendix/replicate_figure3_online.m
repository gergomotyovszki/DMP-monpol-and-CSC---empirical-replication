%% replicates figure 3 in Online Appendix

clear all; close all; addpath('auxfiles'); addpath('VAR_Toolbox');
load DATASET;

% Baseline specification
tstart      = 1980;
tend        = 2016;
nlags       = 5;
shock_first = 0;            % Interest rate first = 1, last = 0
shock       = {'FFR'}; 
controls    = {'UR','MA_EMP_S','MA_RAT_EMP','MA_RWAGE_S','MA_WPREMIUM','INF_Y'};
%controls    = {'UR','INF_Y'};

CI_both     = 1;            % Confidence interval: 0 = 68%, 1 = also 95%

%% Confidence last
IRF_choleski(DATASET,tstart,tend,nlags,0,shock,controls,CI_both);
%%%

[~,~,~]=mkdir('charts');               % printing numerical results
filename = ['charts\MACholesky_whole'];
saveas(gcf,filename,'png');