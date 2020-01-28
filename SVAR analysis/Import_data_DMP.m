clc; clear all; close all;

% Import dataset in excel
[DATASET.NUM,DATASET.TEXT]=xlsread('DATASET_DMP_IRIS.xlsx','DATASET');
%% Define labels and values and units
DATASET.LABEL = DATASET.TEXT(1,:);
DATASET.FIGLABELS = DATASET.TEXT(2,:);
DATASET.VALUE = DATASET.NUM(1,:);
DATASET.UNIT = DATASET.NUM(2,:);
DATASET.LOGS = DATASET.NUM(3,:);
DATASET.TSERIES = DATASET.NUM(4:end,:);
DATASET.MAP = containers.Map(DATASET.LABEL,DATASET.VALUE);
% Units: 1=percent, 2=percentage points, 0=levels
% Logs: 1=log, 0=level
[N_OBS,N_VAR] = size(DATASET.TSERIES);
% Transform data in logs
ndx     = find(DATASET.LOGS==1);
DATASET.TSERIES(:,ndx)  = log(DATASET.TSERIES(:,ndx));
%%
save('DATASET','DATASET');

disp('Finished saving dataset')

