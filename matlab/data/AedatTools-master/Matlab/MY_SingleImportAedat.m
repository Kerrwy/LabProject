% ��60�����ݵ�ת��
clearvars
close all
dbstop if error

% Create a structure with which to pass in the input parameters.
aedat = struct;

% This example only reads out the first 1000 packets
aedat.importParams.endPacket = 1000;


filePaths = { 'H:\���ݼ�\DVS����\DVS spiking camera gesture dataset\DVS spiking camera gesture dataset\DvsGesture\DvsGesture\user23_fluorescent_led.aedat'};

numFiles = length(filePaths);
			
for file = 1 : numFiles
	aedat.importParams.filePath = filePaths{file};
	aedat = ImportAedat(aedat);
	PlotAedat(aedat)
end