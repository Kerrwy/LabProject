function [outMetrix2, outCorr2, objectCorr2, Assignments, UnassignedTracks, UnassignedDetections] = objectMatch(Location, vSurfGray)
%outCorr = ObjectScale(objectCorr)
% Matching multiple objects according to matched feature points.
%
%   Parameters:
%       X: This frame to show x-coordination.
%       Y: This frame to show y-coordination.
%       assignments: This frame matched points with last frame.
%       objectCorr: Targets consisting of X and Y.
%   Return:
%       location: New frame points have matched object.

% global DistanceThreshold
%% Get object
% X = Location(:,1);
% Y = Location(:,2);
% len = length(X);
% i = 1;
% while i<=len
%     objectCorr{i} = [X(i),Y(i)];
%     for j=i+1:len
%         Dis = dist([X(i), Y(i)], [X(j), Y(j)]');
%         if(Dis<DistanceThreshold)
%             temp = objectCorr{i};
%             objectCorr{i} = [];
%             temp = [temp,[X(j), Y(j)]];
%             objectCorr{i} = temp;
%             X(j)=0; Y(j)=0;
%         end
%     end
%     ID(i) = i;
%     X(X==0)=[]; Y(Y==0)=[];
%     i = i+1;
%     len = length(X);
% end
% outCorr = ObjectScale(objectCorr);
% len2 = size(outCorr,1);
% outMetrix2 = cell(1,len);
% I = vSurfGray{Idx};
% for i =1:len
%         outMetrix2{i} = I(outCorr(i,3):outCorr(i,4), outCorr(i,1):outCorr(i,2));
% end
    
[outMetrix2, outCorr2, objectCorr2]  = PointsToObject( Location, vSurfGray);

%% Surf match
global tracks  Width Height
len1 = length(tracks);
len2 = length(outMetrix2);
matchMetix = zeros(len2, len1);
scaleleft = 50;
scaleright = 50;

% 提取sift和surf特征，根本不能匹配
% for i =1:len2
%     I2 = outMetrix2{i};
%     points2 = detectSURFFeatures(I2);
%     [features2, ~] = extractFeatures(I2, points2, 'Method', 'SURF',  'SURFSize', 64);
%     if isempty(features2)
%         continue;
%     end
%     plen = length(points2);
%     for j=1:len1    %匹配率
%         I1 = tracks(j).object;
%         points1 = detectSURFFeatures(I1);
%         [features1, ~] = extractFeatures(I1, points1, 'Method', 'SURF', 'SURFSize', 64);
%         if isempty(features1)
%             continue;
%         end
%         index_pairs = matchFeatures(features1, features2, 'Unique', true, 'MaxRatio',1, 'MatchThreshold',100);   % 匹配的索引对
%         pmatch = size(index_pairs,1);
%         matchMetix(i,j) = -pmatch/plen;   % 匈牙利是求最小值
%     end
% end

%% 灰度直方图
% for i =1:len2
%     I2 = outMetrix2{i};
%     for j=1:len1
%         I1 = tracks(j).object;
%         [Count1,x]=imhist(I1,2);     % mhist(I,n)  计算和显示图像I的直方图，n为指定的灰度级数目，默认为256。如果I是二值图像，那么n仅有两个值。
%         [Count2,x]=imhist(I2,2);     % count为每一级灰度像素个数，x为灰度级
%         Sum1=sum(Count1);Sum2=sum(Count2);
%         Sumup = sqrt(Count1.*Count2);
%         SumDown = sqrt(Sum1*Sum2);
%         Sumup = sum(Sumup);
%         matchMetix(i,j) = -(1-sqrt(1-Sumup/SumDown));
%     end
% end

%% 模板匹配 NCC
% Roi = zeros(size(outCorr2));
% frame = [tracks.frame];
% location = location((frame == Idx),:);

for i =1:len2
    I2 = outMetrix2{i};
    Roi(1) = max(1, outCorr2(i,1)-scaleleft);
    Roi(2) = min(Width, outCorr2(i,2)+scaleleft);
    Roi(3) = max(1, outCorr2(i,3)-scaleright);
    Roi(4) = min(Height, outCorr2(i,4)+scaleright);    
    norm_I2 = norm(I2(:));
    
    for j=1:len1
        I1 = tracks(j).object;
        I1_scale = tracks(j).location;
%         if Roi(1)<I1_scale(1) && I1_scale(2)<Roi(2) && Roi(3)<=I1_scale(3) && I1_scale(4)<Roi(4)   % 相并
        if max(Roi(1),I1_scale(1)) <= min(Roi(2),I1_scale(2)) && max(Roi(3),I1_scale(3)) <= min(Roi(4),I1_scale(4))    %相交
            I1 = imresize(I1, size(I2));
            norm_I1 = norm(I1(:));
            I2 = double(I2(:));
            I1 = double(I1(:));
            matchMetix(i,j)= -I2'*I1 / sqrt(norm_I2*norm_I1);
        else
            matchMetix(i,j)= 0;
            continue;
        end
    end
end

%% Hungarian Algorithm find optimal solution
% len1: 跟踪器； len2:检测器
[assignment,~] = munkres(matchMetix);   %每行对应的列名
UnassignedTracks = [];
UnassignedDetections = [];
Assignments = [];

% unmatched detections
if len1<=len2
    for i=1:len2
        if assignment(i)==0
            UnassignedDetections = [UnassignedDetections,i];
        else
            Assignments = [Assignments; [i, assignment(i)]];
        end
    end
end

% unmatched tracks
if len1>len2
    idx = 1;
    for j=1:len1
        if ~ismember(j, assignment)
            UnassignedTracks = [UnassignedTracks,j];
        else
            Assignments = [Assignments; [idx,assignment(idx)]];
            idx = idx+1;
        end
    end
end

% matched value is low
matchedThreshold = 0;
for k=1:size(Assignments,1)
    if matchMetix(Assignments(k,1), Assignments(k,2))==matchedThreshold
        UnassignedDetections = [UnassignedDetections,Assignments(k,1)];
        UnassignedTracks = [UnassignedTracks,Assignments(k,2)];
        Assignments(k,:) = 0;
    end
end
Assignments(all(Assignments==0,2),:) = [];
end






