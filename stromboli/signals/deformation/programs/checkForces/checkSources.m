% load source files created with different methods and check if they are equal
% sources are located on symmetric vertical boundaries

% Chiara P. Montagna, INGV Pisa, 2/2022
% chiara.montagna@ingv.it

clear all
close all

% ============== INPUT ==============================
% source files paths
oneSidePath = 'sourcesOneSide/';
twoSidesPath = 'sourcesTwoSides/';

% ==================================================

% list sources
oneSideData = dir([oneSidePath 'source*.mat']);
twoSidesData = dir([twoSidesPath 'source*.mat']);

% number of sources
if length(twoSidesData) ~= length(oneSideData)
    disp('ATTENTION! different number of sources')
end

NS = length(twoSidesData);

% load source data
for is = 1:NS
    sourcesOneSide(is) = load([oneSidePath oneSideData(is).name]);
    sourcesTwoSides(is) = load([twoSidesPath twoSidesData(is).name]);
end

% sort by vertical coordinate
[foo,sortedIndeces] = sort([sourcesOneSide.y]);
sortedOneSide = sourcesOneSide(sortedIndeces);
[foo,sortedIndeces] = sort([sourcesTwoSides.y]);
sortedTwoSides = sourcesTwoSides(sortedIndeces);

% separate left from right sides
sortedLeftOS = sortedOneSide;
sortedRightOS = sortedOneSide;
sortedRightOS([sortedRightOS.x] == -0.5) = [];
sortedLeftOS([sortedLeftOS.x] == 0.5) = [];

sortedLeftTS = sortedTwoSides;
sortedLeftTS([sortedLeftTS.x] == 0.5) = [];
sortedRightTS = sortedTwoSides;
sortedRightTS([sortedRightTS.x] == -0.5) = [];

% size of struct.Fx is length(fx)*NS, thus all data are concatenated and in the same order
figure(1)
plot([sortedRightTS.Fx] - [sortedRightOS.Fx],'+k')
title('Fx difference, right side')

sortedLeftOSFx = reshape([sortedLeftOS.Fx],[1 85794]);
% won't work out of the box for mysterious reasons
figure(2)
plot([sortedLeftTS.Fx] - sortedLeftOSFx,'+k')
title('Fx difference, left side')