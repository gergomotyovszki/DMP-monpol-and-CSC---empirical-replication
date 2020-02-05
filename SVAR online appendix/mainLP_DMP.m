% Local projection results presented in Figure 4 in the Online appendix
% to run this file you need to have subfolder 'functions installed'
%
clear all;
close all;
addpath([pwd '/functions/']) 

%% Load data and shocks

% Data
[vdata,names,raw] =  xlsread('DATA_DMP_Q.xlsx','data');

NumberVars = max(size(names));
for i=1:NumberVars
    field = char(names(i)); 
    DataStruct.(field) = vdata(:,i); 
end

% Load shocks
[vdata,names,raw] = xlsread('DATA_DMP_Q.xlsx','shocks');  
names = names(1,:);
NumberVars = max(size(names));
shocks = [];
for ii=2:NumberVars
    field = char(names(ii)); 
    DataStruct.(field) = vdata(:,ii); 
    shocks = [shocks,DataStruct.(field)];
end


%% Key parameters
MA=0; % 1: data is MA-transformed, 0: not MA-transformed
Trend=1;  % 1: linear trend
Seasonal=0; % 1: include seasonal dummies
start_date=1980;%1979.25;
end_date=2008.75;
H_min = 0; % start LP at H_min=0 or 1 (H_min=1 if impose no contemporanous impact)
H_max = 20; 
delta=1;
r=2;

% shock of interest
shock_name= 'TRSHOCK'; %'TR_shock'; %  'RRSHOCKMA'; %   % or MP1_TC 

% variables of interest
    LHS={'UR' 'INF' 'WPREMIUM' 'EMP_S' 'RAT_EMP'  'LRWAGE_S' }; 

%% Data preparation
close all

for j=1:size(LHS,2) 

if Seasonal==1
    % Seasonal dummys
        dumq1= DataStruct.('dumq1');
        dumq2= DataStruct.('dumq2');
        dumq3= DataStruct.('dumq3');
        dumq4= DataStruct.('dumq4');
        dummys = [ dumq2 dumq3 dumq4 ]; 
else
    dummys=[];
end

if Trend==1
    ltrend = DataStruct.('ltrend');
else
    ltrend=[];
end

% deterministic part (constant is always automatically included)
determ=[dummys ltrend];

% Time vector
time = DataStruct.('time'); % declaring the time variable from the structure created from the original dataset
fin = find(time==end_date); % define the index for the last observation in the data
start=find(time==start_date); 

% Dependent variable

data = [DataStruct.(LHS{j})];
%data = log(data)*100;

shocks= DataStruct.(shock_name);

% Resize
if MA == 0
    start = start;
else
    start = start + 4;
end
data = data(start:fin,:);
shocks = shocks(start:fin,:);
if isempty(determ)
else
determ = determ(start:fin,:);
end
% Optimal lag length for data and shocks
[aic_data, bic_data, hqc_data] = aicbic(data,12);
P=4;% Coibion et al.P=2, we use P=4 to get meaningful UR responses
[aic_shock, bic_shock, hqc_shock] = aicbic(shocks,12);
R=20;% as in Coibon et al.


w=[determ lagmatrix(shocks,1:R) lagmatrix(data,1:P)];
y=data;

lp    = locproj(y(1+max(P,R):end),shocks(1+max(P,R):end,:),w(1+max(P,R):end,:),H_min,H_max,'reg'); % IR from (standard) Local Projection
lp    = locproj_conf(lp,H_max);


figure(j)
hold on
% plot( 0:H_max , cumsum(lp.IR(:,1))   , 'r' , 'LineWidth' , 2 )
% plot( 0:H_max , cumsum(lp.conf(:,1:2)) , 'r' )
plot( 0:H_max , lp.IR(:,1)   , 'b' , 'LineWidth' , 2 )
plot( 0:H_max , lp.conf(:,1:2) , 'b' )
plot( 0:H_max , zeros(H_max+1,1) , '-k' , 'LineWidth' , 2 )
grid
xlim([0 H_max])
title(LHS(j))

[~,~,~]=mkdir('charts');               % printing numerical results
filename = ['charts\localproj_wage_' LHS{j}  ];
saveas(gcf,filename,'png');

end
