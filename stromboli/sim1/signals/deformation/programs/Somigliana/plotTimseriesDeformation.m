% plot time series of deformation at synthetic receivers

% Chiara P. Montagna, Simone Colucci; INGV Pisa, 4/1/2021
% chiara.montagna@ingv.it simone.colucci@ingv.it

% ================== INPUT ==================================
% results from deformation.m, specifically:
%              displacement.mat - displacement results, contains variables: 
%                                 XR receivers coordinates
%                                 XS source coordinates
%                                 dto time step
%                                 t time                   
%                                 Utotx horizontal displacement in time t at stations XR
%                                 Utotx vertical displacement in time t at stations XR
%              strain.mat - strain results, contains:
%                           XR receivers coordinates 
%                           XS source coordinates    
%                           dto time step            
%                           t time                   
%                           exx horizontal strain in time t at stations XR
%                           ezz vertical strain in time t at stations XR
%                           theta volumentric strain in time t at stations XR
% ============================================================

% ========================= OUTPUT =====================================

% figures:
%         verticalDisplacement_x_XR.jpg - a figure for each receiver at XR, vertical displacement vs time
%         horizontalDisplacement_x_XR.jpg - a figure for each receiver at XR, horizontal displacement vs time
%         volStrain_x_XR.jpg - a figure for each receiver at XR, volumentric strain vs time

% ============================================================


clear all
close all

% ========== TO BE SET ========================================

% path of deformation data (*.mat)
path_data = '../../data/Somigliana/mat/';

% path for saving figures
path_figs = '../../figures/Somigliana/';

% ==========================================================

load([path_data 'disp.mat']) 
load([path_data 'strain.mat'])

mkdir (path_figs);

th = t/3600; % hours

for ix = 1:length(XR)
    
    % vertical deformation
    fig1 = figure(1);
    clf;
    set(gcf,'Visible','off','Renderer','ZBuffer');
    plot(th,1e3*Utotz(:,ix),'LineWidth',2)
    title(['Vertical displacement at x = ' num2str(XR(ix)) ' m'])
    xlabel('Time (hours)');
    ylabel('Displacement (mm)');
    print(fig1, '-djpeg',[path_figs 'verticalDisplacement_x_' num2str(XR(ix)) ...
                        '.jpg']); 
    
    % horizontal deformation
    fig2 = figure(2);
    clf;
    set(gcf,'Visible','off','Renderer','ZBuffer');
    plot(th,1e3*Utotx(:,ix),'LineWidth',2)
    title(['Horizontal displacement at x = ' num2str(XR(ix)) ' m'])
    xlabel('Time (hours)');
    ylabel('Displacement (mm)');
    print(fig2, '-djpeg',[path_figs 'horizontalDisplacement_x_' ...
                        num2str(XR(ix)) '.jpg']); 
                    
    % volumetric strain 
    fig3 = figure(3);
    clf;
    set(gcf,'Visible','off','Renderer','ZBuffer');
    plot(th,theta(:,ix),'LineWidth',2)
    title(['Volumetric strain at x = ' num2str(XR(ix)) ' m'])
    xlabel('Time (hours)');
    ylabel('Strain');
    print(fig3, '-djpeg',[path_figs 'volStrain_x_' ...
                        num2str(XR(ix)) '.jpg']); 
end
