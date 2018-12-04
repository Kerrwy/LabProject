function [ tout ] = getExactEvtTime( ts, tin )
%GETEXACTEVTTIME 
% after peak detection, we get a set of timings. However these timings may not
% be exactly coincident with exact event timings, this function will get exact
% event timing from those approximate timings.

n = length(tin);
tout = zeros(size(tin));

for i = 1:n
    a = tin(i);    
    e = find(ts==a);
    if ~isempty(e)
        ind = e;
    elseif a>ts(end)   
        ind = length(ts); 
    else
        ind = find( (ts(1:end-1)<a) & (ts(2:end)>a) ) ;
    end    
    tout(i) = ts(ind);
end
end

