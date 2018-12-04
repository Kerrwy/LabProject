function [THs,V]  = getThStats(Ts,V0,dt,use_single_exponential,lut1,lut2)

% disp('getting Th stats...');

V = edInteg (Ts,V0,dt,use_single_exponential,lut1,lut2);
% THs = max(V)*0.3;
THs = mean(V);


    