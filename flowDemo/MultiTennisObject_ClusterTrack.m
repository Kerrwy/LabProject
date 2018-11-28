%% 一、Data Prepare
close all;clc;clear;clear global;
global Width Height N nextId tracks Events
Width = 768;
Height = 640;
% EventsPath = 'TennisFlow.mat';
Events = importdata('..\Crop2ren2bian_continus.mat');
% Events = DataPreprocessing(EventsPath);
Events.y = Height - Events.y+1;

%% 去除边缘事件 0.209072 秒
% y = Events.y;
% parfor i = 1:length(y)
%     if (y(i)<=50)
%         a(i)=1;
%     end
% end
% Events.ts((a==1),:)=[];
% Events.y((a==1),:)=[];
% Events.x((a==1),:)=[];
% Events.poli((a==1),:)=[];
% clear a;
%% Initial Parameters, you may change according to your needs.
N = 60000;
len = length(Events.x);
vSurfSum = zeros(Height, Width);
% vSurfT = zeros(Height, Width);
vSurfSub = cell(1, ceil(len/N));
Location = cell(1, ceil(len/N));
Count = cell(1, ceil(len/N));
for j=1:ceil(len/N)
    vSurfSub{j} = vSurfSum;
    vSurfT{j} = vSurfSum;
    Location{j} = [];
    Count{j} = 0;
end

%% Define WindowNumber*WindowNumber time window, size = (Lw,Lh)
WindowNumber = 32;
Lw = Width/WindowNumber;
Lh = Height/WindowNumber;
Lwc = linspace(Lw/2, Width-Lw/2, WindowNumber);
Lhc = linspace(Lh/2, Height-Lh/2, WindowNumber);

%% 二、Multiple object events operating.
tic;
fprintf("Start calculating effective points...\n");
initializeTracks; % Create an empty array of tracks.
nextId = 1;

for i = 1:len
    xi = Events.x(i);
    yi = Events.y(i);
    tsi = Events.ts(i);
    Idx = ceil(i/N);
    vSurfT{Idx}(yi, xi) = tsi;
    vSurfSub{Idx}(yi, xi) = 1;
    
    if(rem(i, N)==0 && (i>2*N))
        %         vSurfSum = vSurfSum + vSurfSub{Idx-1};
        %         vSurfON = Logital(vSurfSub{Idx} - Logital(vSurfSum));
        %% k聚类检测特征点
        for k = 1:WindowNumber
            for kk = 1:WindowNumber
                xi = Lwc(k);
                yi = Lhc(kk);
                [location, count, vSurfSub{Idx}] = EventClusterAlgorithm(yi, xi, Lw, Lh, vSurfSub{Idx}, vSurfT{Idx});
                if isempty(location)
                    continue;
                end
                Location{Idx} = cat(1, Location{Idx}, location);
                Count{Idx} = Count{Idx}+ count;
            end
        end
        disp([ '------' int2str( i / len * 100 ) '% effective event points of whole objects motion flow done.']);
        
        %%  显示特征点; 测试特征点匹配度
%         Visualiz(vSurfSub{Idx}, Location{Idx});
        %         [matched_pts1, matched_pts2] = PointsDescriptionAndMatch(Location, Idx, vSurfSub);
        
        %%  检测目标
