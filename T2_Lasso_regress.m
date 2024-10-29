%% Import Data
clear; clc;
load('data\detrend_annual_cor.mat');
load('data\enso_find.mat');
load('data\variable-1998-2021.mat');

%% Lasso Regression (sst)
close all
clear b stats
regions = {'E'};
clear estimate pf pt r2 MSE
for epoch = 1:100
    for i = 1:numel(regions)
        yname = ['detrend_Days_annual_', regions{i}, '(17:end)'];
        zname = ['detrend_CumInt_annual_', regions{i}, '(17:end)'];
        chlaname = ['detrend_chla_annual_', regions{i}, ''''];
        
        X = [eval(yname) eval(zname)];
        y = eval(chlaname);
        
        % Set parameters
        k = 10; % Number of folds for cross-validation
        alpha = 1; % Lasso regression
        lambda = logspace(-3,3,100);

        % Perform Lasso regression
        [B, FitInfo, stats] = myLasso(X, y, k, alpha, lambda, 0.05);

        MSE(epoch,:,i) = FitInfo.min_mse;
        estimate(epoch,:, i) = B;
        pt(epoch,:,i) = stats.p_t;
        pf(epoch,i) = stats.p_F;
        r2(epoch,i) = stats.R2;        
    end
end
estimate1 = squeeze(mean(estimate, 1))';
pt1 = squeeze(mean(pt, 1))';
r21 = squeeze(mean(r2, 1))';
pf1 = squeeze(mean(pf, 1))';
MSE1 = squeeze(mean(MSE, 1))';

%% Upwelling and Years
Day = [0.22, -434.92];
Cum = [0.16, -311.98];
Intensity_E = -0.0075 * Day - 0.000985 * Cum;
% i.e., chl-a = -0.0016 * year + 2.9867
