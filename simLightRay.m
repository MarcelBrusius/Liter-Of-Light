% Load Bottle
[Surface.BoundaryFacets,Surface.Vertices]= boundaryFacets(Surface.AlphaShape);

% Define direction vector of incoming light ray
dirRay=[0,0,-1];a=1;
dirRay=dirRay./norm(dirRay);

% Choose a facet/triangle where the light rays hits
facetindex=47;
facet=Surface.BoundaryFacets(47,:);
triangle=Surface.Vertices(facet,:);
normal=Surface.Normal(47,:);

% Choose the hitting point on the triangle uniformly
u=rand(1);v=rand(1);
p=(1-sqrt(u))*triangle(1,:) + sqrt(u)*(1-v)*triangle(2,:) + v*sqrt(u)*triangle(3,:); % p should be uniform in the triangle

% Calculate the direction of the refraction with Snells Law
nAir=1; nWater=1.33;
dirRefrac=nAir/nWater*cross(normal,cross(-normal,dirRay)) - normal*sqrt(1-(nAir/nWater)^2*dot(cross(normal,dirRay),cross(normal,dirRay))); % Shells Law (vector form)


% Check angle
%x=acos(dot(dirRay,normal));
%y=acos(dot(dirRefrac,normal));
%disp(sin(x)/sin(y))



%plot(Surface.AlphaShape,'FaceAlpha',0.3);

plot3(triangle(1:2,1),triangle(1:2,2),triangle(1:2,3),'b')
hold on
plot3(triangle(2:3,1),triangle(2:3,2),triangle(2:3,3),'b')
plot3(triangle([3,1],1),triangle([3,1],2),triangle([3,1],3),'b')

hold on
plot3([p(1)-a*dirRay(1),p(1)],[p(2)-a*dirRay(2),p(2)],[p(3)-a*dirRay(3),p(3)],'b')
plot3([p(1)+a*dirRefrac(1),p(1)],[p(2)+a*dirRefrac(2),p(2)],[p(3)+a*dirRefrac(3),p(3)],'b')
hold off