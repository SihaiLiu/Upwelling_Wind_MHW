%% Figure 5
clear
load('data/MHW_wind_TPI.mat');
output_filepath = 'D:\BaiduNetdiskWorkspace\Article\Marine Biogeochemical Process and Others\Region\EH-Interannual Variation, MHW\Figure\initial\';
f1 = figure();
yyaxis left; % Left y-axis
plot(-1:-1:-10, -TPI_anomaly_pre_clim(1:10,1) ,'b.-','Linewidth',1,'Markersize',25);
hold on 
plot(0:9, -TPI_anomaly_later_clim(1:10,1) ,'b*-','Linewidth',1,'Markersize',15);
hold on
ylabel("Negative TPI anomaly (°C)");
ax1 = gca; % Get current axis handle
ax1.YColor = 'b';  % Set left y-axis color to blue

yyaxis right; % Right y-axis
plot(-1:-1:-10, tao_anomaly_pre_clim(1:10,1) ,'r.-','Linewidth',1,'Markersize',25);
hold on 
plot(0:9, tao_anomaly_later_clim(1:10,1) ,'r*-','Linewidth',1,'Markersize',15);
hold on
xlabel("Days");
ylabel("Wind stress anomaly (N/m^2)");
ax2 = gca; % Get current axis handle
ax2.YColor = 'r';  % Set right y-axis color to red

set(f1,'position',[100 100 1400 800]);
% legend('East', 'Northeast','West','Location','southeast')
set(gca, 'fontsize',25,'FontName','Times New Roman','FontWeight','bold'); % Set colorbar font size
exportgraphics(f1, [output_filepath, 'TPI-Wind Stress-anomaly-2.tif']); % Export figure without white borders
