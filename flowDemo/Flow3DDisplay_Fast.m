% clear;clc;
% N = 40000;
% Width = 768;
% Height = 640;
% Events = importdata( 'Tennis2Processed.mat');
% load('LocationSingleTennis2.mat');
% Delta = 40000;
% for i=2*Delta:Delta:length(Events.x)
%     Flow3DDisplay_Fast(Events, i, Delta,  Location);
% end

% clear;clc;
% N = 60000;
% Width = 768;
% Height = 640;
% Events = importdata('..\Crop2ren2bian_continus.mat');
% load('Location.mat');
% Delta = 60000;
% for i=6*Delta:Delta:2500000%length(Events.x)
%     Flow3DDisplay_Fast(Events, i, Delta,  Location);
% end

function Flow3DDisplay_Fast(Events, i, Delta,  Location)
% Show 3D object flow and effective points.

% global Width Height N Tsl Xl Yl
Font = 25;
global Width Height N 
x = Events.x(i-Delta+1:i);
y = Events.y(i-Delta+1:i);
ts = Events.ts(i-Delta+1:i);
% x = Events.x(1:i);
% y = Events.y(1:i);
% ts = Events.ts(1:i);
% figure(1); clf;

set(gcf,'Position',[80,100,900,800], 'color','w');
s=scatter3( y, x, ts, 0.6, [0 0 0], 'filled');  % scatter3(x,y,z,S,C)散点的大小S,颜色C
alpha(s,0.2)
Location = Location(ceil((i-Delta+1)/N): ceil(i/N));

len = length(Location);
Tsl=[];
Xl=[];
Yl=[];
for i=1:len
    location = Location{i};
    if isempty(location)
        continue;
    end
    ts1 = location(:,3);
    xl = location(:,1);
    yl = location(:,2);
%     hold on;
%     scatter3( yl,Width-xl+1,ts1, 10, 'red', 'filled');
    Tsl = cat(1, Tsl, ts1);
    Xl = cat(1, Xl, xl);
    Yl = cat(1, Yl, yl);
end

hold on;
scatter3( Yl, Xl,Tsl, 2, 'b', 'filled');
set(gca, 'ylim', [0 Width]);
set(gca, 'xlim', [0 Height]);
% set(gca, 'zlim', [min(Events.ts(6*Delta:2500000)) max(Events.ts(6*Delta:2500000))]);
set(gca, 'zlim', [min(Events.ts(2*Delta:length(Events.x))) max(Events.ts(2*Delta:length(Events.x)))]);
set(gca,'LineWidth',2);
zlabel('Ts','FontSize',Font, 'FontWeight','bold');
ylabel('X','FontSize',Font, 'FontWeight','bold');
xlabel('Y','FontSize',Font, 'FontWeight','bold');

view(50,10)
grid on;
% hold off; % remove hold on if you want to visualize only data in the current window
drawnow;
hold on;
end
% view(-90,90)


