function createNewTracks(outMetrix, outCorr, Idx, UnassignedDetections)

global tracks nextId

for i = 1:length(UnassignedDetections)
    DetectionID = UnassignedDetections(i);
    location = outCorr(DetectionID, :);
    object = outMetrix{DetectionID};
   
    % Create a new track.
    newTrack = struct(...
        'id', nextId, ...
        'object', object, ...
        'location', location, ...
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