%% Figure1 Climatology SST
load('data/sst.mat');

output_filepath = "D:\BaiduNetdiskWorkspace\Article\Marine Biogeochemical Process and Others\Region\EH-Interannual Variation, MHW\Figure\Final\";

% Select specified region
x1_pf = 104.9740;
x2_pf = 115;
y1_pf = 17;
y2_pf = 23.0250;
box_xrange_pf = find((lon - x1_pf) .* (lon - x2_pf) <= 0);
box_yrange_pf = find((lat - y1_pf) .* (lat - y2_pf) <= 0);
lon_sub = double(lon(box_xrange_pf));
lat_sub = double(lat(box_yrange_pf));

E_col_value = [19.475, 19.475, 18.775, 18.775];
E_row_value = [110.675, 111.075, 110.675, 110.2750];
col_value_2015 = [17.3, 17.3, 19.9, 19.9];
row_value_2015 = [109, 112, 112, 109];
col_value_2016 = [18.5, 18.5, 19.8, 19.8];
row_value_2016 = [110.3, 111.825, 111.825, 110.3];
% Plot summer average
% sst1_annual_climate_68 = squeeze(nanmean(sst1_month(:,:,summer_find), 3)); % 40-year average for June-August
f1 = figure();
m_proj('Mercator', 'lat', [17 23], 'lon', [105 115]);
m_pcolor(LON_sst, LAT_sst, sst1_annual_climate');
hold on
m_plot([E_row_value, E_row_value(1)], [E_col_value, E_col_value(1)], 'Color', [1 0 1], 'linewidth', 1.5);

% [C,h] = m_contour(lon_sub(1:77), lat_sub, sst1_annual_climate_68(1:77,:)', [29, -10], 'Color', 'k');
% hold on 
% clabel(C, h, 'fontsize', 15, 'LabelSpacing', 1000, 'Color', 'k', 'FontWeight', 'bold');
% [C,h] = m_contour(lon_sub(77:end), lat_sub, sst1_annual_climate_68(77:end,:)', [28.3, -10], 'Color', 'k');
% hold on 
% clabel(C, h, 'fontsize', 15, 'LabelSpacing', 1000, 'Color', 'k', 'FontWeight', 'bold');
shading interp
m_gshhs_h('patch', [.7 .7 .7], 'EdgeColor', [.7 .7 .7]);
% m_plot([row_value_2015, row_value_2015(1)], [col_value_2015, col_value_2015(1)], 'Color', 'k', 'linewidth', 1.5, 'linestyle', '--');
% hold on 
% m_plot([row_value_2016, row_value_2016(1)], [col_value_2016, col_value_2016(1)], 'Color', 'k', 'linewidth', 1.5);
% hold on 
m_grid('box', 'on', 'linest', 'none', 'linewidth', 1.5, 'tickdir', 'in', 'backcolor', [1 1 1], 'fontname', 'Time New Roman', 'fontsize', 15, 'FontWeight', 'bold');
m_text(lon_sub(45), lat_sub(70), ["Beibu Gulf"], 'fontname', 'Time New Roman', 'fontsize', 20, 'FontWeight', 'bold');
m_text(lon_sub(82), lat_sub(42), ["Hainan", "Island"], 'fontname', 'Time New Roman', 'fontsize', 20, 'FontWeight', 'bold');
m_text(lon_sub(80), lat_sub(105), "Chinese mainland", 'fontname', 'Time New Roman', 'fontsize', 20, 'FontWeight', 'bold');
m_text(112.5, 18.5, ["   South", "China Sea"], 'fontname', 'Time New Roman', 'fontsize', 20, 'FontWeight', 'bold');
m_text(lon_sub(5), lat_sub(10), "Vietnam", 'fontname', 'Time New Roman', 'fontsize', 20, 'FontWeight', 'bold');
% m_text(105.2, 22.6, "(d) Climate", 'fontname', 'Time New Roman', 'fontsize', 20, 'FontWeight', 'bold');

colormap(jet)
h = colorbar;
set(get(h, 'ylabel'), 'string', 'SST(℃)'); % ylabel is displayed on the side, title appears above the colorbar
set(gca, 'fontsize', 18, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
set(f1, 'position', [100 100 1000 600]); % 100,100: bottom-left corner coordinates, 1000,600: figure size
fileName = strcat(output_filepath, 'F1d_sst-68-climate.tif');
exportgraphics(f1, fileName); % Generate figure for publication without white borders
