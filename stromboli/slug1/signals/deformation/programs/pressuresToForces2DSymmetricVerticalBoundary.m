% extract force time series from pressure time series at boundary nodes
% boundaries are vertical, system is 2D symmetric wrt to x = 0
% needs pressure time series, time sampling, nodes coordinates

% Chiara P Montagna, INGV Pisa, 2/2022
% chiara.montagna@ingv.it

% INPUT boundaryPressures.mat, created by extractNodePressures.m, containing:
%       - zetas: vertical coordinates
%       - sampleTimes: time
%       - pressure: p time series at zetas
%       - x: coordinate of right vertical boundary

% OUTPUT sourceN.mat: - x, y coordinates of source
%                     - sampleTimes time
%                     - Fx, Fy force time series (Fy = 0 as the boundary is vertical)

clear all; 
close all;

% ================== TO BE SET ========================================
% load data path
cammino = '../../../postprocessing/pressure/data/';
          
% horizontal coordinate of right boundary (m); forces will be x positive
xBoundary = 0.5;
         
% save path
save_path = '../data/sources/';

% =========================================================================

mkdir(save_path)

% load data
load([cammino 'boundaryPressures.mat']);

% number of sources
nnode = length(zetas);
NS = nnode - 1;

% overpressure is needed to compute ground deformation
for inode = 1:nnode
    P(:,inode) = pressure(inode,:) - pressure(inode,1);
end

% find force application point and surface area (line length in 2D)
for i = 1:NS
    ym(i) = (zetas(i) + zetas(i+1))/2;
    prv(i) = abs(zetas(i+1) - zetas(i));
end

% calculate force as average pressure at application point * area
for j = 1:NS
  for time = 1:size(P,1)
    Pm(time) = (P(time,j) + P(time,j+1))/2;
  end
  Fx = prv(j)*Pm;
  y = ym(j);

  % boundary is vertical
  x = xBoundary;
  Fy = zeros(1,length(sampleTimes));
  
  % save data
  save([save_path 'source' num2str(j)],'x','y','sampleTimes','Fx','Fy');

  clear x:
  clear Fx;
  
  % symmetric replication
  x = -xBoundary;
  Fx = - prv(j)*Pm;
  save([save_path 'source' num2str(NS+j)],'x','y','sampleTimes','Fx','Fy'); 
  
end