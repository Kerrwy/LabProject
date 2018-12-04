function Flow3DDisplay(vSurfT,  Location)
% Show 3D object flow and effective points.

global Width Height Events
len = length(vSurfT);
Ts=[];Tsl=[];
X=[];Xl=[];
Y=[];Yl=[];
for i=2:len-1
    vSurf = vSurfT{i};
    location = Location{i};
    
    [Tss, idx] = sort(vSurf(:),'ascend');
    RealTs = find(Tss~=0);
    idx = idx(RealTs);
    ts = Tss(RealTs);
    y = mod(idx,Height);
    x = ceil(idx/Height);
    Ts = cat(1,Ts,ts);
    X = cat(1, X, x);
    Y = cat(1, Y, y);
    if isempty(location)
        continue;
    end
    ts1 = location(:,3);
    xl = location(:,1);
    yl = location(:,2);
    Tsl = cat(1, Tsl, ts1);
    Xl = cat(1, Xl, xl);
    Yl = cat(1, Yl, yl);
end

figure(1); clf;
set(gcf,'Position',[400,100,900,800], 'color','w');
scatter3( Y,Width-X+1, Ts, 2,  'filled');  % scatter3(x,y,z,S,C)散点的大小S,颜色C
hold on;
scatter3( Yl,Width-Xl+1,Tsl, 10, 'red', 'filled');
% view()
set(gca, 'ylim', [0 Width]);
set(gca, 'xlim', [0 Height]);
set(gca, 'zlim', [min(Events.ts) max(Events.ts)]);
% set(gca,'ZTick',(min(Ts):10e3:max(Ts))) %改变x轴坐标间隔显示 这里间隔为2
zlabel('ts (s)');
ylabel('x');
xlabel('y');
grid on;
hold off; % remove hold on if you want to visualize only data in the current window
drawnow;
end



