% Sasonal adjustment with IRIS

%% Housekeeping
    
    close all
    clear all
    clc
    
    % Loading IRIS Toolbox -- only needed if has not been loaded yet in the current Matlab session
        currentfolder = fileparts(which('SA_labor_iris.m'));
        irisfolder = [currentfolder '\IRIS_Tbx_20150127'];
        addpath(genpath(irisfolder));

        irisstartup
    
        irisrequired('20150127');
    

%% Reading the data

    % Reading the seasonally non-adjusted data after the Stata and R manipulations

    NA_inputdata  = 'clean data\morg1979_2016_final.xlsx';
    xls2csv(NA_inputdata)
    NA_input_csv  = 'clean data\morg1979_2016_final.csv';
    
    NA = dbload(NA_input_csv);     
    
    starhist = get(NA.employment_rate_1,'start');
    
    % Loading wage series from after the Kalman-filter adjustment
    edc = {'ed', 'noed'};
    for edu = 1:2
        for indu = 1:6
            if edu == 1 && indu == 4
                
            else 
                NA_inputdata_kalman = ['clean data\hrlwage_' edc{edu} '_industry_' num2str(indu) '_kalman.xlsx'];
                xls2csv(NA_inputdata_kalman)
                
                NA_inputdata_kalman_csv = ['clean data\hrlwage_' edc{edu} '_industry_' num2str(indu) '_kalman.csv'];
                kal = [edc{edu} '_' num2str(indu)];
                NA_kalman.(kal) = dbload(NA_inputdata_kalman_csv);
                
                hrly = ['hrlwage_' edc{edu} '_industry_' num2str(indu)];
                NA_kalman.(kal).x = redate(NA_kalman.(kal).x, 1, starhist);
                NA.([hrly '_old']) = NA.(hrly);
                NA.(hrly) = NA_kalman.(kal).x;
            end
        end
    end
        
    
    
%% Seasonal adjustment by IRIS

    SA_varlist = { 'employment_ratio', 'employment_ratio_industry_1', 'employment_ratio_industry_2', 'employment_ratio_industry_3',...
                    'employment_ratio_industry_4', 'employment_ratio_industry_5', 'employment_ratio_industry_6'};

    for i = 1:length(SA_varlist)
       SAlist = [SA_varlist{i} '_adj'] ;
       SA.(SAlist) =  x12(NA.(SA_varlist{i}), Inf);
    end
    
    for edu = 1:length(edc)
       for indu = 1:6
           SAlist = ['hrlwage_' edc{edu} '_industry_' num2str(indu) ] ;
           SA.(SAlist) =  x12(NA.(SAlist), Inf);
       end
    end        
    
    for edu = 1:length(edc)
       for indu = 1:6
           SAlist = ['employment_rate_' num2str(indu) '_' edc{edu} ] ;
           SA.(SAlist) =  x12(NA.(SAlist), Inf);
       end
    end
    
    SA.employment_rate_ed_any_ind    = x12(NA.employment_rate_ed_any_ind, Inf);
    SA.employment_rate_noed_any_ind  = x12(NA.employment_rate_noed_any_ind, Inf);
    SA.hrlwage_ed_any_industry       = x12(NA.hrlwage_ed_any_industry, Inf);
    SA.hrlwage_noed_any_industry     = x12(NA.hrlwage_noed_any_industry, Inf);


    
%% Save SA data

    dbsave(SA,'clean data\SA_data_iris.csv','class=', false, 'comment=', false, 'format=','%0.8f');
    dbsave(NA,'clean data\NA_data.csv','class=', false, 'comment=', false, 'format=','%0.8f');

    % Remove IRIS from the Matlab path
    rmpath(genpath(irisfolder));
    irisfinish;
    