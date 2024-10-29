function h = biplotdiy(varargin)
%BIPLOT Biplot of variable/factor coefficients and scores.
%   BIPLOT(COEFS) creates a biplot of the coefficients in the matrix
%   COEFS.  The biplot is 2D if COEFS has two columns, or 3D if it has
%   three columns.  COEFS usually contains principal component coefficients
%   created with PCA or PCACOV, or factor loadings estimated with
%   FACTORAN or NNMF.  The axes in the biplot represent the principal
%   components or latent factors (columns of COEFS), and the observed
%   variables (rows of COEFS) are represented as vectors.
%
%   BIPLOT(COEFS, ..., 'Scores', SCORES) plots both COEFS and the scores in
%   the matrix SCORES in the biplot.  SCORES usually contains principal
%   component scores created with PCA or factor scores estimated with
%   FACTORAN.  Each observation (row of SCORES) is represented as a point
%   in the biplot.
%
%   A biplot allows you to visualize the magnitude and sign of each
%   variable's contribution to the first two or three principal components,
%   and how each observation is represented in terms of those components.
%   Use the data cursor to read precise values from the plot.
%
%   BIPLOT imposes a sign convention, forcing the element with largest
%   magnitude in each column of COEFS to be positive.  This flips some of the
%   vectors in COEFS to the opposite direction, but often makes the plot
%   easier to read.  Interpretation of the plot is unaffected, because
%   changing the sign of a coefficient vector does not change its meaning.
%
%   BIPLOT(COEFS, ..., 'VarLabels',VARLABS) labels each vector (variable)
%   with the text in the character array or cell array VARLABS.
%
%   BIPLOT(COEFS, ..., 'Scores', SCORES, 'ObsLabels', OBSLABS) uses the
%   text in the character array or cell array OBSLABS as observation names
%   when displaying data cursors.
%
%   BIPLOT(COEFS, ..., 'Positive', true) restricts the biplot to the positive
%   quadrant (in 2D) or octant (in 3D). BIPLOT(COEFS, ..., 'Positive', false)
%   (the default) makes the biplot over the range +/- MAX(COEFS(:)) for all
%   coordinates.
%
%   BIPLOT(COEFFS, ..., 'PropertyName',PropertyValue, ...) sets properties
%   to the specified property values for all line graphics objects created
%   by BIPLOT.
%
%   BIPLOT(AX,...) plots into AX instead of GCA.
% 
%   H = BIPLOT(COEFS, ...) returns a column vector of handles to the
%   graphics objects created by BIPLOT.  H contains, in order, handles
%   corresponding to variables (line handles, followed by marker handles,
%   followed by text handles), to observations (if present, marker
%   handles), and to the axis lines.
%
%   Example:
%
%      load carsmall
%      X = [Acceleration Displacement Horsepower MPG Weight];
%      X = X(all(~isnan(X),2),:);
%      [coefs,score] = pca(zscore(X));
%      vlabs = {'Accel','Disp','HP','MPG','Wgt'};
%      biplot(coefs(:,1:3), 'scores',score(:,1:3), 'varlabels',vlabs);
%
%   See also FACTORAN, NNMF, PCA, PCACOV, ROTATEFACTORS.

%   References:
%     [1] Seber, G.A.F. (1984) Multivariate Observations, Wiley.

%   Copyright 1993-2020 The MathWorks, Inc. 

% !!!自定义text的特性：
varTextArgs = { 'fontsize',25,'FontName','Times New Roman','color','b'}; % 向量的text
obsTextArgs = { 'fontsize',16,'FontName','Times New Roman'}; % 单点的text
% % 调整文本位置，避免重叠
% adjustAndHideTextPosition(obsHndl, 0.03, 0.04);
    
[~, cax, varargin] = parseplotapi(varargin{:},'-mfilename',mfilename);

% check input number nargin = 0 or only axes input case
if nargin < 1
    error(message('stats:biplot:TooFewInputs'));
elseif nargin == 1 && ~isempty(cax)
    error(message('stats:biplot:TooFewInputs'));
elseif isempty(cax)
    cax = newplot;
end

coefs = varargin{1};
varargin = varargin(2:end);

