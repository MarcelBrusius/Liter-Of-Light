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
Origin = 5*(2*rand(1,3)-1)+80*x/norm(x);
% Origin = [0.5 0 5] + 80*x/norm(x,2);
% Origin = [0.5 13.15 83.91];
Direction = [0 -.5 -2];
Light = createLight(Direction,Origin);

%calculate facets seen by light:
% Surface.Illuminated = Surface.BoundaryFacets(Surface.Normal*Light.Direction' < 0);

[Refract, Reflect] = RayTrace(Surface,Light,1);

% [T,~] = RayTrace(Surface,Refract,1);
% [T,~] = RayTrace(Surface,T,1);
% [T,~] = RayTrace(Surface,T,1);
% [T,~] = RayTrace(Surface,T,1);
% [T,~] = RayTrace(Surface,T,1);
% [T,~] = RayTrace(Surface,T,1);
% [T,~] = RayTrace(Surface,T,1);
% [T,~] = RayTrace(Surface,T,1);
% [T,~] = RayTrace(Surface,T,1);
height = 2;

Ind = [2*(1:(2^(height-1)-1))', 2*(1:(2^(height-1)-1))'+1];
Ind(Ind>(2^(height)-1)) = 0;

C = cell(2^(height)-1,1);
C{1} = [Refract,Reflect];

for i = 2:2:2^(height)-1
    [T,R] = RayTrace(Surface,C{floor(i/2)}(1),1);
    C{ i } = [T,R];
    
    [T,R] = RayTrace(Surface,C{floor(i/2)}(2),1);
    C{i+1} = [T,R];
end

for i = 2^(height-1):2^(height)-1
    RayTrace(Surface,C{i}(1),1);
    RayTrace(Surface,C{i}(2),1);
end
