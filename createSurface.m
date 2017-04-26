function [ Surface ] = createSurface(vert)
%CREATESURFACE Creates the surface of a Coca Cola bottle using alphaShape
%   createSurface creates a struct with the following fields:
%   
%   Surface.Bottle      : alpha shape defined by the vertices given by vert
%
%   Surface.Roof        : creates a plane that represents the roof
%           Note        : corrently disabled
%
%   Surface.Normal      : stated the (outer) normal vector for each surface
%                         element
%
%   Surface.Vertices    : contains the vertices of the surface (of the
%                         bottle)
%
%   Surface.BoundaryFacets: contains the boundary facets defining the
%                           surface

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
[X,Y] = meshgrid(-50:2:50,-50:2:50);
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
% surf(G,Surface.Roof(:,:,1),Surface.Roof(:,:,2),Surface.Roof(:,:,3),...
%     'FaceAlpha',1,'FaceLighting','gouraud','BackFaceLighting','unlit')
% hold on

% Plot the bottle:
plot(Surface.Bottle,'FaceAlpha',1,'FaceLighting','gouraud','BackFaceLighting','unlit');
% trisurf(k,vert(:,1),vert(:,2),vert(:,3));
% axis image
% alpha(0.3)

hold on

% boundary facets (represented by triangle vertices in every row) given in
% "k", or accessible via alphaShape's boundaryFacets function:
[Surface.BoundaryFacets,Surface.Vertices]= boundaryFacets(Surface.Bottle);

% compute surface representation using "normal vectors" for ease of use:
Surface.Normal = zeros(size(Surface.BoundaryFacets));
for i = 1:numel(Surface.BoundaryFacets)/3
    Surface.Normal(i,:) = cross(Surface.Vertices(Surface.BoundaryFacets(i,1),:),...
        Surface.Vertices(Surface.BoundaryFacets(i,2),:));
    Surface.Normal(i,:) = Surface.Normal(i,:)/norm(Surface.Normal(i,:));
end


end