% Choose whether the datatip can attach to Axes or Variable lines.
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

cursorOnAxes = false;
cursorOnVars = true;

[p,d] = size(coefs);

if (d < 2) || (d > 3)
    error(message('stats:biplot:CoefsSizeMismatch'));
elseif isempty(coefs)
    error(message('stats:biplot:EmptyInput'));
end
in3D = (d == 3);

% Process input parameter name/value pairs, assume unrecognized ones are
% graphics properties for PLOT.
% 为了自定义不同投影变量的颜色，添加一个varTextColor
pnames = {'scores' 'varlabels' 'obslabels' 'positive'};
dflts =  {     []          []          []         [] };
[scores,varlabs,obslabs,positive,~,plotArgs] = ...
                    internal.stats.parseArgs(pnames, dflts, varargin{:});




if ~isempty(scores)
    [n,d2] = size(scores);
    if d2 ~= d
        error(message('stats:biplot:ScoresSizeMismatch'));
    end
end

if ~isempty(positive)
    if ~isscalar(positive) || ~islogical(positive)
        error(message('stats:biplot:InvalidPositive'));
    end
else
    positive = false;
end

dataCursorBehaviorObj = hgbehaviorfactory('DataCursor');
set(dataCursorBehaviorObj,'UpdateFcn',@biplotDatatipCallback);
disabledDataCursorBehaviorObj = hgbehaviorfactory('DataCursor');
set(disabledDataCursorBehaviorObj,'Enable',false);

if nargout > 0
    varTxtHndl = [];
    obsHndl = [];
    axisHndl = [];
end

% Force each column of the coefficients to have a positive largest element.
% This tends to put the large var vectors in the top and right halves of
% the plot.
[~,maxind] = max(abs(coefs),[],1);
colsign = sign(coefs(maxind + (0:p:(d-1)*p)));
coefs = coefs .* colsign;

% Plot a line with a head for each variable, and label them.  Pass along any
% extra input args as graphics properties for plot.
%
% Create separate objects for the lines and markers for each row of COEFS.
zeroes = zeros(p,1); nans = NaN(p,1);
arx = [zeroes coefs(:,1) nans]';
ary = [zeroes coefs(:,2) nans]';
if in3D
    arz = [zeroes coefs(:,3) nans]';
    varHndl = [line(cax,arx(1:2,:),ary(1:2,:),arz(1:2,:), 'Color','b', 'LineStyle','-', plotArgs{:}, 'Marker','none'); ...
               line(cax,arx(2:3,:),ary(2:3,:),arz(2:3,:), 'Color','b', 'Marker','.', plotArgs{:}, 'LineStyle','none')];
else
    varHndl = [line(cax,arx(1:2,:),ary(1:2,:), 'Color','b', 'LineStyle','-', plotArgs{:}, 'Marker','none','linewidth', 1); ...
               line(cax,arx(2:3,:),ary(2:3,:), 'Color','b', 'Marker','.', plotArgs{:}, 'LineStyle','none','linewidth', 1)];
