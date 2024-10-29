function [treeFig] = plot_corr_tri(corr, namelist, caxis_lim, mycolormap, mytitle)
    % Figure window and axes setup
    treeFig = figure('Position', [100, 100, 1000, 1000]);
    ax = axes(treeFig);
    ax.NextPlot = 'add';
    ax.DataAspectRatio = [1, 1, 1];
    ax.XColor = 'none';
    ax.YColor = 'none';

    % Heatmap plotting
    sqX = [-1, 0, 1, 0];
    sqY = [0, 1, 0, -1];
    for i = 1:size(corr, 1)
        for j = i:size(corr, 1)
            fill(ax, sqX + (i - 1) + (j - 1), sqY - (i - 1) + (j - 1), corr(i, j), 'EdgeColor', 'none')
            
            % Add correlation coefficient text on color blocks
            % Note: This assumes the correlation coefficients are small enough to display clearly
            if corr(i, j) ~= 0 % Do not display if the value is 0
                text(ax, (i - 1) + (j - 1), -(i - 1) + (j - 1), num2str(corr(i, j), '%0.2f'),...
                 'HorizontalAlignment', 'center',...
                 'VerticalAlignment', 'middle',...
                 'FontSize', 20,...
                 'FontName', 'Times New Roman');
             end
        end
    end
    axis(ax, 'tight')
    
    % Set color limits and add colorbar
    caxis(ax, caxis_lim)
    colormap(ax, mycolormap)
    cbHdl = colorbar(ax);
    cbHdl.Location = 'southoutside';
    cbHdl.FontName = 'Times New Roman';
    cbHdl.FontSize = 20;

    % Upper right labels
    for i = 1:size(corr, 1)
        text(ax, -1/2 + (i - 1) + size(corr, 1), -1/2 + size(corr, 1) - (i - 1), " " + namelist{i}, 'FontSize', 18,...
            'FontName', 'Times New Roman', 'HorizontalAlignment', 'left', 'Rotation', 45)
    end
    
    % Upper left labels
    for i = 1:size(corr, 1)
        text(ax, -3/2 - (i - 1) + size(corr, 1), -1/2 + size(corr, 1) - (i - 1), " " + namelist{size(corr, 1) + 1 - i}, 'FontSize', 18,...
            'FontName', 'Times New Roman', 'HorizontalAlignment', 'right', 'Rotation', -45);
    end
    if ~isempty(mytitle)
        % Adjust title position
        mainTitle = title(ax, mytitle, 'Units', 'normalized');
        % Get current title position
        titlePos = mainTitle.Position;
        % Adjust vertical position of the title (move up)
        titlePos(2) = titlePos(2) + 0.1; % Adjust value as needed
        % Set new title position
        mainTitle.Position = titlePos;
    end

    % Adjust axis position
    ax = gca; % Get current active axis object
    % Get current position and size
    currentPosition = ax.Position;
    % Increase width and height
    newPosition = currentPosition;
    newPosition(4) = newPosition(4) - 0.1; % Increase height
    % Update axis position and size
    ax.Position = newPosition;
    set(gca, 'fontsize', 20, 'FontName', 'Times New Roman');
end
