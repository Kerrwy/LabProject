function updateUnassignedTracks(unassignedTracks)

global tracks
for i = 1:length(unassignedTracks)
    Indx = unassignedTracks(i);
    tracks(Indx).age = tracks(Indx).age + 1;
    tracks(Indx).consecutiveInvisibleCount = ...
        tracks(Indx).consecutiveInvisibleCount + 1;
end
end