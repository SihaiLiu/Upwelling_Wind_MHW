%% Load Data
clear;clc
load('data\detrend_annual_cor.mat');
load('data\enso_find.mat');

load('data\upwelling_mhw_detrend.mat');
load('data\variable-1998-2021.mat');
% load('detrend_variable-1998-2021.mat');
% load('old_mhw_detrend.mat'); % Note: detrend_variable-1998-2021.mat also contains detrended MHW values, so remove duplicates
% D:\BaiduNetdiskWorkspace\Article\Marine Biogeochemical Process and Others\Region\EH-ENSO, Upwelling, Chl-a\data\SST\m_mhw1.0-master\

%% Figure 4 Correlation Analysis (All Indicators)
close all
% Except for regions NE and E, wind stress is only related to rainfall
% chla is the latest calculation
variables = {'TPI','sst1', 'chla','tao', 'curl','ssr', 'tcc', 'tp','oni',...
        'Frequency','MeanInt','MaxInt','CumInt','Duration','Days'}; % CHLA is not used temporarily because it has only 24 years of data.
variables_name = {'TPI', 'SST','Chl-\ita', 'Wind Stress', 'Wind Curl',...
    'Net Solar Radiation', 'Cloud Cover', 'Precipitation','ONI', 'MHW Frequency','MHW MeanInt','MHW MaxInt','MHW CumInt','MHW Duration','MHW Days'};

regions = {'E'};
region_name = {'Eastern Hainan'};
output_filepath = "D:\BaiduNetdiskWorkspace\Article\Marine Biogeochemical Process and Others\Region\EH-Interannual Variation, MHW\Figure\Final\";
% Custom colormap green~white~red
n = [1 42 127 211 252];        
J = zeros(252,3);
%-----------------------------------------------R
J(n(1):n(2),1) = linspace(0.5,1,n(2)-n(1)+1);
J(n(2):n(3),1) = 1;
J(n(3):n(4),1) = linspace(1,0,n(4)-n(3)+1);
%-----------------------------------------------G
J(n(2):n(3),2) = linspace(0,1,n(3)-n(2)+1);
J(n(3):n(4),2) = 1;
J(n(4):n(5),2) = linspace(1,0.5,n(5)-n(4)+1);
%-----------------------------------------------B
J(n(2):n(3),3) = linspace(0,1,n(3)-n(2)+1);
J(n(3):n(4),3) = linspace(1,0,n(4)-n(3)+1);
% The plot appears reversed, with green representing positive values, so use flipud to flip it
J = flipud(J);
% Create ONI index variables for each region for correlation analysis; all regions use the same data
for i = 1:numel(regions)
    variable = ['detrend_oni_annual_', regions{i}];
    eval([variable, ' = detrend(oni_data_study)']);
end
start_char = abs('a'); % Get ASCII of 'a'
for i = 1:numel(regions)
    total_data = [];
    variable_data = {};
    for j = 1:numel(variables)
        variable = ['detrend_',variables{j},'_annual_', regions{i}];

        if exist(variable,'var') % Check if variable exists
            % If the variable has 40 years, take the last 24 years
            if numel(eval(variable)) == 40
                variable_item = eval([variable,'(17:end)']);
            elseif numel(eval(variable)) == 24
                variable_item = eval(variable);
            end
            variable_data = [variable_data(:)', { variables_name{j}}]; % Similar to list append
            % Each row represents a variable
            if size(variable_item, 1) == 1
               total_data = [total_data; variable_item];
            else
               total_data = [total_data; variable_item']; % Double single quotes represent a single quote in strings
            end
        end
    end

    
    % Calculate correlation matrix and plot
    [corr_data, pvalue] = corr(total_data');
    pvalue(pvalue == 1) = 0; % Set p-value of self-correlated variables to 0 for display
%     corr_data(abs(pvalue) >= 0.05) = 0; 
    corr_data(abs(pvalue) >= 0.05) = 0; 
%     figure()
%     H = heatmap(variable_data, variable_data, pvalue);
%     title(['pvalue-Area', regions{i}]);
%     set(gca, 'fontsize',20,'FontName','Times New Roman');
   
%     mytitle = ['(', char(start_char+i-1), ') ','\fontname{宋体}\fontsize{20}', region_name{i}];
    mytitle = '';
    f1 = plot_corr_tri(corr_data, variables_name, [-1,1], flipud(slanCM(98)), mytitle);
    
   
    fileName = strcat(output_filepath,'Correlation.tif');
    set(f1,'position',[100 100 1400 800]);
    exportgraphics(f1, fileName); % Export figure without white borders
end
