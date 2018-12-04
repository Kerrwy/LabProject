function dispOutput_filter(velEvents, SHOW_VELOCITY, dt, Tjin)
%
% dispOutput(velEvents,SHOW_PLOT)
%
% [Input]:
% velEvents:        [x,y,p,t,vx,vy,t_disp,t_e]
%                   data matrix calculated with calcVelocity.m
% SHOW_VELOCITY:    {0,1} boolean to display velocity vectors in movie
% dt:               time interval [ms] for visualization,
%                   negative value for lifetime
% filename:         filename without extension
% cmax:             visualization parameter
%
%
% This function  creates a movie based on the data in the matrix velEvents.
% This data is generated using the function calcVelocity.m For the movies,
% the incoming events are accumulated over a time interval of 1ms and
% display using a framerate of 100 fps, i.e. the movie is 10x slower than
% real-time. The Frames are displayed in a figure and captured for the
% movie.

global IMAGE_FRAME

% set time to be relative -> starting at t=0
% velEvents(:,4) = velEvents(:,4)-velEvents(1,4);

timemat = zeros(IMAGE_FRAME); % initialize display time matrix
colormat = zeros(IMAGE_FRAME); % initialize color matrix
velocitymat = zeros(IMAGE_FRAME(1),IMAGE_FRAME(2),3); % initialize velocity vector matrix
showmat = zeros(IMAGE_FRAME);
velEvents(:,4) = ceil(velEvents(:,4)./Tjin); % round data to ms
velEvents(:,7) = ceil(velEvents(:,7)./Tjin);
firstTime = velEvents(1, 4);
endTime = velEvents(end, 4);

%% event-based full frame visualization algorithm
if(dt < 0)
    tmp = velEvents;
    ind = (tmp(:,4)>=firstTime & tmp(:,4)<endTime);
    tmp = tmp(ind,:); % only take events at this particular time-stamp
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
    end

    if(SHOW_VELOCITY) % calculate velocity vectors
        xvelocitymat = velocitymat(:,:,1);
        yvelocitymat = velocitymat(:,:,2);
        xvel = reshape(xvelocitymat,1,IMAGE_FRAME(1)*IMAGE_FRAME(2));
        yvel = reshape(yvelocitymat,1,IMAGE_FRAME(1)*IMAGE_FRAME(2));
        
        % chang here
%         flag = reshape(timemat,1,IMAGE_FRAME(1)*IMAGE_FRAME(2));      
        flag = xvel;    
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

    truthColor = ['r', 'c', 'g', 'y'];
    ind1 = find(A(3,:)>0 & A(4,:)<0);
    ind2 = find(A(3,:)<0 & A(4,:)<0);
    ind3 = find(A(3,:)<0 & A(4,:)>0);
    ind4 = find(A(3,:)>0 & A(4,:)>0);
    ind = {ind1,ind2,ind3,ind4};
    
    figure(1);
    imshow(showmat);
    hold on;
    % write image to figure
    for aa=1:length(ind)
        sub_angle = angle(ind{1,aa});
        A_ = A(:,ind{1,aa});
        if isempty(A_) %|| length(A_)<size(A,2)/8)
            continue;
        end
        A_(10,:) = abs(sub_angle);
        % 基于概率的滤波方法
        A_trans = A_';
        A_trans(:,6) = sqrt((A_trans(:,3).*A_trans(:,3))+(A_trans(:,4).*A_trans(:,4)));
        sortA_trans = sortrows(A_trans,6);
        len = size(sortA_trans,1);
        fliterlenS = round(len*0.2);  % 滤除10%大的矢量
        sortS = sortA_trans(:,6);
        meanFilterS = mean(sortS(1 : len-fliterlenS));
        mergeS = sort(cat(1, sortS, meanFilterS));
        meanS_index = find(mergeS==meanFilterS);
        meanS_index = meanS_index(1);
        % 生成一维高斯滤波模板
        GaussLength = length(mergeS);
        GaussTemp1 = ones(1,GaussLength);
        GaussTemp2 = ones(1,GaussLength);
        r = meanFilterS;
        sigma1 = max(mergeS);
        sigma2 = min(mergeS);
        for i = 1:GaussLength
           Gausskey = mergeS(i);
           GaussTemp1(i) = exp(-(Gausskey-r)^2/(2*sigma1^2))/(sigma1*sqrt(2*pi));
           GaussTemp2(i) = exp(-(Gausskey-r)^2/(2*sigma2^2))/(sigma2*sqrt(2*pi));
        end
        GaussTemp2(1: meanS_index-1) = GaussTemp2(meanS_index);
        GaussTemp = [GaussTemp2(1: meanS_index-1), GaussTemp2(meanS_index+1: end)];
%         GaussTemp = GaussTemp/sum(GaussTemp);

        sortA_trans(:,7) = sortS.* GaussTemp';
        sortA_trans(:,7) = sortA_trans(:,7)/max(sortA_trans(:,7));          
        sortA_trans(:,8) = sqrt(power(sortA_trans(:,7),2)./(1+power(tan(sortA_trans(:,10)*pi/180),2)));    % vx
        sortA_trans(:,9) = sortA_trans(:,8).*tan(sortA_trans(:,10)*pi/180);                                % vy   
              
        scale = 0;
        switch(aa)
            case 1
                s1 = 1e+01; % scale factor for quiver(箭头) plot
                s2 = -1e+01;    
            case 2
                s1 = -1e+01; 
                s2 = -1e+01; 
            case 3
                s1 = -1e+01; 
                s2 = 1e+01; 
            case 4
                s1 = 1e+01; 
                s2 = 1e+01; 
        end 
%         index1 = find(sortA_trans(:,10)>=truthAngle(1) & sortA_trans(:,10)<=truthAngle(2));
%         quiver(sortA_trans(index1,1),sortA_trans(index1,2),s1*sortA_trans(index1,8),s2*sortA_trans(index1,9),scale,truthColor(aa*2-1));
%         tic;
        quiver(sortA_trans(:,1),sortA_trans(:,2),s1*sortA_trans(:,8),s2*sortA_trans(:,9),scale,truthColor(aa),'LineWidth',1.5,'MaxHeadSize',0.5);

%         plot3（[x1 x2],[y1 y2],[z1 z2]);
%         for pt=1:length(sortA_trans(:,1))
%             plot([sortA_trans(pt,1),sortA_trans(pt,1)+s1*sortA_trans(pt,8)],[sortA_trans(pt,2),sortA_trans(pt,2)+s2*sortA_trans(pt,9)],truthColor(aa),'LineWidth',2);
%         end
%         toc;
        
%         quiver(sortA_trans(:,1),sortA_trans(:,2),s1*sortA_trans(:,8),s2*sortA_trans(:,9),scale,truthColor(aa));
    end
    hold off;
    drawnow;
end
end
