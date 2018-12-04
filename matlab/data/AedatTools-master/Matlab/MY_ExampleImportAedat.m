%% Import and plot from a series of files

clearvars
close all
dbstop if error

% This example only reads out the first 1000 packets
aedat.importParams.endPacket = 1000;

address = 'F:\SNN\spike_code\SDNN_STDP\SDNN_STDP\DataSet\DVSGesture\';
filePaths = dir([address '*.aedat']);
numFiles = length(filePaths);

% Create a structure with which to pass in the input parameters.
aedat = struct;
			
for file = 1 : numFiles   
    ff = (filePaths(file).name);
%     [address ff]
	aedat.importParams.filePath = [address ff];
	aedat = ImportAedat(aedat);
    vid(file) = aedat;
% 	PlotAedat(aedat)
end


%%  vid数据的处理
for k = 1:numFiles
    vidmodf{k} = vid(k).data.polarity;    
end

for k = 1:numFiles
   z = uint16(vidmodf{1,k}.polarity);
   vidmodf{1,k}.polarity = z;
end