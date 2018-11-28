function showDetection(vSurfSub, outCorr)
% function showTrack(vSurfSub, Idx, colors)
% Show tracking points, Different poins have different colors.
%

imshow(vSurfSub);
hold on;
C = ['r','g','y','c','m'];
for j=1:size(outCorr, 1)  
    x = [outCorr(j, 1), outCorr(j, 2)];
    y = [outCorr(j, 3), outCorr(j, 4)];
    rect_position = [x(1), y(1), x(2)-x(1),y(2)-y(1)];
    rectangle('Position',rect_position, 'EdgeColor',C(j),'LineWidth',4);    
end
hold off;
drawnow;
end