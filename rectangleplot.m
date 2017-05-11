%Plot of the rectangle where the origin points of the light rays are
%located

loaded = load('Bottle.mat');
vert = 0.5*loaded.vert;

above_roof=18;
IncidenceAngle=45;
%
diameter=max(vert(:,2))-min(vert(:,2));
f=diameter;
e=diameter/cos((90-IncidenceAngle)*pi/180);
area=e*f/10000;
%
F = figure(1);
G = gca;
hold on
init = struct;
Surface = createSurface(vert);
%
vert=vert(vert(:,2)<-0.0078,:);
vert=vert(vert(:,2)>-0.01,:);
vert(:,3)=abs(vert(:,3)-above_roof);
[m,i]=min(vert(:,3));
vert(i,3)=above_roof;
bottleroof=vert(i,:);
%
b3=25;
if cos(IncidenceAngle*pi/180) > 0
    b1=abs(cos(IncidenceAngle*pi/180))*b3/(sqrt(1-(cos(IncidenceAngle*pi/180))^2));
else
    b1=0;
end
b=[b1 0 b3];
%
v3=10;
if b1 > 0
    v1=-v3*b3/b1;
else
end

v=[v1 0 v3];
v=v/(norm(v));
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

lambda=-20;
X1=[Light.Origin(1,1), Light.Origin(1,1)+lambda*Light.Direction(1,1)];
Y1=[Light.Origin(1,2), Light.Origin(1,2)+lambda*Light.Direction(1,2)];
Z1=[Light.Origin(1,3), Light.Origin(1,3)+lambda*Light.Direction(1,3)];

G=gca;
plot3(G,X1,Y1,Z1,'r-')
% %
view(3);

%move triangle
%mov=[0 0 0];%triangle in bottle
%mov=20*b/norm(b);%triangle moved to rectangle
%mov=[-diameter 0 0];%moved behind the bottle
mov=[0 -diameter/2 0];

for i=1:2

    if i==1
        mov=[0 -diameter/2 0];
    else
        mov=[0 +diameter/2 0];
    end

%Plot triangle
X2=[Light.Origin(1,1)+mov(1,1), Light.Origin(1,1)+mov(1,1)+e*v(1,1)];
Y2=[Light.Origin(1,2)+mov(1,2), Light.Origin(1,2)+mov(1,2)+e*v(1,2)];
Z2=[Light.Origin(1,3)+mov(1,3), Light.Origin(1,3)+mov(1,3)+e*v(1,3)];
G=gca;
plot3(G,X2,Y2,Z2,'g-');
X3=[Light.Origin(1,1)+mov(1,1),Light.Origin(1,1)+mov(1,1)-diameter];
Y3=[Light.Origin(1,2)+mov(1,2),Light.Origin(1,2)+mov(1,2)];
Z3=[Light.Origin(1,3)+mov(1,3),Light.Origin(1,3)+mov(1,3)];
G=gca;
plot3(G,X3,Y3,Z3,'g-');
X4=[Light.Origin(1,1)+mov(1,1)-diameter,Light.Origin(1,1)+mov(1,1)+e*v(1,1)];
Y4=[Light.Origin(1,2)+mov(1,2),Light.Origin(1,2)+mov(1,2)+e*v(1,2)];
Z4=[Light.Origin(1,3)+mov(1,3),Light.Origin(1,3)+mov(1,3)+e*v(1,3)];
G=gca;
plot3(G,X4,Y4,Z4,'g-');

end

m=bottleroof+20*b/norm(b);
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

view(3);

G.ZLim = [-10, 50];
G.XLim = [-30, 30];
G.YLim = [-30, 30];

view(3);