%                         if isempty(Location{Idx})
%                             imshow(vSurfSub{Idx});
%                             drawnow;
%                             continue;
%                         end
%                         [outMetrix, outCorr] = PointsToObject(Location{Idx}, vSurfSub{Idx});
%                         showDetection(vSurfSub{Idx}, outCorr);
        
        %% 根据特征点的匹配得到目标匹配
        %         if( i == 3*N)
        %             [ outMetrix, outCorr, objectCorr]  = PointsToObject( Location{Idx}, vSurfSub{Idx});
        %             createFirstTracks(outMetrix, outCorr, Idx);
        %             %             showTrack(vSurfSub, Idx);
        %             %             showMatchPoints1(vSurfSub, objectCorr, Idx);
        %             Flow3DDisplay1(vSurfT{Idx}, objectCorr);
        %         else
        %             if isempty(Location{Idx})
        %                 [Tss, idx] = sort(vSurfT{Idx}(:),'ascend');
        %                 RealTs = find(Tss~=0);
        %                 idx = idx(RealTs);
        %                 ts = Tss(RealTs);
        %                 y = mod(idx,Height);
        %                 x = ceil(idx/Height);
        %                 figure(1); clf;
        %                 set(gcf,'Position',[60,90,1800,900], 'color','w');
        %                 set(gca, 'ylim', [0 Width]);
        %                 set(gca, 'xlim', [0 Height]);
        %                 set(gca, 'zlim', [min(ts) max(ts)]);
        %                 scatter3(y, Width-x+1, ts, 10,  'filled');  % scatter3(x,y,z,S,C)
        %                 drawnow;
        %                 continue;
        %             end
        %             [outMetrix, outCorr, objectCorr, Assignments, UnassignedTracks, UnassignedDetections] = objectMatch(Location{Idx}, vSurfSub{Idx});
        %             updateAssignedTracks(Assignments, outMetrix, outCorr,Idx);
        %             updateUnassignedTracks(UnassignedTracks);
        %             deleteLostTracks;
        %
        %             createNewTracks(outMetrix, outCorr, Idx, UnassignedDetections);
        %             %             showTrack(vSurfSub, Idx);
        %             %             showMatchPoints2(vSurfSub, Assignments, objectCorr, Idx);
        %             Flow3DDisplay2(vSurfT{Idx}, objectCorr, Assignments)
        %         end
        
        %% 跟踪目标
                        if( i == 2*N)
                            [outMetrix, outCorr] = PointsToObject( Location{Idx}, vSurfSub{Idx});
                            createFirstTracks(outMetrix, outCorr, Idx);
                            showTrack(vSurfSub, Idx);
                        else
                            %             predictNewLocationsOfTracks;
                            [outMetrix, outCorr, Assignments, UnassignedTracks, UnassignedDetections] = objectMatch(Location{Idx}, vSurfSub{Idx});
                            updateAssignedTracks(Assignments, outMetrix, outCorr,Idx);
                            updateUnassignedTracks(UnassignedTracks);
                            deleteLostTracks;
                            showTrack(vSurfSub, Idx);
                            createNewTracks(outMetrix, outCorr, Idx, UnassignedDetections);
                        end
    end
%     Percentage = 6;
%     if (rem(i, N)==0 &&i>=Percentage*N)
%         %         vSurfSum = vSurfSum - vSurfSub{Idx-Percentage+1};
%                 vSurfTPause = vSurfT(Idx-Percentage+1:Idx);
%         LocationPause = Location(Idx-Percentage+1:Idx);
%                 Flow3DDisplay(vSurfTPause,  LocationPause);
% %         Flow3DDisplay_Fast(Events, i, Percentage*N,  Location)
%     end
end
toc;

function showMatchPoints1(vSurfSub, outCorr, Idx)
imshow(vSurfSub{Idx});
hold on;
parfor i=1:length(outCorr)
    scatter(outCorr{i}(:, 1), outCorr{i}(:, 2), 300, '.', 'r');
end
hold off;
drawnow;
end

function showMatchPoints2(vSurfSub, Assignments, outCorr, Idx)
imshow(vSurfSub{Idx});
hold on;
% Assignments第一行检测器，第二行跟踪器
numAssignedTracks = size(Assignments, 1);
for j = 1:numAssignedTracks
    detectionIdx = Assignments(j,1);
    location = outCorr{detectionIdx};
    scatter(location(:, 1), location(:, 2), 300, '.', 'r');
end
hold off;
drawnow;
end

function Flow3DDisplay1(vSurfT, outCorr)
global  Width Height

[Tss, idx] = sort(vSurfT(:),'ascend');
RealTs = find(Tss~=0);
idx = idx(RealTs);
ts = Tss(RealTs);
y = mod(idx,Height);
x = ceil(idx/Height);
figure(1); clf;
set(gcf,'Position',[60,90,1800,900], 'color','w');
set(gca, 'ylim', [0 Width]);
set(gca, 'xlim', [0 Height]);
set(gca, 'zlim', [min(ts) max(ts)]);
% scatter3(Ts, Width-X+1, Y, 10,  'filled');  % scatter3(x,y,z,S,C)
scatter3(y, Width-x+1, ts, 10,  'filled');  % scatter3(x,y,z,S,C)
hold on;
for i=1:length(outCorr)
    %     scatter3(outCorr{i}(:, 3), Width-outCorr{i}(:, 1)+1, outCorr{i}(:, 2), 50, 'red', 'filled');
    scatter3(outCorr{i}(:, 2), Width-outCorr{i}(:, 1)+1,outCorr{i}(:, 3),  50, 'red', 'filled');
end
xlabel('ts (s)');
ylabel('x');
zlabel('y');
grid on;
hold off; % remove hold on if you want to visualize only data in the current window
drawnow;
end
