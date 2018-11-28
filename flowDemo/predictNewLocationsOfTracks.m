function predictNewLocationsOfTracks

global tracks
for i = 1:length(tracks)
    % Predict the current location of the track.
    location = predict(tracks(i).kalmanFilter);
    tracks(i).location = location;
end
end