% Obj = stlread('Cocacola_bottle.stl');
% vert = unique(Obj.vertices,'rows');
% csvwrite('ExportBottle.dat',vert(:,3))

% save('Bottle.mat',vert)
loaded = load('Bottle.mat');
vert = loaded.vert;

F = figure;
G = axes(F);

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



% now it's possible/easy to check for surfaces which are hit by a light ray
% via < Light, surface_normal> > 0:

% new struct for light rays:
Light = struct;
Light.Direction = [0 -.5 -2];
Light.Direction = Light.Direction/norm(Light.Direction,2);
x = [0 0.25 1.5];
Light.Origin = 5*(2*rand(10,3)-1)+80*x/norm(x);
% Light.Origin = [0.5 0 5] + 80*x/norm(x,2);
% Light.Origin = [0.5 13.15 83.91];

lambda = 90;

plot3(G,Light.Origin(:,1),Light.Origin(:,2),Light.Origin(:,3),'x');
hold on
for i = 1:numel(Light.Origin)/3
    plot3(G,[Light.Origin(i,1), Light.Origin(i,1)+lambda*Light.Direction(1)],...
          [Light.Origin(i,2), Light.Origin(i,2)+lambda*Light.Direction(2)],...
          [Light.Origin(i,3), Light.Origin(i,3)+lambda*Light.Direction(3)], '-')
end
% light(G, 'Style','infinite','Position',[-30,-30,90], 'Color', [1,1,1]);

Light.Reflectance = diffuse(Surface.Normal(:,1),Surface.Normal(:,2),Surface.Normal(:,2),[-30,-30,50]);


%calculate facets seen by light:
Surface.Illuminated = Surface.BoundaryFacets(Surface.Normal*Light.Direction' < 0);
Contact.RayNumber = zeros(size(Surface.Illuminated));
Contact.Vertex = zeros(size(Light.Origin));
Contact.BoundaryFacet = zeros(size(Light.Origin));
Contact.Ray_t = zeros(numel(Light.Origin)/3,1);

% 
for raynum = 1:numel(Light.Origin)/3
    for i = 1:numel(Surface.BoundaryFacets)/3
        rs = Light.Origin(raynum,:)' - Surface.Vertices(Surface.BoundaryFacets(i,1),:)'; % right hand side of equation
        sysmat = [-Light.Direction', ...
            Surface.Vertices(Surface.BoundaryFacets(i,2),:)'-Surface.Vertices(Surface.BoundaryFacets(i,1),:)',...
            Surface.Vertices(Surface.BoundaryFacets(i,3),:)'-Surface.Vertices(Surface.BoundaryFacets(i,1),:)']; % System matrix of equation
        sol = sysmat\rs;
        t = sol(1);
        beta = sol(2);
        gamma = sol(3);

        if ((beta > 0 && beta < 1) && (gamma > 0 && gamma < 1) && (t >0) && (beta+gamma<1))
%             Contact.RefractDirection = [];
%             Contact.ReflectDirection = [];
            disp(sol)
            if (Contact.Ray_t(raynum) == 0)
                Contact.RayNumber(i) = raynum;
                Contact.Vertex(raynum,:) = Light.Origin(raynum,:) + t*Light.Direction;
                Contact.BoundaryFacets(raynum,:) = Surface.BoundaryFacets(i,:);
                Contact.Ray_t(raynum) = t;
            elseif (Contact.Ray_t(raynum) > t)
                Contact.RayNumber(i) = raynum;
                Contact.Vertex(raynum,:) = Light.Origin(raynum,:) + t*Light.Direction;
                Contact.BoundaryFacets(raynum,:) = Surface.BoundaryFacets(i,:);
                Contact.Ray_t(raynum) = t;
            end
            plot3(Contact.Vertex(raynum,1), Contact.Vertex(raynum,2), Contact.Vertex(raynum,3), 'b*')
        end
    end
    
end

