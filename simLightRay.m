

% 1. Load bottle
[Surface.BoundaryFacets,Surface.Vertices]= boundaryFacets(Surface.AlphaShape);
% Compute surface representation using "normal vectors" for ease of use
Surface.Normal = zeros(size(Surface.BoundaryFacets));
for i = 1:numel(Surface.BoundaryFacets)/3
    Surface.Normal(i,:) = cross(Surface.Vertices(Surface.BoundaryFacets(i,1),:),...
        Surface.Vertices(Surface.BoundaryFacets(i,2),:));
    Surface.Normal(i,:) = Surface.Normal(i,:) / norm(Surface.Normal(i,:));
end
% Vertices, associated triangles and normal vectors should be easily allocated
Vertices=-100*ones(length(Surface.Vertices),17,3); % A vertex has up to 8 edges, and is therefore part of up to 8 triangles. For each triangle we have to save the indices for the vertices and the normal vector
Vertices(:,1,:)=Surface.Vertices;
for i=1:length(Surface.Vertices)
    counter=0;
    for k=1:length(Surface.BoundaryFacets)
        if any(Surface.BoundaryFacets(k)==i)
            Vertices(i,2+2*counter,:)=Surface.BoundaryFacets(k,:);
            Vertices(i,3+2*counter,:)=Surface.Normal(k,:);
            counter=counter+1;
        end
    end
end
disp('Data-Preparation finished')



tic
% 2. Define direction vector of incoming light ray
dirRay=[0,0,-1];a=5;
dirRay=dirRay./norm(dirRay);

% 3. Choose a facet/triangle where the light rays hits
facetindex=47;
facet=Surface.BoundaryFacets(facetindex,:);
triangle=Surface.Vertices(facet,:);
normal=Surface.Normal(facetindex,:);

% 4. Choose the hitting point on the triangle
u=0.5;v=0.5;
%u=rand(1);v=rand(1);
p1=(1-sqrt(u))*triangle(1,:) + sqrt(u)*(1-v)*triangle(2,:) + v*sqrt(u)*triangle(3,:);

% 5. Calculate the direction of the refraction with Snells Law
nAir=1; nWater=1.33;
dirRefrac=nAir/nWater*cross(normal,cross(-normal,dirRay)) - normal*sqrt(1-(nAir/nWater)^2*dot(cross(normal,dirRay),cross(normal,dirRay))); % Shells Law (vector form)


% 6. Calculate the second hitting point
%%{
searchover=0;
bottleHeight=60;

rad1=1.5; % if a vertex is closer than rad1 to the light ray, it is possible for him to belong to the sought-after triangle and therefore it should be detected.
searchsteps=rad1:2*rad1:(bottleHeight+2*rad1); % 2*rad1 the distance of the searching points
searchpoints=zeros(3,length(searchsteps));
for j=1:length(searchsteps)
    searchpoints(:,j)=p1+searchsteps(j)*dirRefrac;
end


for j=1:length(searchpoints)
    if searchpoints(3,j)<47 && searchpoints(3,j)>3
        rad1=1.5; 
    else
        rad1=4.5;
    end
    rad2=sqrt(2*rad1^2);  % rad2 is the search radius
    for i=1:length(Vertices(:,1,1))
        if norm(permute(Vertices(i,1,:),[3,2,1])-searchpoints(:,j))<rad2
            %for k=1:size(Surface.BoundaryFacets,1)
            k=0;
            while Vertices(i,2+2*k,1)~=-100 && k<=8
                facet=Vertices(i,2+2*k,:);
                triangle=Vertices(facet,1,:);
                X=linsolve([-dirRefrac',(triangle(2,:)-triangle(1,:))',(triangle(3,:)-triangle(1,:))'],searchpoints(:,j)-triangle(1,:)');
                if X(2)>=0 && X(3)>=0 && X(2)+X(3)<=1 && dot(permute(Vertices(i,3+2*k,:),[2,3,1]),dirRefrac)>0
                    p2=searchpoints(:,j)+X(1)*dirRefrac';
                    searchover=1;
                    break
                end
                k=k+1;
            end
        end
        if searchover==1
            break
        end
    end
    if searchover==1
        break
    end
end
toc
%}



%plot(Surface.AlphaShape,'FaceAlpha',0.3);
%hold on

plot3(triangle(1:2,1),triangle(1:2,2),triangle(1:2,3),'k')
hold on
plot3(triangle(2:3,1),triangle(2:3,2),triangle(2:3,3),'k')
plot3(triangle([1,3],1),triangle([1,3],2),triangle([1,3],3),'k')

plot3([p1(1)-a*dirRay(1),p1(1)],[p1(2)-a*dirRay(2),p1(2)],[p1(3)-a*dirRay(3),p1(3)],'b')
%plot3([p1(1),searchpoints(1,j)],[p1(2),searchpoints(2,j)],[p1(3),searchpoints(3,j)],'b')
plot3(p2(1),p2(2),p2(3),'r*')
%plot3(searchpoints(1,j),searchpoints(2,j),searchpoints(3,j),'b*')
plot3(Surface.Vertices(i,1),Surface.Vertices(i,2),Surface.Vertices(i,3),'m+')

plot3([p1(1),p2(1)],[p1(2),p2(2)],[p1(3),p2(3)],'b')
hold off