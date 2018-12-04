function dispOutputByTime(velEvents, SHOW_VELOCITY, Tjin, i)
%
% dispOutput(velEvents,SHOW_PLOT)
%
% [Input]:
% velEvents:        [x,y,p,t,vx,vy,t_disp,t_e]
%                   data matrix calculated with calcVelocity.m
% SHOW_VELOCITY:    {0,1} boolean to display velocity vectors in movie
% Tjin:              change time to ms.

%
% This function  creates a movie based on the data in the matrix velEvents.
% This data is generated using the function calcVelocity.m For the movies,
% the incoming events are accumulated over a time interval of 1ms and
% display using a framerate of 100 fps, i.e. the movie is 10x slower than
% real-time. The Frames are displayed in a figure and captured for the
% movie.

global IMAGE_FRAME timemat colormat velocitymat showmat
iptsetpref('ImshowBorder','tight'); % remove borders around figure
s = 5e+04; % scale factor for quiver(¼ýÍ·) plot


% set time to be relative -> starting at t=0
% velEvents(:,4) = velEvents(:,4)-velEvents(1,4);


velEvents(:,4) = ceil(velEvents(:,4)./Tjin); % round data to ms
velEvents(:,7) = ceil(velEvents(:,7)./Tjin);

%% event-based full frame visualization algorithm
tmp = velEvents;
for l = 1:length(tmp(:,4)) % loop through these events and fill matrices
    x = tmp(l,1)+1;
    y = tmp(l,2)+1;
    vx = tmp(l,5);
    vy = tmp(l,6);
    t_disp = tmp(l,7);
    showmat(y,x) = tmp(l,4);
    
    timemat(y,x) = t_disp; % assign integration time to event
    colormat(y,x) = t_disp; % assign color value to event
    velocitymat(y,x,1) = vx; % x velocity
    velocitymat(y,x,2) = vy; % y velocity
    % calculate global position of pixel in negative direction of motion
    %             [x_parent,y_parent,t_parent] = deleteParent(x,y,vx,vy,t_disp);  % Edge Thinning??
    %             % reset pixel in negative direction of motion
    %             timemat(y_parent,x_parent) = t_parent;
end
image = logical((timemat)).*colormat;
if(SHOW_VELOCITY) % calculate velocity vectors
    %             xvelocitymat = logical((timemat)).*velocitymat(:,:,1);
    %             yvelocitymat = logical((timemat)).*velocitymat(:,:,2);
    xvelocitymat = velocitymat(:,:,1);
    yvelocitymat = velocitymat(:,:,2);
    xvel = reshape(xvelocitymat,1,IMAGE_FRAME(1)*IMAGE_FRAME(2));
    yvel = reshape(yvelocitymat,1,IMAGE_FRAME(1)*IMAGE_FRAME(2));
    
    % chang here
    flag = reshape(timemat,1,IMAGE_FRAME(1)*IMAGE_FRAME(2));
    
    A = zeros(5,IMAGE_FRAME(1)*IMAGE_FRAME(2));
    [A(2,:), A(1,:)] = ind2sub([IMAGE_FRAME(1),IMAGE_FRAME(2)],1:IMAGE_FRAME(1)*IMAGE_FRAME(2));
    A(3,:) = xvel;
    A(4,:) = yvel;
    A(5,:) = flag;
    A(:,A(5,:)==0) = [];
end

angle = zeros(1,size(A,2));
for jj=1:size(A,2)
    if A(3,jj)==0
        angle(jj) = NaN;
    else
        angle(jj) = atan(A(4,jj)/A(3,jj))*180/pi;
    end
end
truthAngle = [0, 45, 90];
truthColor = ['c', 'b', 'r', 'm', 'g', 'f', 'y', 'w'];
ind1 = find(A(3,:)>0 & A(4,:)<0);
ind2 = find(A(3,:)<0 & A(4,:)<0);
ind3 = find(A(3,:)<0 & A(4,:)>0);
ind4 = find(A(3,:)>0 & A(4,:)>0);
ind = {ind1,ind2,ind3,ind4};


figure(1);
image = imresize(image,3,'method','nearest');
imshow(image);

% showmat = imresize(showmat,3,'method','nearest');
% imshow(showmat);
hold on;
% write image to figure
for aa=1:length(ind)
    sub_angle = angle(ind{1,aa});
    A_ = A(:,ind{1,aa});
    sub_angle = abs(sub_angle);
    index1 = find(sub_angle>=truthAngle(1) & sub_angle<truthAngle(2));
    scale = 0;
    quiver(3*(A_(1,index1)),3*(A_(2,index1)),s*A_(3,index1),s*A_(4,index1),scale,truthColor(aa*2-1));
    index2 = find(sub_angle>=truthAngle(2) & sub_angle<truthAngle(3));
    quiver(3*(A_(1,index2)),3*(A_(2,index2)),s*A_(3,index2),s*A_(4,index2),scale,truthColor(aa*2));
end
text(10,10,[num2str(i) ' ms '],'Color','g')
hold off;
drawnow;
timemat = timemat-10; % decrease integration time by 1ms
timemat(timemat<0) = 0; % no negative times
end

