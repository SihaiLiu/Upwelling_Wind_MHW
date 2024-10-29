% Lasso Regression
% data: n rows by m columns, with the first m-1 columns as independent variables and the last column as the dependent variable
% k: number of folds
% alpha: regularization coefficient weight (between 0 and 1), when alpha=1, it's lasso regression
% lambda: range of regularization coefficients; trying different lambda values across various magnitudes is recommended
% p_alpha: confidence interval around 0.05 for the coefficients
% This code uses 10-fold cross-validation and outputs mean and standard deviation of errors across different lambda values

function [B, FitInfo, stats] = myLasso(X, Y, k, alpha, lambda, p_alpha)

    % Standardize
    [X1, mu, sigma] = zscore(X);
    % Combine standardized X with a column of ones
    X = [ones(size(X, 1), 1), X1];
    sigma = [1, sigma];
    % Cross-validation
    cv = cvpartition(size(X,1), 'kfold', k);
    mse = zeros(k, length(lambda));

    for i = 1:k
        trIdx = cv.training(i);
        teIdx = cv.test(i);
        B = lasso(X(trIdx,:), Y(trIdx), 'Alpha', alpha, 'Lambda', lambda);
        Y_pred = X(teIdx,:) * B + mean(Y(trIdx));
        for j = 1:length(lambda)
            mse(i,j) = mean((Y(teIdx) - Y_pred(:,j)).^2);
        end
    end

    % Calculate mean and standard deviation
    mse_mean = mean(mse);
    mse_std = std(mse);

    % Find optimal lambda
    [min_mse, min_idx] = min(mse_mean);

    % Train final model
    B = lasso(X, Y, 'Alpha', alpha, 'Lambda', lambda(min_idx));

    % Unstandardize coefficients
    B = B ./ sigma';
    B(1) = B(1) - sum(B(2:end).*mu'./sigma(2:end)');

    % Return results
    FitInfo.MSE_mean = mse_mean;
    FitInfo.MSE_std = mse_std;
    FitInfo.Lambda = lambda;
    FitInfo.min_mse = min_mse;
    FitInfo.min_idx = min_idx;

    % Calculate statistical tests manually
    n = size(X,1);
    k = size(X,2)-1; % Number of independent variables
    A = X' * X; % Information matrix A
    C = inv(A); % Inverse of information matrix
    b = X \ Y; % Calculate regression statistics vector, with the first element as the intercept
    SSE = Y' * Y - b' * X' * Y; % Residual sum of squares
    MSe = SSE / (n - k - 1); % Residual variance (subtracting 1 for intercept freedom)
    sb = sqrt(MSe * diag(C)); % Standard error of regression statistics
    SST = var(Y) * (n - 1);
    SSR = SST - SSE;
    
    stats.R2 = (SST - SSE) / SST;
    stats.F = (SSR / k) / (SSE / (n - k - 1)); % Adjust for models without intercept as (SSE / (n - k))
    stats.p_F = 1 - fcdf(stats.F, k, n - k - 1);
    stats.t = b ./ sb; % t-test for regression statistics (intercept included in degrees of freedom)
    stats.p_t = 2 * (1 - tcdf(abs(stats.t), n - k - 1));
    stats.B_CI = [B - tinv(1 - p_alpha / 2, size(X,1) - size(X,2)) .* sb, B + tinv(1 - p_alpha / 2, size(X,1) - size(X,2)) .* sb]; % Confidence interval for estimated coefficients

end
