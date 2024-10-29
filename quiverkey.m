function Q = quiverkey(Q, X, Y, U, XLON, XLAT ,label, varargin)
%QUIVERKEY legend for quiver
%
%   QUIVERKEY(Q, X, Y, U, label) 
%   
%   Arguments:
%       Q :      The quiver handle returned by a call to quiver
%       X,Y :    The location of the legend
%       U :      The unit length. If U<0, the arrow will be reversed
%       label :  The string with the length and units of the key
%   
%   Addition arguments:
%       Coordinates = [ 'axes' | 'data'(default) ]
% 
%           'axes' & 'figure' : 'axes' and 'figure' are normalized 
%                       coordinate systems with 0,0 in the lower left 
%                       and 1,1 in the upper right;
%           'data' :    use the axes data coordinates
% 
%       LabelDistance : Distance in 'coordinates' between the arrow and the
%                   label. Deauft is 0.1 (units 'axes').
% 
%       Color : overrides face and edge colors from Q.
% 
%       LabelPosition = [ 'N' | 'S'(default) | 'E' | 'W' ]
% 
%               Position the label above, below, to the right, 
%               to the left of the arrow, respectively.
% 
%       LabelColor : defaults to black
%       
%   Examples: 
% 
%   [x,y] = meshgrid(0:0.2:2,0:0.2:2);
%   u = cos(x).*y;
%   v = sin(x).*y;
%   figure; Qh = quiver(x,y,u,v);
%   quiverkey(Qh, 0.5, 2.5, 1, 'm/s', 'Color', 'r', 'Coordinates', 'data')
%   
% Author:
%   li12242 - Department of Civil Engineering in Tianjin University
% Email:
%   li12242@tju.edu.cn
% 
%%  自定义投影数据处理
global MAP_PROJECTION MAP_VAR_LIST

% Have to have initialized a map first

if isempty(MAP_PROJECTION)
  disp('No Map Projection initialized - call M_PROJ first!');
  return;
end
ulonindex = find(XLON(1,:)==X);
ulatindex = find(XLAT(:,1)==Y);
U_pre = U; % 保留转换前的U 
[X,Y]=m_ll2xy(X,Y,'clip','point');
[XE , YE]=m_ll2xy([XLON(:) XLON(:)+(.001)./cos(XLAT(:)*pi/180)]',[XLAT(:) XLAT(:)]','clip','off'); % 计算对角线上不同经度的经度变化0.001时的投影x值变化，此时YE两列相同
xe = reshape(diff(XE),size(XLAT));
U=rmmissing(U.*xe(ulonindex, ulatindex)*1000);  % u为经度矩阵69*77下的u速度矩阵(！！！注意：原单位为m/s，画图中为deg/s)， diff(XE) 为每个纬度对应的0.001经度变化的投影x值：77*1


%% get input argument
if nargin < 5 
    error('Input arguments" Number incorrect!')
end

if isempty(varargin) && mod(length(varargin), 2) ~= 0
    error('Input arguments donot pairs!')
else
    [CoorUnit, LabelDist, Color, LabelPosition, LabelColor] = getInput(varargin);
end


%% add legend arrow

% get original data
xData = get(Q, 'XData'); yData = get(Q, 'YData');
uData = get(Q, 'UData'); vData = get(Q, 'VData');

% get axes properties
haxes = get(Q, 'Parent');
xLim = get(haxes, 'XLim'); yLim = get(haxes, 'YLim');
NextPlot = get(haxes, 'NextPlot');

% set axes properties
set(haxes, 'NextPlot', 'add')

if strcmp(CoorUnit, 'axes')
    % position of legend arrow
    xa = xLim(1) + X*(xLim(2) - xLim(1));
    ya = yLim(1) + Y*(yLim(2) - yLim(1));
else
    xa = X; ya = Y;
end

% add legend arrow into data vector
xData = [xData(:); xa]; yData = [yData(:); ya];
uData = [uData(:); U];  vData = [vData(:); 0];

% reset data
set(Q, 'XData', xData, 'YData', yData, 'UData', uData, 'VData', vData);
set(Q, 'Color', Color)

%% add text
dx = LabelDist*(xLim(2) - xLim(1));
dy = LabelDist*(yLim(2) - yLim(1));

% set position of label
switch LabelPosition
    case 'N'
        xl = xa; yl = ya + dy;
    case 'S'
        xl = xa; yl = ya - dy;
    case 'E'
        xl = xa + dx; yl = ya;
    case 'W'
        xl = xa - dx; yl = ya;
end% switch

th = text(xl, yl, [num2str(U_pre), ' ', label]);
set(th, 'Color', LabelColor, 'FontSize', 15);

% turn axes properties to original
set(haxes, 'NextPlot', NextPlot)

end% func

%% sub function

function [CoorUnit, LabelDist, Color, LabelPosition, LabelColor] = getInput(varcell)
% Input:
%   varcell - cell variable
% Output:
% 
nargin = numel(varcell);

%% set default arguments

CoorUnit = 'data';
LabelDist = 0.05; % units 'axes'
Color = 'k';
LabelPosition = 'S';
LabelColor = 'k';

%% get input arguments
contour = 1;
while contour < nargin
    switch varcell{contour}
        case 'Coordinates'
            CoorUnit = varcell{contour+ 1};
        case 'LabelDistance'
            LabelDist = varcell{contour+ 1};
        case 'Color'
            Color = varcell{contour+ 1};
        case 'LabelPosition'
            LabelPosition = varcell{contour+ 1};
        case 'LabelColor'
            LabelColor = varcell{contour+ 1};
        otherwise
            error('Unknown input argument.')
    end% switch
    contour = contour + 2;
end% while

end% fun
