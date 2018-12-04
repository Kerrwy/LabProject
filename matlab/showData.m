Width=240;
Height=180;
Delta = 1e3;
img = zeros(Height, Width, 3);
tic;
Y = events(:,2);
X = events(:,1);
P = events(:,3);
for i=Delta:Delta:length(events(:,1))
y = Y(i-Delta+1:i)+1;
x = X(i-Delta+1:i)+1;
p = P(i-Delta+1:i);
for j=1:Delta
if p(j)==1
img(y(j),x(j),1) = 1;
elseif p(j)==-1
img(y(j),x(j),2) = 1;
end
end
imshow(img);
img = zeros(Height, Width,3);
drawnow;
end
toc;