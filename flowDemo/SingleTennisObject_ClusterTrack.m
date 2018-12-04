%% 一、Data Prepare
close all;clc;clear;clear global;
global Width Height N nextId Events
Width = 768;
Height = 640;
% EventsPath = 'Tennis2.mat';
% Events = DataPreprocessing(EventsPath);
% Events.y = Height - Events.y+1;
Events = importdata( 'Tennis2Processed.mat');
%% Initial Parameters, you may change according to your needs.
N = 40000;
len = length(Events.x);
vSurfSum = zeros(Height, Width);
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
WindowNumber = 64;
Lw = Width/WindowNumber;
Lh = Height/WindowNumber;
Lwc = linspace(Lw/2, Width-Lw/2, WindowNumber);
Lhc = linspace(Lh/2, Height-Lh/2, WindowNumber);

%% 二、Multiple object events operating.
tic;
fprintf("Start calculating effective points...\n");
% initializeTracks; % Create an empty array of tracks.
% nextId = 1;
EffectiveEventsNum = 60;
Percentage = 8;

for i = 1:len
    xi = Events.x(i);
    yi = Events.y(i);
    tsi = Events.ts(i);
    Idx = ceil(i/N);
    vSurfT{Idx}(yi, xi) = tsi;
    vSurfSub{Idx}(yi, xi) = 1;
    
    if(i == 2*N)
        vSurfSum = vSurfSum + vSurfSub{Idx-1};
        vSurfON = Logital(vSurfSub{Idx} - Logital(vSurfSum));
        %% k聚类检测特征点
        for k = 1:WindowNumber
            for kk = 1:WindowNumber
                xi = Lwc(k);
                yi = Lhc(kk);
                [location, count, vSurfSub{Idx}] = EventClusterAlgorithm(yi, xi, Lw, Lh, vSurfON, vSurfT{Idx}, EffectiveEventsNum);
                if isempty(location)
                    continue;
                end
                Location{Idx} = cat(1, Location{Idx}, location);
                Count{Idx} = Count{Idx}+ count;
            end
        end
        RoiCorr = Location{Idx};
        Visualiz(vSurfSub{Idx}, Location{Idx});
        rect_position = showRectangle( RoiCorr, Lw, Lh );
        [row_min, row_max, col_min, col_max] = ROI(rect_position, Lw, Lh);
    elseif (rem(i,N)==0 && i>2*N)
        vSurfSum = vSurfSum + vSurfSub{Idx-1};
        vSurfON = Logital(vSurfSub{Idx} - Logital(vSurfSum));
        
        EvetsBinary = vSurfON(col_min:col_max, row_min:row_max);
        EvetsTime = vSurfT{Idx}(col_min:col_max, row_min:row_max);
        Roiwidth = row_max - row_min;
        Roiheight = col_max - col_min;
        WindowNumber1 = 16;
        Lw1 = round(Roiwidth/WindowNumber1);
        Lh1 = round(Roiheight/WindowNumber1);
        Lwc1 = linspace(Lw1/2, Roiwidth-Lw1/2, WindowNumber1);
        Lhc1 = linspace(Lh1/2, Roiheight-Lh1/2, WindowNumber1);
        
        for k = 1:WindowNumber1
            for kk = 1:WindowNumber1
                xi1 = round(Lwc1(k));
                yi1 = round(Lhc1(kk));
                [location, count] = EventClusterAlgorithm_firstROI(yi1, xi1, Lw1, Lh1, EvetsBinary, EvetsTime, col_min, row_min);
                if isempty(location)
                    continue;
                end
                Location{Idx} = cat(1, Location{Idx}, location);
                Count{Idx} = Count{Idx}+ count;
            end
        end
        Location{Idx} = Visualiz(vSurfON, Location{Idx}, vSurfT{Idx}, WindowNumber, Lwc, Lhc, Lw, Lh);       
        if (rem(i, N)==0 &&i>=Percentage*N)
            vSurfSum = vSurfSum - vSurfSub{Idx-Percentage+1};
            %                 vSurfTPause = vSurfT(Idx-Percentage+1:Idx);
            %         LocationPause = Location(Idx-Percentage+1:Idx);
            %                 Flow3DDisplay(vSurfTPause,  LocationPause);
            % %         Flow3DDisplay_Fast(Events, i, Percentage*N,  Location)
        end
        if isempty(Location{Idx})
            continue;
        end
        
        rect_position = showRectangle( Location{Idx}, Lw, Lh );
        [row_min, row_max, col_min, col_max] = ROI(rect_position, Lw, Lh);
        disp([ '------' int2str( i / len * 100 ) '% effective event points of whole objects motion flow done.']);
    end
    
    
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

function [row_min, row_max, col_min, col_max] = ROI(rect_position, Lw, Lh)
global Width Height
row_min = max(1, rect_position(1) - 2*Lw);
row_max = min(Width, rect_position(1)+rect_position(3) + 9*Lw);
col_min = max(1, rect_position(2) - Lh);
col_max = min(Height, rect_position(2)+rect_position(4) + Lh);
end
