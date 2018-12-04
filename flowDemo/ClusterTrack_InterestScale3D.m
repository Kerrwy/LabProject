%% Ò»¡¢Data Prepare
close all;clc;clear;
global Width Height
Width = 768;
Height = 640;
EventsPath = 'eventsUseful_Ts.mat';
Event = importdata(EventsPath);
Events.x = Event(:,1)+1;
Events.y = Event(:,2)+1;
Events.ts = Event(:,3);
Events.y = Height - Events.y+1;
%% Remove the Edge
Edge = 5;
parfor i = 1:length(Events.x)
    if (Events.x(i)<=2*Edge || Events.x(i)>=Width - 2*Edge || Events.y(i)<=2*Edge || Events.y(i)>=Height -2*Edge)
        a(i)=1;
    end
end
Events.ts((a==1),:)=[];
Events.x((a==1),:)=[];
Events.y((a==1),:)=[];
clear a;
%
%% Initial Parameters, you may change according to your needs.
N = 30000;
len = length(Events.x);
vSurfSum = zeros(Height, Width);
vSurfSub = cell(1, ceil(len/N));
Location = cell(1, ceil(len/N));
Count = cell(1, ceil(len/N));
for j=1:ceil(len/N)
    vSurfSub{j} = vSurfSum;
    vSurfT{j} = vSurfSum;
    Location{j} = [];
    Count{j} = [];
end

%% Define WindowNumber*WindowNumber time window, size = (Lw,Lh)
WindowNumber = 64;
Lw = Width/WindowNumber;
Lh = Height/WindowNumber;
Lwc = linspace(Lw/2, Width-Lw/2, WindowNumber);
Lhc = linspace(Lh/2, Height-Lh/2, WindowNumber);

%% ¶þ¡¢Multiple object events operating.
tic;
fprintf("Start calculating effective points...\n");
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
        for k = 1:WindowNumber
            for kk = 1:WindowNumber
                xi = Lwc(k);
                yi = Lhc(kk);
                [location, count] = EventClusterAlgorithm_first(yi, xi, Lw, Lh, vSurfON, vSurfT{Idx});
                if isempty(location)
                    continue;
                end
                Location{Idx} = cat(1, Location{Idx}, location);
                Count{Idx} = cat(1, Count{Idx}, count);
            end
        end
%         [Value, Key] = sum(Count{Idx});
        RoiCorr = Location{Idx};
        %         S = sum(Count{Idx}(1:Key));
        %         RoiCorr = Location{Idx}(S:S+Value);
        
%         Visualiz(vSurfON, vSurfSub{Idx}, Location{Idx});
%         Flow3DDisplay1(vSurfT{Idx},Location{Idx});
        rect_position = showRectangle( RoiCorr, Lw, Lh );
        [row_min, row_max, col_min, col_max] = ROI(rect_position, Lw, Lh);
    elseif (rem(i,N)==0 && i>2*N)
        vSurfSum = vSurfSum + vSurfSub{Idx-1};
        vSurfON = Logital(vSurfSub{Idx} - Logital(vSurfSum));
        %         [location, count] = EventClusterAlgorithm_after(row_min, row_max, col_min, col_max, vSurfON, vSurfT);
        %           Location{Idx} = cat(1, Location{Idx}, location);
        
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
        
        Visualiz(vSurfON, vSurfSub{Idx}, Location{Idx});
%         Flow3DDisplay1(vSurfT{Idx}, Location{Idx});
        rect_position = showRectangle( Location{Idx}, Lw, Lh );
        [row_min, row_max, col_min, col_max] = ROI(rect_position, Lw, Lh);
        disp([ '------' int2str( i / len * 100 ) '% effective event points of whole objects motion flow done.']);
    end
end
% Flow3DDisplay2(vSurfT, Location);
toc;
function [row_min, row_max, col_min, col_max] = ROI(rect_position, Lw, Lh)
row_min = rect_position(1) + 2*Lw;
row_max = rect_position(1)+rect_position(3) + 7*Lw;
col_min = rect_position(2) - 2*Lh;
col_max = rect_position(2)+rect_position(4) + 2*Lh;
end