function Events = DataPreprocessing(EventsPath)
% function [ denoisedEvents ] = DataPreprocessing(EventsPath)
% 
% Cutting local data，save the standard form.
%
%     Parameters:
%         EventsPath: Load local data.
%     Return:
%          Events：Cutted the multiple object denoised data phase.

%% Ordered ts
Event = importdata(EventsPath);
Event = Event(1: 5000000,:);
Events.x = Event(:,1);
Events.y = Event(:,2);
Events.ts = Event(:,3);
Events.poli = Event(:,4);

tsCopy = Events.ts;
j = 2;
Events.ts(1) = 1;
for i = 2:length(Events.ts)
    if Events.ts(i)==tsCopy(i-1)
        Events.ts(i)=Events.ts(i-1);
    else
        Events.ts(i)=j;
        j=j+1;
    end
end
clear tsCopy
Events.x = Events.x+1;
Events.y = Events.y+1;
disp("Time continuous.");

% %% Denoised
% eventDelta = 50000;
% global Width Height
% len=length(Events.x);
% denoisedImg=zeros(Height,Width);
% denoisedEvents.x = [];
% denoisedEvents.y = [];
% denoisedEvents.ts = [];
% heatMap=zeros(Height,Width);
% 
% imgIndex=1;
% stopNum=fix(len/eventDelta);      % fix(x)：向0取整（也可以理解为向中间取整）
% eventsXBuffer=zeros(1,eventDelta,'uint16');
% eventsYBuffer=zeros(1,eventDelta,'uint16');
% eventsTsBuffer=zeros(1,eventDelta,'uint64');
% 
% fprintf('Start denoing...\n')
% while (imgIndex<=stopNum)
%     startEventIndex=(imgIndex-1)*eventDelta+1;
%     stopEventIndex=imgIndex*eventDelta;
%     eventsXBuffer(:)=Events.x(startEventIndex:stopEventIndex);
%     eventsYBuffer(:)=Events.y(startEventIndex:stopEventIndex);
%     eventsTsBuffer(:)=Events.ts(startEventIndex:stopEventIndex);
%     eventIndex=1;
%     while eventIndex<=eventDelta
%         row=eventsYBuffer(eventIndex);
%         col=eventsXBuffer(eventIndex);
%         denoisedImg(row,col)=eventsTsBuffer(eventIndex);
%         heatMap(row,col)=heatMap(row,col)+1;
%         eventIndex=eventIndex+1;
%     end
%     weightMap=getWeightMap(heatMap);
%     denoisedImg=denoisedImg.*weightMap;
%     [Ts, idx] = sort(denoisedImg(:),'ascend');
%     RealTs = find(Ts~=0);
%     idx=idx(RealTs);
%     denoisedEvents.ts = cat(1, denoisedEvents.ts, Ts(RealTs));
%     denoisedEvents.y = cat(1, denoisedEvents.y, mod(idx,Height));
%     denoisedEvents.x = cat(1, denoisedEvents.x, ceil(idx/Height));
%     denoisedImg(:)=0;
%     heatMap(:)=0;
%     imgIndex=imgIndex+1;
% end
% fprintf('Finished denoing.\n')
% end
% 
% function [weightMap]=getWeightMap(heatMap)
% thresh=sum(heatMap(:))/sum(heatMap(:)>0);
% if thresh<2
%     thresh=2;
% else
%     thresh=fix(thresh);
% end
% weightMap=heatMap>=thresh;
% end


