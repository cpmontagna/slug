function [S,gamma] = Somigliana(XR,XS,alfa,beta,rho,fdir,udir)

%
%       Calculate Somigliana Solution for Static displacement in a homogeneous, 
%       unbounded medium
%
%	Coding of AKI & Richards Formula pg 114
%
%  	Input Parameters:
% ---------------------------------------------------------------------------
%  	XR = [xr,yr,zr]	receiver coordinates [m]
%  	XS = [xs,ys,zs]	source coordinates (origin of referring system) [m]
%  	alfa = s-wave propagation speed [m/s]
%       beta = p-wave propagation speed [m/s]
%       rho = rock density [kg/m3]
% 	fdir = force direction (1 = EW, 2 = NS, 3 = UD)
% 	udir = ground displacement direction (1 = EW, 2 = NS, 3 = UD)
% ---------------------------------------------------------------------------
%
%      Output:
% ---------------------------------------------------------------------------
%      gamma: direction cosines from source to receiver
%      x1 E positive    	-> xso,xr
%      x2 N positive		-> yso,yr
%      x3 up positive    	-> zso,sr	
%  
%      S: vector containing the static displacement per unit force
%          along direction udir
% ---------------------------------------------------------------------------

xr = XR(1); 
yr = XR(2); 
zr = XR(3);
xso = XS(1); 
yso = XS(2); 
zso = XS(3);

D = (XR-XS)';
r = sqrt(D'*D);

gamma(1) = (xr-xso)/r;
gamma(2) = (yr-yso)/r;
gamma(3) = (zr-zso)/r;

delta = eye(3,3);

argP = 1/(alfa*alfa);
argS = 1/(beta*beta);

S1 = 1/(8*pi*rho*r);
S2 = (argS-argP)*gamma(udir)*gamma(fdir);
S3 = (argP+argS)*delta(udir,fdir);

S = S1*(S2+S3);
return
end