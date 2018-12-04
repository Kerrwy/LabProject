function [vx, vy] = singleFit(A)
%
% --input
%       A: include local plane accordinate and timestamp, 3*localSize
%       [x+i,y+i,t];   t = lastTimesMap[x + i][y + i][type];
%       i = -searchDistance : searchDistance.

% here, we will not need to calculate t_disp, only vx and vy.

localSize = size(A,2);
forthDimension = ones(1,localSize);
neighborhood = cat(1, A, forthDimension); % 要过滤掉far away的时间

if (localSize < 3)  % 此处3指的是算上邻域总共有3个像素; 如果邻域大小是7*7，则localSize = size(neighborhood,2)=49.
    vx = 0;
    vy = 0;
    return;
end
sx2 = 0;
sy2 = 0;
st2 = 0;
sxy = 0;
sxt = 0;
syt = 0;
sxx = 0;
syy = 0;
stt = 0;
th3 = 1e-3;

for i=1:localSize
    sx2 = sx2 + neighborhood(1,i)*neighborhood(1,i);
    sy2 = sy2 + neighborhood(2,i)*neighborhood(2,i);
    st2 = st2 + neighborhood(3,i)*neighborhood(3,i);
    sxy = sxy + neighborhood(1,i)*neighborhood(2,i);
    sxt = sxt + neighborhood(1,i)*neighborhood(3,i);
    syt = syt + neighborhood(2,i)*neighborhood(3,i);
    sxx = sxx + neighborhood(1,i);
    syy = syy + neighborhood(2,i);
    stt = stt + neighborhood(3,i);
end

if (sx2 * sy2 * st2 + 2 * sxy * sxt * syt - sxt * sxt * sy2 - sx2 * syt * syt - sxy * sxy * st2 == 0)
    vx = 0;
    vy = 0;
    return;
end
theta(1) = sxx * (syt * syt - sy2 * st2) + syy * (sxy * st2 - sxt * syt) + stt * (sxt * sy2 - sxy * syt);
theta(2) = sxx * (sxy * st2 - syt * sxt) + syy * (sxt * sxt - sx2 * st2) + stt * (sx2 * syt - sxy * sxt);
theta(3) = sxx * (sxt * sy2 - sxy * syt) + syy * (sx2 * syt - sxy * sxt) + stt * (sxy * sxy - sx2 * sy2);
tmp = -theta(3)/(power(theta(1),2)+power(theta(2),2));
vx = theta(1) * tmp;
vy = theta(2) * tmp;

