% Convert Bin files to Mat files, and save.

%% User variables set-up
% close all;clear;clc;
% % general variables
fileDir='D:\chepaishibei';
fileName='Recording_20181016_123843243_E_25MHz.bin';

% Non-user variables set-up
X=768;
Y=640;
bytesPerEvent=4;

displayTime=1e-15;% time for each picture to display
startEvents=1e5;% to skip the first <startEvents> of events 
eventDelta=5e4;% num of events to form a pic

bytesPerDelta=eventDelta*bytesPerEvent;
binaryImg=zeros(Y,X);
grayImg=zeros(Y,X);
normalizedGray=zeros(Y,X); % range in [0,1]
filepath=fullfile(fileDir,fileName);

%% Read in binary data from bin file
fid=fopen(filepath);
fread(fid,20);% the first 20 bytes seems to have recorded the info of setting
fread(fid,startEvents*bytesPerEvent);% skip user controled amount of events
[bytes,bytesCount]=fread(fid,'uint8');% read in events from bianry file

%% Prepare data for image showing/saving
x=uint16(0);
y=uint16(0);
a=uint16(0);
t=uint32(0);
c=uint8(0);
bytesIndex=1;
stopNum=bytesCount-mod(bytesCount,eventDelta*bytesPerEvent);  % 去掉整除不了的
Events=zeros(bytesCount/4,4);
% while bytesIndex<stopNum
while bytesIndex<bytesCount
    byte0=bytes(bytesIndex);
    byte1=bytes(bytesIndex+1);
    byte2=bytes(bytesIndex+2);
    byte3=bytes(bytesIndex+3);
        
    switch(byte3)
        case 0
            %col event
            x=uint16(mod(byte0,128));%X[6:0]
            x=x+bitshift((mod(byte1,64)-mod(byte1,16)),3);%X[8:7]
            c=uint8(bitshift(byte1,-6));%C[0]
            if c==1
                x=767-x;
            end
            a=uint16(mod(byte1,16));%A[3:0]
            a=a+bitshift(mod(byte2,32),4);%A[8:4]
        case 255
            % special event
            bytesIndex=bytesIndex+4;
            continue
        otherwise
            %row event
            y=uint16(mod(byte0,128));%Y[6:0]
            y=y+bitshift((mod(byte1,128)-mod(byte1,16)),3);%Y[9:7]
            t=uint32(mod(byte1,16));%T[3:0]
            t=t+bitshift(mod(byte2,128),4);%T[10:4]
            t=t+bitshift(mod(byte3,64),11);%T[16:11]
            bytesIndex=bytesIndex+4;
            continue
    end
    
    Events(ceil(bytesIndex/4),1)=x;
    Events(ceil(bytesIndex/4),2)=y;
    Events(ceil(bytesIndex/4),3)=t;
    Events(ceil(bytesIndex/4),4)=a;    
    bytesIndex=bytesIndex+4;
end
fclose(fid);
% save('AllEvents','Events');
% %% Crop from initial events
% Events = importdata('AllEvents');
% StartEventsNum=4.7378e+07;
% EventsSum=1.2e7;
% StartEvents=168e5;
% EndEventsSum=210e5;
% CropEvents = Events(StartEvents:EndEventsSum, :);
% CropEvents(all(CropEvents==0,2),:) = []; 
% % calculate data time
% tsCopy = CropEvents(:,3);
% sum = 0;
% for i = 2:length(tsCopy)
%     if tsCopy(i)>=tsCopy(i-1)
%         sum = sum+tsCopy(i)-tsCopy(i-1);
%     else
%         sum = sum + tsCopy(i);
%     end
% end
% Tss = sum*40/10^9;

CropEvents = Events;
CropEvents(all(CropEvents==0,2),:) = [];
% save('CropIndoorBadminton', 'CropEvents');
% save('Crop2ren2bian', 'CropEvents');
%% Show to check
Delta =5e5;
img = zeros(Y,X);
for i=Delta:Delta:length(CropEvents)
        y = Y-CropEvents(i-Delta+1:i,2);
        x = CropEvents(i-Delta+1:i,1)+1;
        a = CropEvents(i-Delta+1:i,4);
    for j=1:Delta
        img(y(j),x(j)) = a(j);
    end
    imshow(img);
    img = zeros(Y,X);
    drawnow;
end
toc;
