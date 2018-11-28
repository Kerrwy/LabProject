function  rect_position = showRectangle( RoiCorr, Lw, Lh )
% Show tracking rectangle.
%   Parameters:
%       RoiCorr: Effective event points.
% hold on;
x = RoiCorr(:, 1);
y = RoiCorr(:, 2);
rect_position = [min(x)-4*Lw, min(y)-Lw, max(x)-min(x)+5*Lw, max(y)-min(y)+Lh];
% rectangle('Position',rect_position, 'EdgeColor','r','LineWidth',2);
% hold off;
% drawnow;

end

