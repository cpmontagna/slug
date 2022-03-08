% load and compare results from deformation.m

% Chiara P. Montagna, INGV Pisa 4/2022
% chiara.montagna@ingv.it

% ======= INPUT =============================
% deformation data (mat/disp.mat) paths
loadPathOne = 'Somigliana/twoSides/otherHalf/';
loadPathTwo = 'Somigliana/oneSide/otherHalf/';

% ===========================================

% load displacement data
dispOne = load([loadPathOne 'mat/disp.mat']);
dispTwo = load([loadPathTwo 'mat/disp.mat']);
UtotxOne = dispOne.Utotx(:,1);
UtotxTwo = dispTwo.Utotx(:,1);

% plots
figure(1)
plot(UtotxOne - UtotxTwo);
xlabel('time, samples');
ylabel('Utotx diff');