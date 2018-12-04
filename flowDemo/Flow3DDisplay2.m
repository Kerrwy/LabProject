function Flow3DDisplay2(vSurfT,  outCorr, Assignments)
% Show 3D object flow and effective points.

global Width Height

Ts=[];
X=[];
Y=[];
[Tss, idx] = sort(vSurfT(:),'ascend');
RealTs = find(Tss~=0);
idx = idx(RealTs);
ts = Tss(RealTs);
y = mod(idx,Height);
x = ceil(idx/Height);
Ts = cat(1,Ts,ts);
X = cat(1, X, x);
Y = cat(1, Y, y);

figure(1); clf; 
set(gcf,'Position',[60,90,1800,900], 'color','w');
set(gca, 'ylim', [0 Width]);
set(gca, 'xlim', [0 Height]);
set(gca, 'zlim', [min(Ts) max(Ts)]);
% scatter3(Ts, Width-X+1, Y, 10,  'filled');  % scatter3(x,y,z,S,C)
scatter3(Y,  Width-X+1, Ts,10,  'filled');  % scatter3(x,y,z,S,C)
hold on;
numAssignedTracks = size(Assignments, 1);
for j = 1:numAssignedTracks
    detectionIdx = Assignments(j,1);
    location = outCorr{detectionIdx};
%     scatter3(location(:,3), Width-location(:, 1)+1, location(:, 2), 50, 'red', 'filled');
    scatter3(location(:, 2), Width-location(:, 1)+1, location(:,3), 50, 'red', 'filled');
end
xlabel('ts (s)');
ylabel('x');
zlabel('y');
grid on;
hold off; % remove hold on if you want to visualize only data in the current window
drawnow;
end



