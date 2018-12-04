function [ Location, Count ] = EventClusterAlgorithm_firstROI(yi, xi, Lw, Lh, vSurfON, vSurfT, col_min, row_min) 
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

TimeThreshold = 5;
DistanceThreshold = 4;
EffectiveEventsNum = 60;

EvetsBinary = vSurfON(round(yi-Lh/2+1):round(yi+Lh/2), round(xi-Lw/2+1):round(xi+Lw/2));
if ~any(EvetsBinary(:))
%     disp("Local scale all zeros ...");
    Location=[]; Count=0;
    return;
else
    EvetsTime = vSurfT(round(yi-Lh/2+1):round(yi+Lh/2), round(xi-Lw/2+1):round(xi+Lw/2));
    [Evety, Evetx] = find(EvetsBinary~=0);
    len = length(Evetx);
    if len<EffectiveEventsNum
%         disp("Events not enough ...");
        Location=[]; Count=0;
        return;
    end
    EvetsTime(EvetsBinary==0)=0;
    E = EvetsTime(EvetsBinary~=0);
    [~, F, C] = mode(E(:));  % Looking for the most time
    RepreTSI = C{1,1};
    k = 1;
    Location = zeros(length(Evetx), 2);
    
%     for j = 1:length(RepreTSI)
%             [RepreTy, RepreTx] = find(EvetsTime == RepreTSI(j));
%             Locationx = RepreTx + xi-Lw/2;
%             Locationy = RepreTy + yi-Lh/2;
%     end
%     Location = [Locationx, Locationy];

    for i = 1:len
        for j = 1:length(RepreTSI)
            [RepreTy, RepreTx] = find(EvetsTime == RepreTSI(j));
            TimeDiff = EvetsTime(Evety(i), Evetx(i))-RepreTSI(j);
            if TimeDiff<TimeThreshold &&...
               (dist([Evety(i), Evetx(i)], [RepreTy(round(F/2)), RepreTx(round(F/2))]')<DistanceThreshold)
                Location(k,1) = Evetx(i)+xi-round(Lw/2);
                Location(k,2) = Evety(i)+yi-round(Lh/2);
                Location(k,3) = EvetsTime(Evety(i), Evetx(i));
                k = k+1;
            end
        end
    end
    Location(all(Location==0,2),:)=[];
    Location(:,1) = Location(:,1)+row_min;
    Location(:,2) = Location(:,2)+col_min;
end
Count = size(Location, 1);
end

