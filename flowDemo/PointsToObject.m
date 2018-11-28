function [ outMetrix, outCorr, objectCorr] = PointsToObject( Location, vSurfGray )
% function [ outMetrix, outCorr, ID ] = PointsToObject2( Location, vSurfGray )
% Convert overlapping feature points to a single target.
%
% Parameter:
%       X: Matched feature points x-coordination.
%       Y: Matched feature points y_coordination.

if isempty(Location)
    outMetrix=[];
    outCorr=[];
    return;
end
global DistanceThreshold

X=Location(:,1);
Y=Location(:,2);
Ts=Location(:,3);
len = length(X);
i = 1;
DistanceThreshold = 100;
while i<=len
    objectCorr{i} = [X(i),Y(i),Ts(i)];
    for j=i+1:len         
        Dis = dist([X(i), Y(i)], [X(j), Y(j)]');
        if(Dis<DistanceThreshold)
            temp = objectCorr{i};
            objectCorr{i} = [];
            temp = [temp,[X(j), Y(j), Ts(j)]]; 
            objectCorr{i} = temp;
            X(j)=0; Y(j)=0; Ts(j)=0;
        end
    end
%     ID(i) = i;
    X(X==0)=[]; Y(Y==0)=[]; Ts(Ts==0)=[];
    i = i+1;
    len = length(X);   
end

outCorr = ObjectScale(objectCorr);
lens = length(objectCorr);
for j=1:lens
    objectCorr{j} = transpose(reshape(objectCorr{j},3,[]));
end
    
    
len = size(outCorr,1);
outMetrix = cell(1,len);
I = vSurfGray;
for i =1:len    
        outMetrix{i} = I(outCorr(i,3):outCorr(i,4), outCorr(i,1):outCorr(i,2));
end
            
            


      


