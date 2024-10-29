%% Figure 3
load('data/variable-1998-2021.mat');
output_filepath = 'D:\BaiduNetdiskWorkspace\Article\Marine Biogeochemical Process and Others\Region\EH-Interannual Variation, MHW\Figure\Final\';
TPI_annual_E_neg = -TPI_annual_E;
% Generate random data as an example
x = 1998:2021;
% Perform linear regression
X = [x',ones([2021-1998+1,1])];
[b1,bint1,r1,rint1,stats1]=regress(chla_annual_E',X); % stats contains R2, F statistics, p-value, and estimated error variance
[b2,bint2,r2,rint2,stats2]=regress(TPI_annual_E_neg',X);
% Linear fit
p1 = polyfit(x, chla_annual_E, 1);
p2 = polyfit(x, TPI_annual_E_neg, 1);
% Generate fitted line data points
yy1 = polyval(p1, x);
yy2 = polyval(p2, x);

% Create a new figure window
f1 = figure();

% Use yyaxis to create two y-axes
yyaxis left; % Left y-axis
plot(x, chla_annual_E, 'b.-', 'LineWidth', 2, 'markersize', 30);
hold on 
plot(x, yy1, 'b--', 'LineWidth', 2);
% !!! \it for italic, \rm for normal, \bf for bold
ylabel('Chl-\ita\rm\bf(mg/m^3)'); % Set label for left y-axis 
ax1 = gca; % Get current axis handle
ax1.YColor = 'b';  % Set left Y-axis color to blue
intercept_char = sprintf('%+.2f', b1(2));
chla_legend = ['y=', num2str(b1(1), 2), 'x', intercept_char, '; {\itR}^2=', num2str(stats1(1), 1), ', {\itp}>0.05'];

yyaxis right; % Right y-axis
plot(x, TPI_annual_E_neg, 'r.-', 'LineWidth', 2, 'markersize', 30);
hold on 
plot(x, yy2, 'r--', 'LineWidth', 2);
ylabel('Negative TPI(°C)'); % Set label for right y-axis
intercept_char = sprintf('%+.2f', b2(2));
TPI_legend = ['y=', num2str(b2(1), 2), 'x', intercept_char, '; {\itR}^2=', num2str(stats2(1), 2), ', {\itp}<0.05'];
ax2 = gca;
ax2.YColor = 'r';

% Set all axes properties
box off;
ax = gca;
ax.LineWidth = 2;

% Set x-axis properties
xlabel('Year');
xlim([x(1), x(end)]);

% Add legend
lgd = legend('Chl-\ita', chla_legend, 'Negative TPI', TPI_legend, 'Location', 'north', 'fontsize', 20);
lgd.Box = 'off';

% Set global axis properties
set(gca, 'fontsize', 25, 'FontName', 'Times New Roman', 'FontWeight', 'bold');

set(f1, 'position', [100 100 1400 800]);
exportgraphics(f1, [output_filepath, 'F8_TPI_chla_annual.tif']); % Export figure without white borders

%% Figure 2
% Load data
load('data/mhw-6var-annual.mat');
output_filepath = 'D:\BaiduNetdiskWorkspace\Article\Marine Biogeochemical Process and Others\Region\EH-Interannual Variation, MHW\Figure\Final\';

start_year = 1982;

% Generate random data as an example
x = start_year:2021;
% Perform linear regression
X = [x',ones([2021-start_year+1,1])];
[b1,bint1,r1,rint1,stats1]=regress(annual_Frequency_E_mean,X);
[b2,bint2,r2,rint2,stats2]=regress(annual_MeanInt_E_mean,X);
[b3,bint3,r3,rint3,stats3]=regress(annual_Duration_E_mean,X);
[b4, ~, ~, ~, stats4] = regress(annual_MaxInt_E_mean, X);
[b5, ~, ~, ~, stats5] = regress(annual_Days_E_mean, X);
[b6, ~, ~, ~, stats6] = regress(annual_CumInt_E_mean, X);
% Generate fitted line data points
yy1 = polyval(b1, x);
yy2 = polyval(b2, x);
yy3 = polyval(b3, x);
yy4 = polyval(b4, x);
yy5 = polyval(b5, x);
yy6 = polyval(b6, x);

aspect_norm = [1 6 1];
f1 = figure();
layout = tiledlayout(6,1,'TileSpacing','compact','Padding','compact');

% Add first subplot
ax = nexttile;
daspect(aspect_norm);
plot(x, annual_Frequency_E_mean, 'b.-', 'LineWidth', 2, 'MarkerSize', 25);
hold on 
plot(x, yy1, 'b--', 'LineWidth', 2);
intercept_char = sprintf('%+.2f', b1(2));
legend1 = ['y=', num2str(b1(1), 2), 'x', intercept_char, '; {\itR}^2=', num2str(stats1(1), 2), ', {\itp}=', num2str(stats1(3), 2)];
lgd = legend("Frequency (times)", legend1, 'Location','bestoutside', 'fontsize', 20);
lgd.Box = 'off';
xlim([x(1), x(end)]);
set(gca, 'XColor', 'none');
set(gca, 'fontsize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
box off;

% Add second subplot
ax = nexttile;
daspect(aspect_norm);
plot(x, annual_MeanInt_E_mean, 'r.-', 'LineWidth', 2, 'MarkerSize', 25);
hold on 
plot(x, yy2, 'r--', 'LineWidth', 2);
intercept_char = sprintf('%+.2f', b2(2));
legend2 = ['y=', num2str(b2(1), 2), 'x', intercept_char, '; {\itR}^2=', num2str(stats2(1), 2), ', {\itp}=', num2str(stats2(3), 2)];
lgd = legend(['Mean intensity (°C)'], legend2, 'Location', 'bestoutside', 'fontsize', 20);
lgd.Box = 'off';
xlim([x(1), x(end)]);
set(gca, 'XColor', 'none');
set(gca, 'fontsize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
box off;

% Add third subplot
ax = nexttile;
daspect(aspect_norm);
plot(x, annual_Duration_E_mean, 'g.-', 'LineWidth', 2, 'MarkerSize', 25);
hold on 
plot(x, yy3, 'g--', 'LineWidth', 2);
intercept_char = sprintf('%+.2f', b3(2));
legend3 = ['y=', num2str(b3(1), 2), 'x', intercept_char, '; {\itR}^2=', num2str(stats3(1), 2), ', {\itp}=', num2str(stats3(3), 2)];
lgd = legend( ['Duration (days)'], legend3, 'Location', 'bestoutside', 'fontsize', 20);
lgd.Box = 'off';
set(gca, 'XColor', 'none');
xlim([x(1), x(end)]);
set(gca, 'fontsize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
box off;

% Add fourth subplot: Maximum intensity
ax = nexttile;
daspect(aspect_norm);
plot(x, annual_MaxInt_E_mean, 'm.-', 'LineWidth', 2, 'MarkerSize', 25);
hold on;
plot(x, yy4, 'm--', 'LineWidth', 2);
intercept_char = sprintf('%+.2f', b4(2));
legend4 = ['y=', num2str(b4(1), 2), 'x', intercept_char, '; {\itR}^2=', num2str(stats4(1), 2), ', {\itp}=', num2str(stats4(3), 2)];
lgd = legend(['Maximum intensity (°C)'], legend4, 'textcolor', 'r', 'Location', 'bestoutside', 'fontsize', 20);
lgd.Box = 'off';
set(gca, 'XColor', 'none');
xlim([x(1), x(end)]);
set(gca, 'fontsize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
box off;

% Add fifth subplot: Days
ax = nexttile;
daspect(aspect_norm);
plot(x, annual_Days_E_mean, 'c.-', 'LineWidth', 2, 'MarkerSize', 25);
hold on;
plot(x, yy5, 'c--', 'LineWidth', 2);
legend5 = sprintf('y=%.2fx%+.2f; {\\itR}^2=%.3f, {\\itp}=%.2f', b5(1), b5(2), stats5(1), stats5(3));
lgd = legend("Mean days (days)", legend5, 'textcolor', 'r', 'Location', 'bestoutside', 'fontsize', 20);
lgd.Box = 'off';
set(gca, 'XColor', 'none');
xlim([x(1), x(end)]);
set(gca, 'fontsize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
box off;

% Add sixth subplot: Cumulative intensity
ax = nexttile;
daspect(aspect_norm);
plot(x, annual_CumInt_E_mean, 'k.-', 'LineWidth', 2, 'MarkerSize', 25);
hold on;
plot(x, yy6, 'k--', 'LineWidth', 2);
intercept_char = sprintf('%+.2f', b6(2));
legend6 = sprintf('y=%.2fx%+.2f; {\\itR}^2=%.3f, {\\itp}=%.2f', b6(1), b6(2), stats6(1), stats6(3));
lgd = legend(['Cumulative intensity (°C)'], legend6, 'textcolor', 'r', 'Location', 'bestoutside', 'fontsize', 20);
lgd.Box = 'off';
xlim([x(1), x(end)]);
xlabel('Year', 'fontsize', 20);
set(gca, 'fontsize', 20, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
box off;

set(f1, 'position', [100 100 1400 2000]);
exportgraphics(f1, [output_filepath, 'F10_mhw_3var_annual.tif']); % Export figure without white borders
