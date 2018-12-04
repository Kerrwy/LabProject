function [matched_pts1, matched_pts2] = PointsDescriptionAndMatch(Location, Idx, vSurfSub)
% Generate descriptors and match.
% Reference:
%   https://ww2.mathworks.cn/help/vision/ref/matchfeatures.html?searchHighlight=matchFeatures&s_tid=doc_srchtitle
%
%   Parameters:
%   Returns:
%

if isempty(Location{Idx}) || isempty(Location{Idx-1})
    matched_pts1 = [];
    matched_pts2 = [];
    return;
else
    PointProperties1 = SURFPoints(Location{Idx-1});
    PointProperties2 = SURFPoints(Location{Idx});
    
    [features1, valid_points1] = extractFeatures(vSurfSub{Idx-1}, PointProperties1, 'Method', 'SURF','SURFSize', 64);
    [features2, valid_points2] = extractFeatures(vSurfSub{Idx}, PointProperties2, 'Method', 'SURF','SURFSize', 64);
    
    index_pairs = matchFeatures(features1, features2,'Unique', true, 'MaxRatio',1,'MatchThreshold',80);
    MatchDescrip1 = index_pairs(:, 1);
    MatchDescrip2 = index_pairs(:, 2);
    matched_pts1 = valid_points1(MatchDescrip1,:);
    matched_pts2 = valid_points2(MatchDescrip2,:);
    
%     Trackers = features2(MatchDescrip2,:);
    figure(2);
    showMatchedFeatures(vSurfSub{Idx-1},vSurfSub{Idx},matched_pts1,matched_pts2,'montage');
    drawnow;
end
end



