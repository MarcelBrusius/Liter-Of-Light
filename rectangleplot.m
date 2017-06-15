%Plot of the rectangle where the origin points of the light rays are
%located

loaded = load('Bottle.mat');
vert = 0.5*loaded.vert;

above_roof=0;
IncidenceAngle=65;
%
diameter=max(vert(:,2))-min(vert(:,2));
f=diameter;
%
F = figure(1);
G = gca;
hold on
init = struct;
Surface = createSurface(vert);
plot(Surface.Bottle,'FaceAlpha',0.2,'FaceLighting','gouraud','BackFaceLighting','unlit');
%
vert2=vert(vert(:,2)<0.1,:);
vert2=vert2(vert2(:,2)>-0.1,:);
vert2=vert2(vert2(:,1)>0,:);
vert2=vert2(vert2(:,3)<= above_roof,:);
[~,i]=min(abs(vert2(:,3)-above_roof));
%vert(i,3)=above_roof;
bottleroof=vert2(i,:);
if above_roof < 20
    bottleroof(1,1)=4.33;
end

%

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
v=[v1 0 v3];
v=v/(norm(v));

vert=vert(vert(:,1)<0,:);
vert=vert(vert(:,3)>= above_roof,:);
%distance plane origin 
d=dot(bottleroof,-v);
distances=zeros(length(vert),1);
    for k=1:length(vert)
       distances(k,1)=abs(dot(vert(k,:),-v)-d);
    end
[e,I]=max(distances(:,1));
maxpoint=vert(I,:);

area=e*f/10000;

%
clear('vert');
%
Origin=bottleroof;
Direction=-b;
Direction=Direction/norm(Direction);
%
Light=struct;
Light.Direction=Direction;
Light.Origin=Origin;

%distance lightsource
dist=40;
lambda=-dist;
X1=[Light.Origin(1,1), Light.Origin(1,1)+lambda*Light.Direction(1,1)];
Y1=[Light.Origin(1,2), Light.Origin(1,2)+lambda*Light.Direction(1,2)];
Z1=[Light.Origin(1,3), Light.Origin(1,3)+lambda*Light.Direction(1,3)];

G=gca;
plot3(G,X1,Y1,Z1,'r-')
% %
view(3);

m=bottleroof+dist*b/norm(b);
rec1=m + 0*e*v - f/2*[0 -1 0];
rec2=m + 0*e*v + f/2*[0 -1 0];
rec3=m + 1*e*v + f/2*[0 -1 0];
rec4=m + 1*e*v - f/2*[0 -1 0];

G=gca;
plot3(G,[rec1(1,1),rec2(1,1)],[rec1(1,2),rec2(1,2)],[rec1(1,3),rec2(1,3)],'b-');
G=gca;
plot3(G,[rec3(1,1),rec4(1,1)],[rec3(1,2),rec4(1,2)],[rec3(1,3),rec4(1,3)],'b-');
G=gca;
plot3(G,[rec1(1,1),rec4(1,1)],[rec1(1,2),rec4(1,2)],[rec1(1,3),rec4(1,3)],'b-');
G=gca;
plot3(G,[rec3(1,1),rec2(1,1)],[rec3(1,2),rec2(1,2)],[rec3(1,3),rec2(1,3)],'b-');

recm1= m + 1*e*v;
G=gca;
plot3(G,[recm1(1,1),maxpoint(1,1)],[recm1(1,2),maxpoint(1,2)],[recm1(1,3),maxpoint(1,3)],'r-');
view(3);

G.ZLim = [above_roof, 80];
G.XLim = [-30, 45];
G.YLim = [-30, 30];

view(3);
