% function createFirstTracks(location, match_idx1, nextId)
function createFirstTracks(outMetrix, outCorr,  Idx)
% Create tracks with matched points.
%

global tracks nextId
len = length(outMetrix);
for i = 1:len
    object = outMetrix{i};
    location = outCorr(i, :);
    % Create a new track.
    newTrack = struct(...
        'id',  nextId, ...
        'object',object, ...
        'location',location, ...
        'frame', Idx, ...
        'age', 1, ...
        'totalVisibleCount', 1, ...
        'consecutiveInvisibleCount', 0);    
    
    % Add it to the array of tracks.
    tracks(end + 1) = newTrack;    
    % Increment the next id.
    nextId = nextId + 1;
end
end