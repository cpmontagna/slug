% extract pressure timeseries on all boundary

% Chiara P. Montagna, INGV Pisa, Feb 2022
% chiara.montagna@ingv.it

% make it a jupyter notebook

clear all; 
close all;
fclose('all');

% ================================ TO BE SET ==============================

sampleTimes = 0:0.1:4.4;

% ========================================================================

load '../data/0/boundaryLine_p.xy';
zetas = boundaryLine_p(:,1);

% $$$ for i = 1:length(zCoords)
% $$$ [foo(i),index(i)] = min(abs(zCoords(i) - zetas));
% $$$ end

j = 1; 
for sampleTimeNow = sampleTimes(1:end)
load(['../data/' num2str(sampleTimeNow) '/boundaryLine_p.xy']);
for i = 1:length(zetas)
pressure(i,j) = boundaryLine_p(i,2);
end
j = j+1;
end

save('../data/boundaryPressures.mat','pressure','zetas');

% $$$ figure(1)
% $$$ hold on
% $$$ for i = 1:length(index)
% $$$ plot(sampleTimes,pressure(i,:))
% $$$ end
% $$$ legend('0 m','5 m','15 m', '25m','box','off')
% $$$ xlabel(['Time, s']);
% $$$ ylabel(['Pressure, Pa']);