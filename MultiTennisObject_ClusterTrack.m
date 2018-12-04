%% 一、Data Prepare
close all;clc;clear;clear global;
global Width Height N nextId
Width = 768;
Height = 640;
Events = importdata('Crop2ren2bian_continus.mat');
Events.y = Height - Events.y+1;
% Events = DataPreprocessing('Crop2ren2bian.mat');

%% Initial Parameters, you may change according to your needs.
N = 60000;
len = length(Events.x);
vSurfSum = zeros(Height, Width);
vSurfT = zeros(Height, Width);
vSurfSub = cell(1, ceil(len/N));
Location = cell(1, ceil(len/N));
Count = cell(1, ceil(len/N));
for j=1:ceil(len/N)
    vSurfSub{j} = vSurfSum;
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
Location = importdata('Location.mat');
% vSurfSub = importdata('vSurfSub_denoised.mat');

for i = 1:len
    xi = Events.x(i);
    yi = Events.y(i);
    tsi = Events.ts(i);
    Idx = ceil(i/N);
    %     vSurfT(yi, xi) = tsi;
    vSurfSub{Idx}(yi, xi) = 1;
    
    if(rem(i, N)==0)
        %% k聚类检测特征点
        %         for k = 1:WindowNumber
        %             for kk = 1:WindowNumber
        %                 xi = Lwc(k);
        %                 yi = Lhc(kk);
        %                 [location, count, vSurfSub{Idx}] = EventClusterAlgorithm(yi, xi, Lw, Lh, vSurfSub{Idx}, vSurfT);
        %                 if isempty(location)
        %                     continue;
        %                 end
        %                 Location{Idx} = cat(1, Location{Idx}, location);
        %                 Count{Idx} = Count{Idx}+ count;
        %             end
        %         end
        disp([ '------' int2str( i / len * 100 ) '% effective event points of whole objects motion flow done.']);
        
        %%  显示特征点，测试特征点匹配度
        %         Visualiz(vSurfSub{Idx}, Location{Idx});
        %         [matched_pts1, matched_pts2] = PointsDescriptionAndMatch(Location, Idx, vSurfSub);
        
        %%  检测目标
        %         if isempty(Location{Idx})
        %             imshow(vSurfSub{Idx});
        %             drawnow;
        %             continue;
        %         end
        %         [outMetrix, outCorr] = PointsToObject(Location{Idx}, vSurfSub{Idx});
        %         showDetection(vSurfSub{Idx}, outCorr);
        
        %% 根据特征点的匹配得到目标匹配
        if( i == N)
            [outMetrix, outCorr] = PointsToObject( Location{Idx}, vSurfSub{Idx});
            createFirstTracks(outMetrix, outCorr, Idx);
            showTrack(vSurfSub, Idx);
        else
            if isempty(Location{Idx})
                imshow(vSurfSub{Idx});
                drawnow;
                continue;
            end            
            [outMetrix, outCorr, Assignments, UnassignedTracks, UnassignedDetections] = objectMatch(Location{Idx}, vSurfSub{Idx});
            updateAssignedTracks(Assignments, outMetrix, outCorr,Idx);
            updateUnassignedTracks(UnassignedTracks);
            deleteLostTracks;
            
            createNewTracks(outMetrix, outCorr, Idx, UnassignedDetections);
            showTrack(vSurfSub, Idx);
        end
        
        %% 跟踪目标
        %         if( i == 2*N)
        %             [outMetrix, outCorr] = PointsToObject2( Location{Idx}, vSurfSub{Idx});
        %             createFirstTracks(outMetrix, outCorr, Idx);
        %             showTrack(vSurfSub, Idx);
        %         else
        %             %             predictNewLocationsOfTracks;
        %             [outMetrix, outCorr, Assignments, UnassignedTracks, UnassignedDetections] = objectMatch(Location{Idx}, vSurfSub{Idx});
        %             updateAssignedTracks(Assignments, outMetrix, outCorr,Idx);
        %             updateUnassignedTracks(UnassignedTracks);
        %             deleteLostTracks;
        %             showTrack(vSurfSub, Idx);
        %             createNewTracks(outMetrix, outCorr, Idx, UnassignedDetections);
        %         end
    end
end
toc;