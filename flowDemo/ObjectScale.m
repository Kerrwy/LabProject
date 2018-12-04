function outCorr = ObjectScale(objectCorr)
global Width Height 
scale = 20;
len = length(objectCorr);
outCorr = zeros(len, 4);

for j=1:len
    object = transpose(reshape(objectCorr{j},3,[]));
    x1 = max(1,min(object(:,1))-scale);
    x2 = min(Width, max(object(:,1))+scale);
    y1 = max(1, min(object(:,2))-scale);
    y2 = min(Height,max(object(:,2))+scale);
   outCorr(j,:) = [x1,x2,y1,y2];
end