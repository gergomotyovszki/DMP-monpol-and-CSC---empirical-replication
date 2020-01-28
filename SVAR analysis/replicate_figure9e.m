%-------------------------------------------------
% Main file for estimating Proxy VAR for monetary policy and wage inequality project
%-------------------------------------------------
% codes based on Proxy SVAR by Mertens and Ravn, modified by E. Pappa
%
rng(15);
clc; clear all; close all; addpath('auxfiles'); addpath('VAR_Toolbox'); addpath('proxySVAR');
%
load DATASET;
%% Baseline VAR specification
tstart           = 1980; 
tend             = 2007; %set tend to 2011 for extended sample
nlags            = 5; % 
%%
% Instrumented variable
shock            = {'FFR'};
% Instrument (Proxy)
IV               =  {'RRSHOCK'}; % {'RRSHOCK'}; %RR shock  %TRSHOCK Coibon shock, 'RRSHOCKMA' extended sample Miranda-Agrippino

%Replicate Figure 9e in appendix
%% SECTORIAL RESULTS

% smoothed sector
baseline_var     = {'UR','MA_EMP_S5','MA_RATIO_EMP5','MA_RWAGE_S5','MA_WPREMIUM5','INF_Y'};


%------------------------------------------------------
%% Select what to plot
plot_irf         = 1;        % plot IRFs 0=no plot, 1=single, 2=plot overlay
% Baseline specification
%IRF_proxy(DATASET,tstart,tend,IV,nlags,shock,baseline_var,plot_irf)
IRF_proxysec(DATASET,tstart,tend,IV,nlags,shock,baseline_var,plot_irf)


[~,~,~]=mkdir('charts');               % printing numerical results
filename = ['charts\MAsector5VAR'];
saveas(gcf,filename,'epsc');