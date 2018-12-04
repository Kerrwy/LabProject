function [ V ]= LIFposition_Integ (delta_t,V0,dt,lut1,lut2, K1)
% event-driven leaky integration cell

use_single_exponential = 1;
% K1 = 0;
K2 = 0;

lut_addr = round(delta_t /dt)+1;
% disp(lut_addr);
if lut_addr<=length(lut1)
    Sc1 = lut1(lut_addr);
else
    Sc1 = 0;
end
K1 = Sc1*K1;
K1 = K1 + V0;

if ~use_single_exponential
    if lut_addr<=length(lut2)
        Sc2 = lut2(lut_addr);
    else
        Sc2 = 0;
    end
    K2 = Sc2*K2;
    K2 = K2 + V0;
    K = K1-K2;
else
    K = K1;
end
V = K;             % total potential. 
end