end
set(varHndl(1:p),'Tag','varline');
set(varHndl((p+1):(2*p)),'Tag','varmarker');
set(varHndl,{'UserData'},num2cell(([1:p 1:p])'));
if cursorOnVars
    hgaddbehavior(varHndl,dataCursorBehaviorObj);
else
    hgaddbehavior(varHndl,disabledDataCursorBehaviorObj);
end


if ~isempty(varlabs)
    if ~(ischar(varlabs) && (size(varlabs,1) == p)) && ...
                           ~(iscellstr(varlabs) && (numel(varlabs) == p))
        error(message('stats:biplot:InvalidVarLabels'));
    end

    % Take a stab at keeping the labels off the markers.
    delx = .01*diff(get(cax,'XLim'));
    dely = .01*diff(get(cax,'YLim'));
    if in3D
        delz = .01*diff(get(cax,'ZLim'));
    end

    if in3D
        varTxtHndl = text(cax,coefs(:,1)+delx,coefs(:,2)+dely,coefs(:,3)+delz,varlabs,'Interpreter','none',varTextArgs{:},'FontWeight','bold'); % 向量名加粗
    else
        varTxtHndl = text(cax,coefs(:,1)+delx,coefs(:,2)+dely,varlabs,'Interpreter','none',varTextArgs{:},'FontWeight','bold');
    end
    set(varTxtHndl,'Tag','varlabel');
    
    % 调整文本位置，避免重叠
    adjustAndHideTextPosition(varTxtHndl, 0.05, 0.05)
%     adjustTextPosition(varTxtHndl);
end



% Plot axes and label the figure.
if ~ishold(cax)
    view(cax,d);
    grid(cax,'on');
    axlimHi = 1.1*max(abs(coefs(:)));
    axlimLo = -axlimHi * ~positive;
    if in3D
        axisHndl = line(cax,[axlimLo axlimHi NaN 0 0 NaN 0 0],[0 0 NaN axlimLo axlimHi NaN 0 0],[0 0 NaN 0 0 NaN axlimLo axlimHi], 'Color','black');
    else
        axisHndl = line(cax,[axlimLo axlimHi NaN 0 0],[0 0 NaN axlimLo axlimHi], 'Color','black');
    end
    set(axisHndl,'Tag','axisline');
    if cursorOnAxes
        hgaddbehavior(axisHndl,dataCursorBehaviorObj);
    else
        hgaddbehavior(axisHndl,disabledDataCursorBehaviorObj);
    end

    xlabel("Component 1");
    ylabel("Component 2");
%     xlabel(cax,getString(message('stats:biplot:LabelComponent1')));
%     ylabel(cax,getString(message('stats:biplot:LabelComponent2')));
    if in3D
%         zlabel(cax,getString(message('stats:biplot:LabelComponent3')));
        zlabel("Component 3");
    end
    axis(cax,'tight');
end

% Plot data.
if ~isempty(scores)
    % Scale the scores so they fit on the plot, and change the sign of
    % their coordinates according to the sign convention for the coefs.
    maxCoefLen = sqrt(max(sum(coefs.^2,2)));
    scores = (maxCoefLen.*(scores ./ max(abs(scores(:))))).*colsign;
    
    % Create separate objects for each row of SCORES.
    nans = NaN(n,1);
    ptx = [scores(:,1) nans]';
    pty = [scores(:,2) nans]';
    % Plot a point for each observation, and label them.
    if in3D
        ptz = [scores(:,3) nans]';
        obsHndl = line(cax,ptx,pty,ptz, 'Color','r', 'Marker','.', plotArgs{:}, 'LineStyle','none');
    else
        obsHndl = line(cax,ptx,pty, 'Color','r', 'Marker','.', plotArgs{:}, 'LineStyle','none');
    end
    if ~isempty(obslabs)
        if ~(ischar(obslabs) && (size(obslabs,1) == n)) && ...
                           ~(iscellstr(obslabs) && (numel(obslabs) == n))
            error(message('stats:biplot:InvalidObsLabels'));
        end
        % ！！！添加了这里
         % Take a stab at keeping the labels off the markers.
        delx = .01*diff(get(cax,'XLim'));
        dely = .01*diff(get(cax,'YLim'));
        if in3D
            delz = .01*diff(get(cax,'ZLim'));
        end

        if in3D
            obsHndl = text(cax,scores(:,1)+delx,scores(:,2)+dely,scores(:,3)+delz,obslabs,'Interpreter','none',obsTextArgs{:});
        else
            obsHndl = text(cax,scores(:,1)+delx,scores(:,2)+dely,obslabs,'Interpreter','none',obsTextArgs{:});
        end
    end
    set(obsHndl,'Tag','obsmarker');
    set(obsHndl,{'UserData'},num2cell((1:n)'));
    hgaddbehavior(obsHndl,dataCursorBehaviorObj);
    % 调整文本位置，避免重叠
    adjustAndHideTextPosition(obsHndl, 0.03, 0.04);
end


if ~ishold(cax) && positive
    axlims = axis;
    axlims(1:2:end) = 0;
    axis(axlims);
end

if nargout > 0
    h = [varHndl; varTxtHndl; obsHndl; axisHndl];
end

    % -----------------------------------------
    % Generate text for custom datatip.
    function dataCursorText = biplotDatatipCallback(~,eventObj)
    clickPos = get(eventObj,'Position');
    clickTgt = get(eventObj,'Target');
    clickNum = get(clickTgt,'UserData');
    ind = get(eventObj,'DataIndex');
    switch get(clickTgt,'Tag')
    case 'obsmarker'
        dataCursorText = {getString(message('stats:biplot:CursorScores')) ...
            getString(message('stats:biplot:CursorComponent1',num2str(clickPos(1)))) ...
            getString(message('stats:biplot:CursorComponent2',num2str(clickPos(2)))) };
        if in3D
            dataCursorText{end+1} = getString(message('stats:biplot:CursorComponent3',num2str(clickPos(3))));
        end
        if isempty(obslabs)
            clickLabel =  num2str(clickNum);
        elseif ischar(obslabs)
            clickLabel = obslabs(clickNum,:);
        elseif iscellstr(obslabs)
            clickLabel = obslabs{clickNum};
        end
        dataCursorText{end+1} = '';
        dataCursorText{end+1} = getString(message('stats:biplot:CursorObservation',clickLabel));
    case {'varmarker' 'varline'}
        dataCursorText = {getString(message('stats:biplot:CursorLoadings')) ...
            getString(message('stats:biplot:CursorComponent1',num2str(clickPos(1)))) ...
            getString(message('stats:biplot:CursorComponent2',num2str(clickPos(2)))) };
        if in3D
            dataCursorText{end+1} = getString(message('stats:biplot:CursorComponent3',num2str(clickPos(3))));
        end
        if isempty(varlabs)
            clickLabel = num2str(clickNum);
        elseif ischar(varlabs)
            clickLabel = varlabs(clickNum,:);
        elseif iscellstr(varlabs)
            clickLabel = varlabs{clickNum};
        end
        dataCursorText{end+1} = '';
        dataCursorText{end+1} = getString(message('stats:biplot:CursorVariable',clickLabel));
    case 'axisline'
        comp = ceil(ind/3);
        dataCursorText = getString(message('stats:biplot:CursorComponent',num2str(comp)));
    otherwise
        dataCursorText = {...
            getString(message('stats:biplot:CursorComponent1',num2str(clickPos(1)))) ...
            getString(message('stats:biplot:CursorComponent2',num2str(clickPos(2))))};
        if in3D
            dataCursorText{end+1} = getString(message('stats:biplot:CursorComponent3',num2str(clickPos(3))));
        end
    end

    end % biplotDatatipCallback

end % biplot

% 定义调整文本位置的函数
function adjustTextPosition(textHandles, tolerance)
    for i = 1:numel(textHandles)
        pos1 = get(textHandles(i), 'Position');
        for j = (i+1):numel(textHandles)
            pos2 = get(textHandles(j), 'Position');
            if norm(pos1(1:2) - pos2(1:2)) < tolerance
                pos2(2) = pos1(2) + tolerance;
                set(textHandles(j), 'Position', pos2);
            end
        end
    end
end

% tolerance是要调整的大小，threshold是要隐藏重叠的重叠判定距离
function adjustAndHideTextPosition(textHandles, tolerance, threshold)
    maxIterations = 100; % 最大迭代次数，避免无限循环
    iteration = 0;
    
    while iteration < maxIterations
        iteration = iteration + 1;
        overlapsDetected = false;
        
        % 调整文本位置
        adjustTextPosition(textHandles, tolerance);
        
        for i = 1:numel(textHandles)
            pos1 = get(textHandles(i), 'Position');
            
            for j = (i+1):numel(textHandles)
                pos2 = get(textHandles(j), 'Position');
                
                % 使用阈值 threshold 进行判断
                if norm(pos1(1:2) - pos2(1:2)) < threshold
                    overlapsDetected = true;
                    
                    % 只显示第一个重叠的文本对象，隐藏其余的文本对象
                    if i < j
                        set(textHandles(j), 'Visible', 'off');
                    else
                        set(textHandles(i), 'Visible', 'off');
                    end
                end
            end
        end
        
        if ~overlapsDetected
            break; % 没有重叠，退出循环
        end
    end
end

