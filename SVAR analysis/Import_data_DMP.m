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

%% Baseline VAR specification
torstart         = 1979;
tstart           = 1980; 
tend             = 2007; %set tend to 2011 for extended sample
tend_month = 12;
%%
% outcome variables
baseline_series = {'UR','MA_EMP_S','MA_RAT_EMP','MA_RWAGE_S','MA_WPREMIUM','INF_Y'};
DETRVAR        = DATASET.TSERIES((tstart-torstart)*12+1:((tend-tstart)*12+tend_month)+(tstart-torstart)*12+1,cell2mat(values(DATASET.MAP,[baseline_series])));


%% Detrending Data of RCONTROLS
%detrend 0 = 1 no, 1 = yes with time polynomial, detorder = order of the polynominal
detrend =  [ 0, 1, 1, 1, 1, 1];
%detorder = [ 1, 1, 1, 1, 1, 1, 1, 1];
detorder = [ 2, 2, 2, 2, 2, 2];
%detorder = [ 3, 3, 3, 3, 3, 3, 3, 3];
%detorder = [ 4, 4, 4, 4, 4, 4, 4, 4];

Z = DETRVAR;
Z_tilde = Z;

for i=1:length(detrend)
    if detrend(i)>0;
        [Nobs, nvars] = size(DETRVAR); trend0 = [1:1:Nobs]'; A0 = [ ones(Nobs,1) trend0 ]; A1 = A0; trend1=trend0;
        if detorder(i)>1;
            for j=2:detorder(i);
                trend1 = trend1.*trend0; A1 = [ A1 trend1 ];
            end;
        end;
        Ahat = A1\Z(:,i);
        Z_tilde(:,i) = Z(:,i) - A1*Ahat;
    end;
end;
display('correlation UR and employment ratio')
corrcoef(Z_tilde(:,1),Z_tilde(:,3))
display('correlation UR and WPREM')
corrcoef(Z_tilde(:,1),Z_tilde(:,5))



