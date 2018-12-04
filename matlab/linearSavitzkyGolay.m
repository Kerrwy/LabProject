function [vx, vy] = linearSavitzkyGolay(data, x, y)
%
% -- input
%       A: input neighborhood events, 3*localSize
%       we only ues real coordinate and timetamp to calculate theta.
%       The curent event (x,y) corresponds to A median coordinate.

% A先不要去掉时间久远的事件，边计算边去掉。
N = size(data,1);
% create 3x(N^2) matrix with data: A=[x;y;t] for linear model theta'*A=B
dataVector = reshape(data,1,N^2);
A = zeros(3,N^2);
% rows of data patch are y-entries, columns are x-entries
[A(2,:), A(1,:)] = ind2sub([N,N],1:N^2);
A(3,:) = dataVector;
med = max(A(3,:))*9/10;

theta = zeros(1, 2, 3);
ii = 0;
jj = 0;

for i = 1:N
    for j = 1:N
        t1 = data(i,j);
        if t1>=med
            for xx = i+1:N
                t2 = data(x+xx, y+j);
                if t2>=med
                    theta(1) = theta(1)+(t2-t1)/(xx-i);
                    ii = ii +1;
                end
            end
            
            for yy = j+1:N
                t2 = data(x+i, y+yy);
                if(t2>=med)
                    theta(2) = theta(2)+(t2-t1)/(yy-j);
                    jj = jj+1;
                end
            end      
        end
    end
end
if ii==0
    theta(1) = 0;
else
    theta(1) = theat(1)/ii;
end

if jj==0
    theta(2) = 0;
else
    theta(2) = theta(2)/jj;
end
theta(3) = -1;
tmp = -theta(3)/(power(theta(1),2)+power(theta(2),2));
vx = theta(1) * tmp;
vy = theta(2) * tmp;
            




