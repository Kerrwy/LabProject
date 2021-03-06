function [velEvents] = calcVelocity(allEvents,N,epsilon,mu,REG_ON,SHOW_PLOT, V0, lut1, lut2, dt, THs)
%
% [velEvents] = calcVelocity(allEvents,N,epsilon,mu,dt,SHOW_PLOT)
%
% [Input]:
% allEvents:    [x,y,p,t] matrix containing address-events from DVS
% N:            Local Window Size NxN
% epsilon:      RANSAC estimated fraction of outliers [0,1]
% mu:           RANSAC distance threshold
% REG_ON:       Regularization ON (1) or OFF (0)
% SHOW_PLOT:    {0,1} boolean to show plot during algorithm
%
% [Output]:
% velEvents:    [x,y,p,t,vx,vy,t_disp,t_e]
% vx,vy:        Velocity-components of incoming event in [pixel/mus]
% t_disp:       Display time, based on velocity of incoming event in [mus]
% t_e:        	Time prediction error for incoming event
%
% This function calculates the velocity components and display time of
% events from the matrix allEvents. allEvents is generated using the
% file loadEvents.m and contains x,y,p,t of each event.
%
% These events are split up by polarity {-1,1} and processed separately.
% Assuming local constant velocity, the planar velocity v = [vx vy] of each
% event is calculated in [pixel/mus] and therefore, the display time of a
% pixel is 1/|v| [mus].

clc;
global IMAGE_FRAME surfNeg  surfPos theta_estimatedNeg  theta_estimatedPos t_estimatedNeg t_estimatedPos LIFmat surface
% N == odd number!
if(mod(N,2) == 0)
    disp('Error: N must be an odd number')
    return;
end

% set time to be relative -> starting at t=0
% allEvents(:,4) = allEvents(:,4)-allEvents(1,4);

last = length(allEvents(:,4)); % index of last event
velEvents = zeros(last,8); % extended event data with velocity
velEvents(:,1:4) = allEvents;
show_vel = true;
Tjin = 1e3;
Delta = 2000;
localScale = 5;

% ues for save every event potential, if this pixel's event fire, it can be
% calculate vx,vy。
for i = 1:last % loop trough input data
    x = allEvents(i,1)+1;
    y = allEvents(i,2)+1;
    p = allEvents(i,3);
    t = allEvents(i,4);
    
%     %     % 某个位置的神经元发放脉冲后进入不应期，该位置邻域内的运动矢量在不应期时保持不变。
%     y1 = max(1, y-floor(localScale/2));
%     y2 = min(IMAGE_FRAME(1), y+floor(localScale/2));
%     x1 = max(1, x-floor(localScale/2));
%     x2 = min(IMAGE_FRAME(2), x+floor(localScale/2));
%     
% %     isFire = find(LIFmat(y1: y2, x1: x2) >= -V0 & LIFmat(y1: y2, x1: x2)<0, 1);    %%%%%%等于-V0不代表求出了速度！！！！！！！！！！，因为阈值的设置使得每一个到来的事件都>=THs
% %     if ~isempty(isFire)
%         scaleTs = surface(y1: y2, x1: x2);
%         scaleTs = sort(scaleTs(:));
%         j = scaleTs(end);   % 该时间可能是很早之前的时间
%         first = max(1,i-50);
%         indI = find(allEvents(first:i-1,4) == j);
%         if ~isempty(indI)
%             indI = indI(end);
%             indI = indI-1+first;
%             if velEvents(indI,5)~=0
%                 velEvents(i,5) = velEvents(indI,5);
%                 velEvents(i,6) = velEvents(indI,6);
%                 velEvents(i,7) = velEvents(indI,7);
%                 velEvents(i,8) = 0;
%             end
%         end
% %     end
    
    
    delta = t-surface(y,x);
    positionPotential = LIFposition_Integ(delta,V0,dt,lut1,lut2,LIFmat(y,x)); % 每个位置神经元计算膜电压
    LIFmat(y,x) = positionPotential;
    surface(y,x) = t;
    
    %% Positive Events
    if(p == -1)
        surfPos(y,x) = t; % assign incoming event to positive SAE
        if positionPotential>THs
            LIFmat(y,x) = -V0;
            %             LIFmat(y,x) = 0;
            
            % check if pixel in imageFrame, depending on window size N
            if(((IMAGE_FRAME(1)-floor(N/2)>=y) && (y>=ceil(N/2))) && ((IMAGE_FRAME(2)-floor(N/2)>=x) && (x>=ceil(N/2))) && velEvents(i,5)==0)
                % read out local NxN surface window
                data = surfPos((y-floor(N/2)):(y+floor(N/2)),...
                    (x-floor(N/2)):(x+floor(N/2)));
                % read predicted time and theta at incoming events' position (x,y)
                theta_prior = [theta_estimatedPos(y,x,1);...
                    theta_estimatedPos(y,x,2);...
                    theta_estimatedPos(y,x,3)];
                t_est = t_estimatedPos(y,x);
                % estimate local plane normal theta
                [theta,flag] = fitPlane(data,theta_prior,t_est,epsilon,mu,REG_ON,SHOW_PLOT);
                
                if(flag) % if theta found
