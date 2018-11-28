function [ Location, Count, vSurfON ] = EventClusterAlgorithm(yi, xi, Lw, Lh, vSurfON, vSurfT)
% Cluster events according to time and disdance.
%
%   Parameters:
%       yi: Input event y-coordinate.
%       xi: Inpur event x-coordinate.
%       Lw: Scale width.
%       Lh; Scale height.
%       vSurfON: Scale binary values.
%       vSurfT: Scale time value.
%   Return:
%       Points: Cluster eventpoints coordinate.

TimeThreshold = 20;
DistanceThreshold = 10;
EffectiveEventsNum = 160;

EvetsBinary = vSurfON(yi-Lh/2+1:yi+Lh/2, xi-Lw/2+1:xi+Lw/2);

EvetsTime = vSurfT(yi-Lh/2+1:yi+Lh/2, xi-Lw/2+1:xi+Lw/2);
[Evety, Evetx] = find(EvetsBinary~=0);
len = length(Evetx);
if len<EffectiveEventsNum
    vSurfON(yi-Lh/2+1:yi+Lh/2, xi-Lw/2+1:xi+Lw/2)=0;     % Õâ¿éºÜÂý
    Location=[]; Count=0;
    return;
end
EvetsTime(EvetsBinary==0)=0;
E = EvetsTime(EvetsBinary~=0);
[~, F, C] = mode(E(:));  % Looking for the most time
RepreTSI = C{1,1};
k = 1;
Location = zeros(length(Evetx), 2);

for i = 1:len
    for j = 1:length(RepreTSI)
        [RepreTy, RepreTx] = find(EvetsTime == RepreTSI(j));
        TimeDiff = EvetsTime(Evety(i), Evetx(i))-RepreTSI(j);
        if TimeDiff<TimeThreshold &&...
                (dist([Evety(i), Evetx(i)], [RepreTy(round(F/2)), RepreTx(round(F/2))]')<DistanceThreshold)
            Location(k,1) = Evetx(i)+xi-Lw/2;
            Location(k,2) = Evety(i)+yi-Lh/2;
            k = k+1;
        end
    end
end
Location(all(Location==0,2),:)=[];
Count = size(Location, 1);
end

