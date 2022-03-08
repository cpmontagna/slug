% extract pressure timeseries on selected boundary positions

% Chiara P. Montagna, INGV Pisa, Feb 2022
% chiara.montagna@ingv.it

% TODO overpressure
% make it a jupyter notebook

clear all; 
close all;
fclose('all');

% ================================ TO BE SET ==============================

zCoords = [0 5 15 25];

sampleTimes = 0:0.1:4.4;


% ========================================================================

load '../0/boundaryLine_p.xy';
zetas = boundaryLine_p(:,1);

for i = 1:length(zCoords)
[foo(i),index(i)] = min(abs(zCoords(i) - zetas));
end
j = 1;
 
for sampleTimeNow = sampleTimes(1:end)
load(['../' num2str(sampleTimeNow) '/boundaryLine_p.xy']);
for i = 1:length(zCoords)
pressure(i,j) = boundaryLine_p(index(i),2);
end
j = j+1;
end

figure(1)
hold on
for i = 1:length(index)
plot(sampleTimes,pressure(i,:))
end
legend('0 m','5 m','15 m', '25m','box','off')
xlabel(['Time, s']);
ylabel(['Pressure, Pa']);