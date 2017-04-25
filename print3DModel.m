% Obj = stlread('Cocacola_bottle.stl');
% vert = unique(Obj.vertices,'rows');
% csvwrite('ExportBottle.dat',vert(:,3))

% save('Bottle.mat',vert)
loaded = load('Bottle.mat');
vert = loaded.vert;

figure(1)

% create struct for better overview:
Surface = struct;

% create the bottle' surface (floting number specifies shrink factor):
% k = boundary(vert(:,1),vert(:,2),vert(:,3),0.863);


% create the bottle as an "alphaShape" with adjusted "AlphaRadius" in order
% to ease work with the surface:
Surface.Bottle = alphaShape(vert(:,1),vert(:,2),vert(:,3));
Surface.Bottle.Alpha = 10;

x = (vert(:,3) < 36 & vert(:,3) > 35);
sur = vert(x,:);
val = sur(1,3);

%Generate the "roof":
[X,Y] = meshgrid(-100:1:100,-100:1:100);
no = zeros(1,sum(x));
for i = 1:sum(x)
    no(i) =norm(sur(i,[1,2]));
end
mi = min(no);
ma = max(no);

Pl = zeros([size(X),3]);
Pl(:,:,1) = X;
Pl(:,:,2) = Y;
Pl(:,:,3) = val*ones(size(X));
[m,n,~] = size(Pl);

Pl = reshape(Pl, [n*m,3]);
contr = sqrt(sum(Pl(:,[1,2]).^2,2));
Pl(contr < ma,3) = 0; % cut a circle out for the bottle

Surface.Roof = zeros(m,n,3);
for i = 1:3
    Surface.Roof(:,:,i) = reshape(Pl(:,i),[m,n]);
end

clear('Pl','mi','ma','m','n','val','no','sur','x','vert','loaded','X','Y','contr');

% Plot the "roof":
surf(Surface.Roof(:,:,1),Surface.Roof(:,:,2),Surface.Roof(:,:,3))
hold on

% Plot the bottle:
plot(Surface.Bottle);
axis image
% trisurf(k,vert(:,1),vert(:,2),vert(:,3));
% axis image
% alpha(0.3)

hold off

% boundary facets (represented by triangle vertices in every row) given in
% "k", or accessible via alphaShape's boundaryFacets function:
[Surface.BoundaryFacets,Surface.Vertices]= boundaryFacets(Surface.Bottle);

% compute surface representation using "normal vectors" for ease of use:
Surface.Normal = zeros(size(Surface.BoundaryFacets));
for i = 1:numel(Surface.BoundaryFacets)/3
    Surface.Normal(i,:) = cross(Surface.Vertices(Surface.BoundaryFacets(i,1),:),...
        Surface.Vertices(Surface.BoundaryFacets(i,2),:));
end

% now it's possible/easy to check for surfaces which are hit by a light ray
% via < Light, surface_normal> > 0:

% new struct for light rays:
Light = struct;

