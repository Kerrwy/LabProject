function [ tpeak ]=FindPeak(V,t,Radius,th)

N = length(V);
indPeak = zeros(1,N);
tpeak = zeros(1,N);
cnt = 0;
i=1;
while i<=N
    
    % There are chances that two or more even peaks happen within the search range.
    % only select the first one. So that selected slices will have enough
    % space with each other.
    
    if V(i)>=th       
        range = max(1,i-Radius) : min(i+Radius, N);
        [vmax,ind] = max(V(range));
        ind = max(1,i-Radius)-1+ ind(1);

        if ind==i   % peak
            cnt = cnt+1; 
            tpeak(cnt) = t(i);
            indPeak(cnt) = i;           
            i = i+Radius;   % jump forward to out of the range of the current peak
            continue;          
        elseif ind>i              
            i = ind;    % jump forward
            continue;
        end
    end   
    i = i+1;    % step forward
end

indPeak = indPeak(1:cnt);
tpeak = tpeak(1:cnt);

