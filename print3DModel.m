% Obj = stlread('Cocacola_bottle.stl');
% vert = unique(Obj.vertices,'rows');
% csvwrite('ExportBottle.dat',vert(:,3))

% save('Bottle.mat',vert)
loaded = load('Bottle.mat');
vert = loaded.vert;

F = figure;
G = axes(F);

Surface = createSurface(vert);

% now it's possible/easy to check for surfaces which are hit by a light ray
% via < Light, surface_normal> > 0:

% new struct for light rays:
x = [0 0.25 1.5];
Origin = 5*(2*rand(200,3)-1)+80*x/norm(x);
% Origin = [0.5 0 5] + 80*x/norm(x,2);
% Origin = [0.5 13.15 83.91];
Direction = [0 -.5 -2];
Light = createLight(Direction,Origin,1);

%calculate facets seen by light:
Surface.Illuminated = Surface.BoundaryFacets(Surface.Normal*Light.Direction' < 0);

[Refraction, ~] = RayTrace(Surface,Light);
% 


