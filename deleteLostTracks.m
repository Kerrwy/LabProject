function deleteLostTracks

global tracks
invisibleForTooLong = 4;% 已经是轨迹的，连续5次都没有出现目标了。
ageThreshold = 5;% 轨迹更新了5次，匹配到的比率还不到0.6

% Compute the fraction of the track's age for which it was visible.
ages = [tracks(:).age];   % 检测帧数
totalVisibleCounts = [tracks(:).totalVisibleCount];  % 检测匹配轨迹数
visibility = totalVisibleCounts ./ ages;  % 每更新一次（updateAssignedTracks）,所有轨迹age+1，匹配到的轨迹totalVisibleCount+1，没匹配到的轨迹consecutiveInvisibleCount+1.

% Find the indices of 'lost' tracks.
lostInds = (ages < ageThreshold & visibility < 0.6) | ...
    [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

% Delete lost tracks.
tracks = tracks(~lostInds);
end