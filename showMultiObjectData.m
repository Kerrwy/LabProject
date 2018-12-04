function showMultiObjectData( Events )
% Show multiple tennis object original frame.
%   
%     Parameters:
%         Events: Input data.

global Width Height
Delta = 6e4;
img = zeros(Height, Width);
tic;
for i=Delta:Delta:length(Events.x)
    y = Height - Events.y(i-Delta+1:i)+1;
    x = Events.x(i-Delta+1:i);
    a = Events.ts(i-Delta+1:i);    
    for j=1:Delta
        img(y(j),x(j)) = a(j);
    end
    imshow(img);
    img = zeros(Height, Width);
    drawnow;
end
toc;
end


% %% Ò»¡¢Data Prepare
% close all;clc;clear;clear global;
% Width = 768;
% Height = 640;
% Events = importdata('Crop2ren2bian_continus.mat');
% % Events = DataPreprocessing('Crop2ren2bian.mat');
% 
% %% Initial Parameters, you may change according to your needs.
% N = 60000;
% len = length(Events.x);
% vSurfSum = zeros(Height, Width);
% vSurfSub = cell(1, ceil(len/N));
% for j=1:ceil(len/N)
%     vSurfSub{j} = vSurfSum;
% end
% 
% %% ¶þ¡¢Multiple object events operating.
% tic;
% fprintf("Start calculating effective points...\n");
% for i = 1:len
%     xi = Events.x(i);
%     yi = Events.y(i);
%     Idx = ceil(i/N);
%     vSurfSub{Idx}(yi, xi) = 1;
%     if(rem(i, N)==0)
%         disp([ '------' int2str( i / len * 100 ) '% effective event points of whole objects motion flow done.']);
%         Visualiz(vSurfSub{Idx});
%     end
% end


