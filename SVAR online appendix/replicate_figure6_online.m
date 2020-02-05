%-------------------------------------------------
% Main file for estimating Proxy VAR for monetary policy and wage inequality project
%-------------------------------------------------
% codes based on Proxy SVAR by Mertens and Ravn, modified by E. Pappa
%
rng(15);
clc; clear all; close all; addpath('auxfiles'); addpath('VAR_Toolbox'); addpath('proxySVARDMP');
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
%% replicate Figure 5 in online appendix
%% SMOOTHING using 5 month backward moving average
baseline_var     = {'UR','EMP_S','RAT_EMP','RWAGE_S','WPREMIUM','INF_Y'}; %{'IP','UR','CPI'}; % Baseline variables - original regression
%------------------------------------------------------
%% Select what to plot
plot_irf         = 1;        % plot IRFs 0=no plot, 1=single, 2=plot overlay
% Standard error method
method           = 1;        % 1 = Bootstrap;

% Baseline specification
IRF_proxy(DATASET,tstart,tend,IV,nlags,shock,baseline_var,plot_irf,method)

[~,~,~]=mkdir('charts');               % printing numerical results
filename = ['charts\baselineVAR'];
saveas(gcf,filename,'png');