function [Origin,Direction,Intensity] = chooseRays(above_roof, IncidenceAngle, n_rays)
%CHOOSERAYS computes the Origin points, the Direction vector
%and the Intensity for the sun rays, depending on
% - above_roof: level of roof w.r.t bottle
% - IncidenceAngle: elevation angle in degrees
% - n_rays : number of rays

loaded = load('Bottle.mat');
%rescaling (to get values in cm)
vert = 0.5*loaded.vert;

bottletop= [-1.2973   -0.0078   29.9952];

%Finding bottle points in same x1-x3-plane and ignore some numerical error
vert=vert(vert(:,2)<-0.0078,:);
vert=vert(vert(:,2)>-0.01,:);

%Finding the bottle point in this plane which is nearest to above_roof
vert(:,3)=abs(vert(:,3)-above_roof);
[m,i]=min(vert(:,3));
vert(i,3)=above_roof;
bottleroof=vert(i,:);


vek=bottletop-bottleroof;
a=15;
b=7;
%Size of inital rectangle in m^2 (where the origin points are located)
area=a*b/10000;

%inital_ray_intensity:
%started with an irradiance of 1000 W/m^2
%scaled with sine-value of elevation angle, the irradiated area
%and the number of rays
Intensity=1000*sin(IncidenceAngle*pi/180)*area/n_rays;

%Find vector in x1-x3-plane which fulfills the given elevation angle
b3=10;
if cos(IncidenceAngle*pi/180) < 10^-4
    b1=0;
else
    b1=abs(cos(IncidenceAngle*pi/180))*b3/(sqrt(1-(cos(IncidenceAngle*pi/180))^2));
end
b=[b1 0 b3];

m=bottleroof+b;
Origin=m + rand(n_rays,1)*15*vek/norm(vek) + (7*rand(n_rays,1)-3.5)*[0 -1 0];
Direction=-b;


end

