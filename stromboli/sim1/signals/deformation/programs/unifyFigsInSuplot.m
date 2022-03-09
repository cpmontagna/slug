% combine figs into a single figure as subplots

% Load saved figures
c = hgload('../figures/Somigliana/verticalDisplacement_x_500_10s.fig');
k = hgload('../figures/Green/verticalDisplacement_x_500_10s.fig');

% Prepare subplots
figure
h(1) = subplot(1,2,1);
xlim([0 10]);
xlabel('Time (s)');
ylabel('Vertical deformation (mm)');
title('Somigliana');

h(2) = subplot(1,2,2);
xlim([0 10]);
xlabel('Time (s)');
ylabel('Vertical deformation (mm)');
title('Green');

% Paste figures on the subplots
copyobj(allchild(get(c,'CurrentAxes')),h(1));
copyobj(allchild(get(k,'CurrentAxes')),h(2));
% Add legends
% l(1) = legend(h(1),'a)');
% l(2) = legend(h(2),'b)');