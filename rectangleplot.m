%Plot of the rectangle where the origin points of the light rays are
%located

loaded = load('Bottle.mat');
vert = 0.5*loaded.vert;

above_roof=18;
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
%
vert=vert(vert(:,2)<0.1,:);
vert=vert(vert(:,2)>-0.1,:);

[~,i]=min(abs(vert(:,3)-above_roof));
%vert(i,3)=above_roof;
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

if IncidenceAngle < 75
    [~,I]=max(vert(:,3));
    bottletop=vert(I,:);
    bb=b/norm(b);
    op=bottleroof+dot(bottletop-bottleroof,bb)*bb;
    e=norm(bottletop-op);
else
    %e=diameter/cos((90-IncidenceAngle)*pi/180);
%     vert=vert(vert(:,1)<0,:);
%     vert=vert(vert(:,3)>= above_roof,:);
%     bb=b/norm(b);
%     d=zeros(length(vert),1);
%     for k=1:length(vert)
%        d(k,1)=norm(bottleroof+dot(vert(k,:)-bottleroof,bb)*bb-vert(k,:));
%     end
    %e=max(d(:,1));
    
    %point "behind" bottlecap
    p=[-4.2183    0.1303   18.6124];
    bb=b/norm(b);
    op=bottleroof+dot(p-bottleroof,bb)*bb;
    e=norm(p-op);
    
    %e=11;
end


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
dist=30;
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
if IncidenceAngle < 75
    plot3(G,[recm1(1,1),bottletop(1,1)],[recm1(1,2),bottletop(1,2)],[recm1(1,3),bottletop(1,3)],'r-');
else
    plot3(G,[recm1(1,1),p(1,1)],[recm1(1,2),p(1,2)],[recm1(1,3),p(1,3)],'r-');
end
view(3);

G.ZLim = [-10, 60];
G.XLim = [-30, 30];
G.YLim = [-30, 30];

view(3);
