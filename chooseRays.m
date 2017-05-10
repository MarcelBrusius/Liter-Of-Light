function [Origin,Direction,Intensity] = chooseRays(above_roof, IncidenceAngle, n_rays)
%CHOOSERAYS computes the Origin points, the Direction vector
%and the Intensity for the sun rays, depending on
% - above_roof: level of roof w.r.t bottle
% - IncidenceAngle: elevation angle in degrees
% - n_rays : number of rays

loaded = load('Bottle.mat');
%rescaling (to get values in cm)
vert = 0.5*loaded.vert;

%Size of inital rectangle in m^2 (where the origin points are located)
%Depends on IncidenceAngle

%Greatest diameter of bottle
diameter=max(vert(:,2))-min(vert(:,2));

f=diameter;
e=diameter/cos((90-IncidenceAngle)*pi/180);
area=e*f/10000;

%Finding bottle points in same x1-x3-plane and ignore some numerical error
vert=vert(vert(:,2)<-0.0078,:);
vert=vert(vert(:,2)>-0.01,:);

%Finding the bottle point in this plane which is nearest to above_roof
vert(:,3)=abs(vert(:,3)-above_roof);
[m,i]=min(vert(:,3));
vert(i,3)=above_roof;
bottleroof=vert(i,:);


%Find vector in x1-x3-plane which fulfills the given elevation angle
%w.r.t to the horizontal vector h=[1 0 0].
%So b=[b1 0 b3] with cos(Incangle)=b1/norm(b).
b3=25;
if cos(IncidenceAngle*pi/180) > 0
    b1=abs(cos(IncidenceAngle*pi/180))*b3/(sqrt(1-(cos(IncidenceAngle*pi/180))^2));
else
    b1=0;
end
b=[b1 0 b3];

m=bottleroof+b;

%Calculate vector v in x1-x3-plane, which is normal to b, 
%s.t. b and v generate a rectangle.
v3=10;
if b1 > 0
    v1=-v3*b3/b1;
else
end

v=[v1 0 v3];
v=v/(norm(v));
rn=rand(n_rays,2);

%Calculation of Origin points located in the computed rectangle
Origin=m + rn(:,1)*e*v + (f*rn(:,2)-0.5*f)*[0 -1 0];

Direction=-b;

%inital_ray_intensity:
%started with an irradiance of 1000 W/m^2
%scaled with the irradiated area
%and the number of rays
Intensity=1000*area/n_rays;



end

