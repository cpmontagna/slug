function Disp = Green2D(t,F,XR,XS,alfa,beta,rho,fdir,udir) 
  
%       Analytic convolution of the Green's Function 
%       with an external force
%       2D solution, y coordinates are not used
%
%  	Input Parameters:
% ---------------------------------------------------------------------------
%  	XR = [xr,yr,zr]	receiver coordinates [m]
%  	XS = [xs,ys,zs]	source coordinates (origin of referring system) [m]
%  	alfa = s-wave propagation speed [m/s]
%       beta = p-wave propagation speed [m/s]
%       rho = rock density [kg/m3]
% 	fdir = force direction (1 = EW, 2 = UD)
% 	udir = ground displacement direction (1 = EW, 2 = UD)
%       t = time vector 
%       F = fdir compoment of the external force
% ---------------------------------------------------------------------------

%
%      Output:
% ---------------------------------------------------------------------------
%      Disp: vector containing the udir displacement component due to external %      force F along the fdir direction
% ---------------------------------------------------------------------------

N = length(t);
dt = t(2)-t(1);
  
% allocate variables
I_11 = zeros(N,1);
I_12 = zeros(N,1); 
I_13 = zeros(N,1); 
I_14 = zeros(N,1); 

% Kronecker's delta
delta_k = eye(2,2);

%  Receiver and Source coordinates
xr = XR(1); 
zr = XR(3);
xs = XS(1); 
zs = XS(3);

%  Receiver-to-source distance
Distance = (XR-XS)';
r = sqrt(Distance'*Distance);
r = r(1);
  
% Direction cosines
gamma(1) = (xr-xs)/r;
gamma(2) = (zr-zs)/r;
  
% Time Indices and time corresponding to 
% P-wave and S-wave arrivals
indP = round((r/alfa)/dt);
indS = round((r/beta)/dt);
argP = r/alfa;
argS = r/beta;
  
% check if time step is not too loose
if(indP<1||indS<1)
    disp('time step is too loose: reduce it! ...exiting')
    return
end
  
% constant coefficients
coeff1 = 1/(2*pi*rho); 
coeff2 = gamma(udir)*gamma(fdir);
coeff3 = 1/(r^2);  
coeff4 = 1/(alfa^2); 
coeff5 = 1/(beta^2); 
  
tt = 0:dt:(N-1)*dt;
tt_square = tt.^2;

% pad with zeros if force is shorter than integration interval
ext_F = zeros(max([N indS]),1);  
ext_F(1:N) = F;
  
% Loop over time
for it = 1:N
    %  indices from (it-1)-(indP+1) to (it-1)-(it-1))=0
    if(it-indP-2 > 0)
        ind_alpha = it-indP-2:-1:0;
        % For negative times, consider the first time sample (F(1)=0)
        k_alpha = logical(ind_alpha<1);
        ind_alpha(k_alpha) = 1;
    end
    
    %  indices from it-1-(indS+1) to it-1-(it-1)=0
    if(it-indS-2 > 0)
        ind_beta =  it-indS-2:-1:0; 
        k_beta  = logical(ind_beta<1);
        ind_beta(k_beta) = 1;
    end
            
    % smart way to compute the integrals
    % first and last points weighted one half
    if(it-indP-2 > 0)
        int_11 = 0.5*dt*(1./sqrt(tt_square(indP+1)-...
                                 argP^2)*ext_F(ind_alpha(1))+1./sqrt(tt_square(it-1)-...
                                                          argP^2)*ext_F(ind_alpha(end)));
        int_11 = int_11+dt*dot((1./sqrt(tt_square(indP+2:it-2)-...
                                        argP^2)),ext_F(ind_alpha(2:end-1))');
        int_13 = 0.5*dt*(sqrt(tt_square(indP+1)-...
                              argP^2)*ext_F(ind_alpha(1))+sqrt(tt_square(it-1)-...
                                                          argP^2)*ext_F(ind_alpha(end)));
        int_13 = int_13+dt*dot(sqrt(tt_square(indP+2:it-2)-...
                                    argP^2),ext_F(ind_alpha(2:end-1))');
        I_11(it) = coeff2*coeff4*int_11;
        I_13(it) = (2*coeff2-delta_k(udir,fdir))*coeff3*int_13;
    end
    if(it-indS-2 > 0)
        int_12 = 0.5*dt*(1./sqrt(tt_square(indS+1)-...
                                 argS^2)*ext_F(ind_beta(1))+1./sqrt(tt_square(it-1)-...
                                                          argS^2)*ext_F(ind_beta(end)));
        int_12 = int_12+dt*dot((1./sqrt(tt_square(indS+2:it-2)-...
                                        argS^2)),ext_F(ind_beta(2:end-1))');
        int_14 = 0.5*dt*(sqrt(tt_square(indS+1)-...
                              argS^2)*ext_F(ind_beta(1))+sqrt(tt_square(it-1)-...
                                                          argS^2)*ext_F(ind_beta(end)));
        int_14 = int_14+dt*dot(sqrt(tt_square(indS+2:it-2)-...
                                    argS^2),ext_F(ind_beta(2:end-1))');
        I_12(it) = (coeff2-delta_k(udir,fdir))*coeff5*int_12;
        I_14(it) = -(2*coeff2-delta_k(udir,fdir))*coeff3*int_14;
    end
end
  
Disp = coeff1*(I_11 - I_12 + I_13 + I_14);
return 
end

