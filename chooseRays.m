function [Origin,Direction,Intensity] = chooseRays(above_roof, IncidenceAngle, n_rays)
%CHOOSERAYS computes the Origin points, the Direction vector
%and the Intensity for the sun rays, depending on
% - above_roof: level of roof w.r.t bottle
% - IncidenceAngle: elevation angle in degrees
% - n_rays : number of rays

loaded = load('Bottle.mat');
%rescaling (to get values in cm)
vert = 0.5*loaded.vert;

%Greatest diameter of bottle
diameter=max(vert(:,2))-min(vert(:,2));
f=diameter;

%Finding bottle points in same x1-x3-plane and ignore some numerical error
vert2=vert(vert(:,2)<-0.0078,:);
vert2=vert2(vert2(:,2)>-0.01,:);

%Finding the bottle point in this plane which is nearest to above_roof
vert2=vert2(vert2(:,1)>0,:);
vert2=vert2(vert2(:,3)<= above_roof,:);
[~,i]=min(abs(vert2(:,3)-above_roof));
%vert(i,3)=above_roof;
bottleroof=vert2(i,:);
if above_roof < 20
    bottleroof(1,1)=4.33;
end


%Find vector in x1-x3-plane which fulfills the given elevation angle
%w.r.t to the horizontal vector h=[1 0 0].
%So b=[b1 0 b3] with cos(Incangle)=b1/norm(b).
%Calculate vector v in x1-x3-plane, which is normal to b
if IncidenceAngle > 0
    b3=25;
    b1=abs(cos(IncidenceAngle*pi/180))*b3/(sqrt(1-(cos(IncidenceAngle*pi/180))^2));
    v3=10;
    v1=-v3*b3/b1;
else
    b1=1;
    b3=0;
    v1=0;
    v3=1;
end
b=[b1 0 b3];

m=bottleroof+30*b/norm(b);
v=[v1 0 v3];
v=v/(norm(v));

%Size of inital rectangle in m^2 (where the origin points are located)
%Depends on IncidenceAngle

vert=vert(vert(:,1)<0,:);
vert=vert(vert(:,3)>= above_roof,:);
%consider hesse normal form of plane with normal vector v
%distance plane origin 
d=dot(bottleroof,-v);
distances=zeros(length(vert),1);
    for k=1:length(vert)
       distances(k,1)=abs(dot(vert(k,:),-v)-d);
    end
%find max-distant point 
e=max(distances(:,1));

area=e*f/10000;

rn=rand(n_rays,2);

%Calculation of Origin points located in the computed rectangle
Origin=m + rn(:,1)*e*v + (f*rn(:,2)-0.5*f)*[0 -1 0];

Direction=-b;

%inital_ray_intensity:
%started with an irradiance of 1000 W/m^2, corrected it down to 700W/m^2
%scaled with the irradiated area
%and the number of rays
Intensity=700*area/n_rays;



end