%                     tic;
%                     minNegTs = min(surfPos(surfPos>0));
%                     surfPos(surfPos == minNegTs) = 0;
%                     toc;

                    % choose sign of normal s.t. it shows in positive z-direction
                    theta = sign(theta(3))*theta;
                    a = theta(1);
                    b = theta(2);
                    c = theta(3);
                    % calculate velocity components and display time
                    vx = c*(-a)/(a^2+b^2);
                    vy = c*(-b)/(a^2+b^2);
                    t_disp = sqrt(a^2+b^2)/c;
                    velEvents(i,5) = vx;
                    velEvents(i,6) = vy;
                    velEvents(i,7) = t_disp;
                    if(t_est ~= 0)  % if prediction available at this location
                        velEvents(i,8) = t-t_est;   % time prediction error t_e
                    else
                        velEvents(i,8) = 0;
                    end
                else % if not enough inliers found (flag = 0): theta = [0;0;1]
                    vx = 0;
                    vy = 0;
                    velEvents(i,5) = 0;  % v_x
                    velEvents(i,6) = 0;  % v_y
                    velEvents(i,7) = 0;  % t_disp
                    velEvents(i,8) = 0;  % t_e
                end
                % predict next pixel
                [x_estimate,y_estimate,theta_estimate,t_estimate] = calcNormalEstimate(x,y,t,vx,vy,theta);
                theta_estimatedPos(y_estimate,x_estimate,1:3) = theta_estimate;
                t_estimatedPos(y_estimate,x_estimate) = t_estimate;
            end
        end
    end
    
    %% Negative Events
    if(p == 1)
        surfNeg(y,x) = t; % assign incoming event to negative SAE
        if positionPotential>THs
            LIFmat(y,x) = -V0;
            %             LIFmat(y,x) = 0;
            
            % check if pixel in imageFrame, depending on window size N
            if(((IMAGE_FRAME(1)-floor(N/2)>=y) && (y>=ceil(N/2))) && ((IMAGE_FRAME(2)-floor(N/2)>=x) && (x>=ceil(N/2))) && velEvents(i,5)==0)
                % read out local NxN surface window
                data = surfNeg((y-floor(N/2)):(y+floor(N/2)),...
                    (x-floor(N/2)):(x+floor(N/2)));
                % read predicted time and theta at incoming events' position (x,y)
                theta_prior = [theta_estimatedNeg(y,x,1);...
                    theta_estimatedNeg(y,x,2);...
                    theta_estimatedNeg(y,x,3)];
                t_est = t_estimatedNeg(y,x);
                % estimate local plane normal theta
                [theta,flag] = fitPlane(data,theta_prior,t_est,epsilon,mu,REG_ON,SHOW_PLOT);
                
                if(flag) % if theta found
%                     minNegTs = min(surfNeg(surfNeg>0));
%                     surfNeg(surfNeg == minNegTs) = 0;

                    % choose sign of normal s.t. it shows in positive z-direction
                    theta = sign(theta(3))*theta;
                    a = theta(1);
                    b = theta(2);
                    c = theta(3);
                    % calculate velocity components and display time
                    vx = c*(-a)/(a^2+b^2);
                    vy = c*(-b)/(a^2+b^2);
                    t_disp = sqrt(a^2+b^2)/c;
                    velEvents(i,5) = vx;
                    velEvents(i,6) = vy;
                    velEvents(i,7) = t_disp;
                    if(t_est ~= 0) % if prediction available at this location
                        velEvents(i,8) = t-t_est;  % time prediction error t_e
                    else
                        velEvents(i,8) = 0;
                    end
                else % if not enough inliers found (flag = 0): theta = [0;0;1]
                    vx = 0;
                    vy = 0;
                    velEvents(i,5) = 0; % v_x
                    velEvents(i,6) = 0; % v_y
                    velEvents(i,7) = 0; % t_disp
                    velEvents(i,8) = 0; % t_e
                end
                % predict next pixel
                [x_estimate,y_estimate,theta_estimate,t_estimate] = calcNormalEstimate(x,y,t,vx,vy,theta);
                theta_estimatedNeg(y_estimate,x_estimate,1:3) = theta_estimate;
                t_estimatedNeg(y_estimate,x_estimate) = t_estimate;
            end
        end
    end
    
    
    % display progress in command window every 100 events
    if mod(i, Delta) == 0
        disp([num2str(round(100/last*i)) ' / 100%           (' num2str(i) ' / ' num2str(last) ')']);
        disp(['DVS记录时间'   num2str((t-allEvents(i-Delta+1,4))/10^6) 's']);
        %         toc;
        if find(velEvents(i-Delta+1:i,5)~=0)
            dispOutput_filter(velEvents(i-Delta+1:i,:), show_vel, -1, Tjin);
            %             dispOutput(velEvents(i-Delta+1:i,:), show_vel);
            %             dispOutputByTime(velEvents(i-Delta+1:i,:), show_vel, Tjin, t/Tjin);
        end
    end
    
    %     if (mod(round(t/Tjin),10)==0  && t~=velEvents(i+1,4) && t~=velEvents(end,4)) % 每10ms可视化一次,但是可能多个时间都对应10ms
    %         disp([num2str(round(t/Tjin)) 's' ' / ' num2str(round(velEvents(end,4)/Tjin)) 's']);
    %         ind = (velEvents(:,4)/Tjin>=(round(t/Tjin)-10) & velEvents(:,4)/Tjin<round(t/Tjin));
    %         if find(velEvents(ind, 5)~=0)
    %             dispOutputByTime(velEvents(ind,:), show_vel, Tjin, t/Tjin);
    %         end
    %     end
end
