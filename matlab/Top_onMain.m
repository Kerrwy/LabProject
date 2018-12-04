clear all;clc;
close all
%% prepare lut for exp(-t/tau), used for leaky integration cell.
tau_m = 20e3;
dt = tau_m/1e3; % dt for lut
tau_s = tau_m/4;
tau1 = tau_m;
tau2 = tau_s;

% normalization coefficient.
V0 = 1/max(exp(-(0:dt:5*tau1)/tau1)-exp(-(0:dt:5*tau1)/tau2));
% if ~use_single_exponential
%     tmp = round(5*tau1/dt);
%     V0 = 1/max( lut1(1:tmp) - lut2(1:tmp) );
% else
%     V0 = 1;
% end

%% parameter setting
plotfig = 0;
data_folder = 'data';
dataset = 'rotDisk.mat';

% Window Size
N = 9;
% Estimated fraction of outliers for RANSAC algorithm
epsilon = 0.4;
% Euclidian distance threshold for RANSAC algorithm
mu = 0.001;
% Regularization
reg = true;
% Visualization during computation  可视化平面
vis = false;


%% preallocate space
global IMAGE_FRAME surfNeg  surfPos theta_estimatedNeg  theta_estimatedPos t_estimatedNeg t_estimatedPos LIFmat surface
global timemat colormat velocitymat showmat

IMAGE_FRAME = [180,240];

% preallocate space
surfPos = zeros(IMAGE_FRAME);
surfNeg = zeros(IMAGE_FRAME);
surface = zeros(IMAGE_FRAME);
theta_estimatedPos = zeros(IMAGE_FRAME(1),IMAGE_FRAME(2),3);
theta_estimatedNeg = zeros(IMAGE_FRAME(1),IMAGE_FRAME(2),3);
t_estimatedPos = zeros(IMAGE_FRAME);
t_estimatedNeg = zeros(IMAGE_FRAME);
LIFmat = zeros(IMAGE_FRAME);

timemat = zeros(IMAGE_FRAME); % initialize display time matrix
colormat = zeros(IMAGE_FRAME); % initialize color matrix
velocitymat = zeros(IMAGE_FRAME(1),IMAGE_FRAME(2),3); % initialize velocity vector matrix
showmat = zeros(IMAGE_FRAME);

%% load data and calculate effective timings
tic;
EventsPath = ([data_folder, '/', dataset]);
events = importdata(EventsPath);
% events(:,3) = 1;
 
t = 0:dt:10*tau1;

lut1 = exp(-t/tau1);
lut2 = exp(-t/tau2);
% lut1 = ones(1,100000);
% lut2 = ones(1,100000);
DeltaTS = (events(end,4)-events(1,4))/length(unique(events(:,4)));
THs = V0;


events_with_velocity = calcVelocity(events, N, epsilon, mu, reg, vis, V0, lut1, lut2, dt, THs);
toc;

