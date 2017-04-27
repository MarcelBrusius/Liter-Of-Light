clear

% Obj = stlread('Cocacola_bottle.stl');
% vert = unique(Obj.vertices,'rows');
% csvwrite('ExportBottle.dat',vert(:,3))

% save('Bottle.mat',vert)
loaded = load('Bottle.mat');
vert = loaded.vert;

F = figure(1);

G = gca;
hold on

Surface = createSurface(vert);

% new struct for light rays:
x = [0 0.25 1.5];
Origin = 5*(2*rand(1000,3)-1)+80*x/norm(x);
% Origin = [0.5 0 5] + 80*x/norm(x,2);
% Origin = [0.5 13.15 83.91];
Direction = [0 -.5 -2];
Light = createLight(Direction,Origin);

%calculate facets seen by light:
% Surface.Illuminated = Surface.BoundaryFacets(Surface.Normal*Light.Direction' < 0);

FirstRefract = RayTrace(Surface,Light,1,'b');

SecondRefract = RayTrace(Surface,FirstRefract,1,'r');

% ThridRefract = RayTrace(Surface,SecondRefract,1,'y');


% 


