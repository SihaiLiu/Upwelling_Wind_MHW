%% Import Data
clear; clc;
load('data\detrend_annual_cor.mat');
load('data\enso_find.mat');

%% PCA of 40-year interannual summer variations for all variables except chlorophyll and some redundant variables
% close all
% Except for regions NE and E, wind stress is only related to rainfall
% variables = {'sst1','area','SST1','tao', 'coastal', 'curl','ssr', 'tcc', 'tp',...
%         'Frequency','MeanInt','MaxInt','CumInt','Duration','Days'}; % CHLA is not used temporarily because it has only 24 years of data.
% variables_name = {'SST','Upwelling Area','Front', 'Wind Stress', 'Coastal Wind', 'Wind Curl',...
%     'Net Solar Radiation', 'Cloud Cover', 'Precipitation', 'MHW Frequency','MHW MeanInt','MHW MaxInt','MHW CumInt','MHW Duration','MHW Days'};
% regions = {'E','NE', 'W', 'regW', 'regE'};

% MHW-specific indicators
variables = {'Frequency','MeanInt','MaxInt','CumInt','Duration','Days'}; % CHLA is not used temporarily because it has only 24 years of data.
variables_name = {'Frequency','Mean intensity','Max intensity','Cumulative intensity','Duration','Mean days'};
% varTextColor_list = {'b', 'b', 'r', 'r', 'b', 'r'};
regions = {'E'};
output_filepath = "D:\BaiduNetdiskWorkspace\Article\Marine Biogeochemical Process and Others\Region\EH-Interannual Variation, MHW\Figure\Final\";
years = {};
for i = 1:numel(detrend_area_annual_E)
    years{i} = num2str(1981 + i);
end
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

for i = 1:numel(regions)
    total_data = [];
    variable_data = {};
    for j = 1:numel(variables)
        variable = ['detrend_',variables{j},'_annual_', regions{i}];
        if exist(variable, 'var') % Check if variable exists
            variable_data = [variable_data(:)', { variables_name{j}}]; % Similar to list append
            % Each row represents a variable
            if size(eval(variable), 1) == 1
               total_data = [total_data; eval(variable)];
            else
               total_data = [total_data; eval([variable, ''''])]; % Double single quotes represent a single quote in strings
            end
        end
    end

    [ndim, prob, chisquare] = barttest(total_data', 0.05);
    p1 = zscore(total_data'); % Standardization, by default normalizes each column
    [ndim1, prob1, chisquare1] = barttest(p1, 0.05);
    % C = corr(p1,'type','Pearson'); % Calculate correlation

    [coeff{i}, score{i}, latent{i}, test{i}, explained{i}] = pca(p1);
    
    % MHW indicators
    f1 = figure();
%     PropertyValue = {'Component 1', 'Component 2'};
    b = biplotdiy(coeff{i}(:,1:2),'scores',score{i}(:,1:2),'varlabels', variables_name, 'obslabels', years(1:40), 'MarkerSize', 20);
    xlim([-0.6, 0.8]);
    ylim([-0.6, 0.7]);
    set(gca, 'fontsize', 25, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
    %     PropertyValue = {'Component 1', 'Component 2', 'Component 3'};
%     biplotdiy(coeff{i}(:,1:3), 'scores', score{i}(:,1:3), 'varlabels', variables_name, 'obslabels', years(1:40), 'PropertyName', PropertyValue);
    axisLimits = axis; 
%     title = ['(', char(abs('a') + i - 1), ')', regions{i}];
%     title = ['(', char(abs('a') + i - 1), ') ', '\fontname{Times New Roman}', region_name{i}];
%     text(axisLimits(1), axisLimits(4) - 0.05 * (axisLimits(4) - axisLimits(3)), title, 'fontname', 'Time New Roman', 'fontsize', 25, 'FontWeight', 'bold')
    ylabel('Component 2');
    xlabel('Component 1');
    set(f1, 'position', [100 100 1400 800]);
%     fileName = strcat(output_filepath, title, '-PCA-2D.tif');
    fileName = strcat(output_filepath, regions{i}, '-PCA-2D.tif');
    exportgraphics(f1, fileName); % Export figure without white borders
end

explain_mean = mean(cell2mat(explained), 2);
sum(explain_mean(1:3));
