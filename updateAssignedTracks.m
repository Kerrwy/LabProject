function updateAssignedTracks(Assignments, outMetrix, outCorr,Idx)

global tracks
numAssignedTracks = size(Assignments, 1);
% Assignments第一行检测器，第二行跟踪器
for j = 1:numAssignedTracks
    Indx = Assignments(j, 2);   
    detectionIdx = Assignments(j,1);
    object = outMetrix{detectionIdx};
    location = outCorr(detectionIdx, :);
    % Correct the estimate of the object's location using the new detection.
%     correct(tracks(Indx).kalmanFilter, corr);
    
    % Replace
    tracks(Indx).object = object;
    tracks(Indx).location = location;
    tracks(Indx).frame = Idx;
    
    % Update track's age.
    tracks(Indx).age = tracks(Indx).age + 1;
    
    % Update visibility.
    tracks(Indx).totalVisibleCount = ...
        tracks(Indx).totalVisibleCount + 1;
    tracks(Indx).consecutiveInvisibleCount = 0;
    
end
end