% function showTrack(vSurfSub, Idx, outCorr, id)
function showTrack(vSurfSub, Idx)

% Show tracking points, Different poins have different colors.
%
global tracks 
C = ['r','g','y','c','m','r','g','y','c','m'];
scale = 30;
location = [tracks.location];
location = transpose(reshape(location,4,[]));
id = [tracks.id];
frame = [tracks.frame];

location = location((frame == Idx),:);
id = id([tracks.frame] == Idx);

imshow(vSurfSub{Idx});
hold on;
for j=1:length(id)
%     if id(j)==0
%         continue;
%     else
        x1 = location(j, 1);x2 = location(j, 2);
        y1 = location(j, 3);y2 = location(j, 4);
        rect_position = [x1, y1, x2-x1, y2-y1];
        rectangle('Position',rect_position, 'EdgeColor',C(id(j)),'LineWidth',2);
        textBack = [x1, y1, scale, scale];
        rectangle('Position',textBack, 'EdgeColor',C(id(j)),'LineWidth',2,'FaceColor',C(id(j)));
        text(x1+4,y1+10,num2str(id(j)),'Color','black','FontSize',20, 'FontWeight','Bold');
%     end
end  
hold off;
drawnow;
end