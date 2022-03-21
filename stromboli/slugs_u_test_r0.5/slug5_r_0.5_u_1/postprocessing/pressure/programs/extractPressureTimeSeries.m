% extract pressure timeseries on a vertical boundary
% data is stored as function of space 

% Chiara P. Montagna, INGV Pisa, Feb 2022
% chiara.montagna@ingv.it

% INPUT one file per time sample, containing point coordinates and pressure

% OUTPUT boundaryPressures.mat, containing coordinates (zetas) and corresponding pressure time series (sampleTimes, pressure)

clear all; 
close all;
fclose('all');

% ================================ TO BE SET ==============================
% sampled times
sampleTimes = [0:0.1:10];

% pressure data path 
% data stored as loadPath/sampleTime/fileName
loadPath = '../data/';
fileName = 'boundaryLine_p.xy';

% save data
savePath = '../data/';

% ========================================================================

% vertical coordinates
timeZero = load([loadPath '0/' fileName]);
zetas = timeZero(:,1);

% load space data and convert to time series
j = 1; 
for sampleTimeNow = sampleTimes(1:end)
    data = load([loadPath num2str(sampleTimeNow) '/' fileName]);

    for i = 1:length(zetas)
        pressure(i,j) = data(i,2);
    end
    j = j+1;
end

save([savePath 'boundaryPressures.mat'],'sampleTimes','pressure','zetas');
