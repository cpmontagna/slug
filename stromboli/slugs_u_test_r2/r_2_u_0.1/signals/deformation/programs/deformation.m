% calculate ground displacement caused by a 2D non-homogeneous, complex source by means of Green's functions integrations or Somigliana tensor (quasi-static approximation, Aki, K, and P G Richards (1980). Quantitative Seismology. W.H. Freeman and Company)
% needs Green2D.m or Somigliana.m

% Simone Colucci, Chiara P. Montagna; INGV Pisa, October 2021
% simone.colucci@ingv.it chiara.montagna@ingv.it

% =========================== INPUT ====================================

% files sourceNUMBER.mat (e.g. source1.mat) contain time series of forces at specific points in 2D space
% they contain 4 variables:                                                
%      x, double - horizontal coordinate of source [m]                          
%      y, double - vertical coordinate of source [m]                         
%      Fx, array of double - time series of horizontal force at source [N]
%      Fy, array of double - time series of vertical force at source [N]     
% ========================================================================

% ========================= OUTPUT =====================================
% saves mat files: dispFileName.mat - full results, contains variables: 
%                                 XR receivers coordinates
%                                 XS source coordinates
%                                 dto time step
%                                 t time                   
%                                 Utotx horizontal displacement in time t at stations XR
%                                 Utotz vertical displacement in time t at stations XR
%              normalized_disFileName.mat - as above (displacement.mat) but with normalized values for U
%              strainFileName.mat - strain results, if flag is on, contains:
%                           XR receivers coordinates 
%                           XS source coordinates    
%                           dto time step            
%                           t time                   
%                           exx horizontal strain in time t at stations XR
%                           ezz vertical strain in time t at stations XR
%                           theta volumentric strain in time t at stations XR
% directory csv contains strain and displacement time series in csv format for each receiver (e.g. ezz_rec#5.csv)
% ========================================================================

clear all
close all

% ============================ TO BE SET =================================

%%%% Input data 
% Path for input files
path_source = '../data/sources/';

% time step of input data [s]
% not needed for Somigliana 
dto = 0.1;

% number of input time samples
% 'all' as a keyword to select alla vailable samples, or any number (smaller than length(Fx))
np = 'all'; 

%%%% Output data:
% path for saving output
path_data = '../data/Green/';
% filenames
dispFileName = 'disp';
strainFileName = 'strain';

%% parameters:
% rock parameters for wave propagation - Chouet et al., 2003
alfa = 3500; % S-wave propagation speed [m/s]
beta = 2000; % P-wave propagation speed [m/s]
rho = 2650; % rock density [kg/m3]

% synthetic stations horizontal coordinates [m]
% cannot be a single one
xr = [200 500 1000];

% receivers vertical coordinate [m] - offset from 0 (Earth's surface)
zOffset = 200;

% calculate strain
strainFlag = 1;

% differential for strain calculation (e = sum_i(dUi/di))
dx = 0.1;
dz = 0.1;

% third dimension
Mogi3D = 'false'; % 'true' replicates the system in the third dimension; 'false' gives 2D results
halfY = 1000; % half length along the third dimension [m]
dy = 100; % discretization step along third dimension coordinate [m]
fact_simmetry = 2;

% Green's functions or Somigliana                               
Green = 'true';   % 'false' uses Somigliana tensor approximation
% ========================================================================

% create data output dir
mkdir(path_data)
path_data_mat=[path_data 'mat/'];
path_data_dat=[path_data 'receiver_source/'];
path_data_csv=[path_data 'csv/'];
mkdir(path_data_mat)
mkdir(path_data_dat)
mkdir(path_data_csv)

% number of receivers along x direction
nr = length(xr);

% receivers y, z coordinates
yr = zeros(nr,1);
zr = zOffset + zeros(nr,1);
yr = yr';
zr = zr';

if (strcmp('false',Mogi3D))
    halfY = 0;
    dy = 1;
    fact_simmetry = 1;
end

% read source data
source_data = dir([path_source 'source*.mat']);
NS = length(source_data); % number of sources

% create time vector for saving time series
sourcetmp = load([path_source source_data(1).name]);
if (strcmp('all',np))
    np = length(sourcetmp.Fx);
end

if (strcmp('true',Green))
    t = 0:dto:(np-1)*dto;
else
    t = sourcetmp.sampleTimes;
end

% calculate displacement

Utotx = zeros(np,nr);
Utotz = zeros(np,nr);
Ux = zeros(np,1);
Uz = zeros(np,1);
if strainFlag
    Utotx_right = zeros(np,nr);
    Utotz_up = zeros(np,nr);
    Utotx_left = zeros(np,nr);
    Utotz_down = zeros(np,nr);
    Ux_right = zeros(np,1);
    Uz_up = zeros(np,1);
    Ux_left = zeros(np,1);
    Uz_down = zeros(np,1);
    
    hdx = dx/2;
    hdz = dz/2;
end

for ir = 1:nr         % loop receivers
    disp(['Receiver: ' num2str(ir)]);
    t0 = clock;
    
    for is = 1:NS      % Loop sources        
        source = load([path_source source_data(is).name]);
        
        % coordinates of the deformation source
        xs(is) = source.x;
        zs(is) = source.y;
        
        % forces
        Fx = (source.Fx(1,:));
        Fz = (source.Fy(1,:));
        Fx = Fx';
        Fz = Fz';
        
        for iy = 0 : dy : halfY
            
            % evaluate displacement at receiver
            if (strcmp('true',Green))
                Uxx = Green2D(t,Fx,[xr(ir) yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,1,1);
                Uxz = Green2D(t,Fz,[xr(ir) yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,2,1);
                Uzx = Green2D(t,Fx,[xr(ir) yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,1,2);
                Uzz = Green2D(t,Fz,[xr(ir) yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,2,2);
                
                Ux(:,1) = (Uxx + Uxz)*dy;
                Uz(:,1) = (Uzx + Uzz)*dy;
                
            else
                [Uxx, ~] = Somigliana([xr(ir) yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,1,1);
                [Uxz, ~] = Somigliana([xr(ir) yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,3,1);
                [Uzx, ~] = Somigliana([xr(ir) yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,1,3);
                [Uzz, ~] = Somigliana([xr(ir) yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,3,3);
                
                Ux(:,1) = (Fx.*Uxx+Fz.*Uxz)*dy;
                Uz(:,1) = (Fx.*Uzx+Fz.*Uzz)*dy;
                
                
            end
            
            Utotx(:,ir) = Utotx(:,ir) + Ux(:,1);
            Utotz(:,ir) = Utotz(:,ir) + Uz(:,1);
            
            % evaluate displacement at receiver for strain calculation
            if strainFlag
                
                if (strcmp('true',Green))
                    Uxx_right = Green2D(t,Fx,[xr(ir)+hdx yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,1,1);
                    Uxz_right = Green2D(t,Fz,[xr(ir)+hdx yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,2,1);
                    Uzx_up = Green2D(t,Fx,[xr(ir) yr(ir) zr(ir)+hdz],[xs(is) iy zs(is)],alfa,beta,rho,1,2);
                    Uzz_up = Green2D(t,Fz,[xr(ir) yr(ir) zr(ir)+hdz],[xs(is) iy zs(is)],alfa,beta,rho,2,2);
                    
                    Uxx_left = Green2D(t,Fx,[xr(ir)-hdx yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,1,1);
                    Uxz_left = Green2D(t,Fz,[xr(ir)-hdx yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,2,1);
                    Uzx_down = Green2D(t,Fx,[xr(ir) yr(ir) zr(ir)-hdz],[xs(is) iy zs(is)],alfa,beta,rho,1,2);
                    Uzz_down = Green2D(t,Fz,[xr(ir) yr(ir) zr(ir)-hdz],[xs(is) iy zs(is)],alfa,beta,rho,2,2);
                    
                    Ux_right(:,1) = (Uxx_right + Uxz_right)*dy;
                    Uz_up(:,1) = (Uzx_up + Uzz_up)*dy;
                    
                    Ux_left(:,1) = (Uxx_left + Uxz_left)*dy;
                    Uz_down(:,1) = (Uzx_down + Uzz_down)*dy;
                    
                else
                    [Uxx_right, ~] = Somigliana([xr(ir)+hdx yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,1,1);
                    [Uxz_right, ~] = Somigliana([xr(ir)+hdx yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,3,1);
                    [Uzx_up, ~] = Somigliana([xr(ir) yr(ir) zr(ir)+hdz],[xs(is) iy zs(is)],alfa,beta,rho,1,3);
                    [Uzz_up, ~] = Somigliana([xr(ir) 0 hdz],[xs(is) iy zs(is)],alfa,beta,rho,3,3);
                    
                    [Uxx_left, ~] = Somigliana([xr(ir)-hdx yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,1,1);
                    [Uxz_left, ~] = Somigliana([xr(ir)-hdx yr(ir) zr(ir)],[xs(is) iy zs(is)],alfa,beta,rho,3,1);
                    [Uzx_down, ~] = Somigliana([xr(ir) yr(ir) zr(ir)-hdz],[xs(is) iy zs(is)],alfa,beta,rho,1,3);
                    [Uzz_down, ~] = Somigliana([xr(ir) yr(ir) zr(ir)-hdz],[xs(is) iy zs(is)],alfa,beta,rho,3,3);
                    
                    Ux_right(:,1) = (Fx.*Uxx_right+Fz.*Uxz_right)*dy;
                    Uz_up(:,1) = (Fx.*Uzx_up+Fz.*Uzz_up)*dy;
                    
                    Ux_left(:,1) = (Fx.*Uxx_left+Fz.*Uxz_left)*dy;
                    Uz_down(:,1)=(Fx.*Uzx_down+Fz.*Uzz_down)*dy;
                
                end
                
                Utotx_right(:,ir) = Utotx_right(:,ir) + Ux_right(:,1);
                Utotz_up(:,ir) = Utotz_up(:,ir) + Uz_up(:,1);
                
                Utotx_left(:,ir) = Utotx_left(:,ir) + Ux_left(:,1);
                Utotz_down(:,ir) = Utotz_down(:,ir) + Uz_down(:,1);
                
            end
            
        end
        
    end
    
    jj = etime(clock,t0);
    disp(['Elapsed Time for all sources is ' num2str(jj) 's']);
    
end

% displacement
Utotx = Utotx*fact_simmetry;
Utotz = Utotz*fact_simmetry;

if strainFlag
    Utotx_right = Utotx_right*fact_simmetry;
    Utotx_left = Utotx_left*fact_simmetry;
    Utotz_up = Utotz_up*fact_simmetry;
    Utotz_down = Utotz_down*fact_simmetry;
    
    % differential displacement
    dUx = Utotx_right - Utotx_left;
    dUz = Utotz_up - Utotz_down;
    
    % longitudinal strain
    exx = dUx/dx;
    ezz = dUz/dz;
    % volumetric strain
    theta = exx + ezz;
end

% Normalise with abs(max) after t=0

norm_Utotx = zeros(size(Utotx));
norm_Utotz = zeros(size(Utotz));

norm_Utotx(1,:) = Utotx(1,:);
norm_Utotz(1,:) = Utotz(1,:);

abs_max_x = abs(max(Utotx'));
abs_max_z = abs(max(Utotz'));

for it = 2:size(Utotx,1)
    norm_Utotx(it,:) = Utotx(it,:)/abs_max_x(it);
    norm_Utotz(it,:) = Utotz(it,:)/abs_max_z(it);
end

XS = [xs' , zeros(NS,1), zs']; % source coordinates
XR = [xr', yr', zr'];  % receiver coordinates
% save *.mat

displacement_name = [path_data_mat dispFileName '.mat'];
save(displacement_name,'XR','XS','dto','t','Utotx','Utotz','-mat')

if strainFlag
    strain_name = [path_data_mat strainFileName '.mat'];
    save(strain_name,'XR','XS','dto','t','exx','ezz','theta','-mat')
end

total_normalized = [path_data_mat 'normalized_' dispFileName '.mat'];
save(total_normalized,'XR','XS','dto','t','norm_Utotx','norm_Utotz','-mat')

% save *.csv, strainsuite format

S = seconds(t);
S.Format = 'hh:mm:ss';
D = datetime('today','Format','yyyy-MM-dd');
Dchar = char(D);
Schar = char(S);

for i=1:length(Utotz(1,:))
    
    Utotx_str = num2str(Utotx(:,i));
    Utotz_str = num2str(Utotz(:,i));
    if strainFlag
        exx_str = num2str(exx(:,i));
        ezz_str = num2str(ezz(:,i));
        theta_str = num2str(theta(:,i));
    end
    
    displacementx = strcat(Dchar,'T',Schar,',',Utotx_str);
    displacementz = strcat(Dchar,'T',Schar,',',Utotz_str);
    if strainFlag
        strainxx = strcat(Dchar,'T',Schar,',',exx_str);
        strainzz = strcat(Dchar,'T',Schar,',',ezz_str);
        strainvol = strcat(Dchar,'T',Schar,',',theta_str);
    end
    
    displacementx_path = [path_data_csv 'ux_rec#' num2str(i) '.csv'];
    displacementz_path = [path_data_csv 'uz_rec#' num2str(i) '.csv'];
    if strainFlag
        strainxx_path = [path_data_csv 'exx_rec#' num2str(i) '.csv'];
        strainzz_path = [path_data_csv 'ezz_rec#' num2str(i) '.csv'];
        strainvol_path = [path_data_csv 'theta_rec#' num2str(i) '.csv'];
    end
    
    dlmwrite(displacementx_path,((displacementx)),'delimiter','')
    dlmwrite(displacementz_path,((displacementz)),'delimiter','')
    if strainFlag
        dlmwrite(strainxx_path,((strainxx)),'delimiter','')
        dlmwrite(strainzz_path,((strainzz)),'delimiter','')
        dlmwrite(strainvol_path,((strainvol)),'delimiter','')
    end
    
end

