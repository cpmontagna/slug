% extract force time series from pressure time series at boundary nodes
% needs pressure time series, time sampling, nodes coordinates

% Chiara P Montagna, INGV Pisa, 2/2022
% chiara.montagna@ingv.it

% TODO jupyter notebook

clear all; 
close all;

% ================== TO BE SET ========================================
% paths 
cammino ='../data/';
save_path = '../data/sources/';

% =========================================================================

mkdir(save_path)
% $$$ % read ordered nodes label
% $$$ bound_nodes = load([cammino 'nodeBoundary']);
load([cammino 'boundaryPressures.mat']);
%nnode = size(bound_nodes,1);
nnode = length(zetas);

for inode = 1:nnode
    P(:,inode) = pressure(inode,:) - pressure(inode,1);
    X(inode) = 0;
    Y(inode) = zetas(inode);
    %    ll(inode) = node.label;
end

% $$$ % MV 130809 take all nodes
% $$$ [xm,ym,nodes,prh,prv]=computeMidPoint(X',Y',ll');
% $$$ 
% $$$ for k=1:length(nodes)
% $$$    firstLine(k)=find(ll==nodes(k,1));
% $$$    secondLine(k)=find(ll==nodes(k,2));
% $$$ end
% $$$ clear ll nodes

for i = 1:nnode - 1
    ym(i) = (zetas(i) + zetas(i+1))/2;
    prv(i) = abs(zetas(i+1) - zetas(i));
end

for j=1:length(ym)
  for time = 1:size(P,1)
    Pm(time) = (P(time,j)+P(time,j+1))/2;
end
Fx = prv(j)*Pm;
y = ym(j);

save([save_path 'source' num2str(j)],'y','Fx'); 
end



