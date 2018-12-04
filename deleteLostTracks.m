function deleteLostTracks

global tracks
invisibleForTooLong = 4;% �Ѿ��ǹ켣�ģ�����5�ζ�û�г���Ŀ���ˡ�
ageThreshold = 5;% �켣������5�Σ�ƥ�䵽�ı��ʻ�����0.6

% Compute the fraction of the track's age for which it was visible.
ages = [tracks(:).age];   % ���֡��
totalVisibleCounts = [tracks(:).totalVisibleCount];  % ���ƥ��켣��
visibility = totalVisibleCounts ./ ages;  % ÿ����һ�Σ�updateAssignedTracks��,���й켣age+1��ƥ�䵽�Ĺ켣totalVisibleCount+1��ûƥ�䵽�Ĺ켣consecutiveInvisibleCount+1.

% Find the indices of 'lost' tracks.
lostInds = (ages < ageThreshold & visibility < 0.6) | ...
    [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

% Delete lost tracks.
tracks = tracks(~lostInds);
end