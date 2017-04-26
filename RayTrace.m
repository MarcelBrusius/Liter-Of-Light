function [ Refraction ] = RayTrace( Surface , Light , varargin)
%RAYTRACE Computes ray tracing for light rays
%   Computes intersection of light rays given in Light.Origin with
%   direction Light.Direction onto a triangular surface given in Surface
%   with vertices Surface.Vertices and boundary facets
%   Surface.BoundaryFacets
%
%   Return a struct containing the intersection points of rays with
%   triangles on surface as Refraction.Origin and their direction via
%   Fresnel's equations and Snell's Law (external function)

    if numel(varargin) == 1
        flag = varargin{1};
    elseif numel(varargin) == 0
        flag = 0;
    else
        error('Too many input arguments');
    end
    
    G = gca; %get current axes

    Contact.RayNumber = zeros(numel(Light.Origin)/3);
    Contact.Vertex = zeros(size(Light.Origin));
    Contact.BoundaryFacet = zeros(size(Light.Origin));
    Contact.Ray_t = zeros(numel(Light.Origin)/3,1);
    Contact.Mask = false(numel(Surface.BoundaryFacets)/3,1);
    Contact.Facet = zeros(numel(Light.Origin),1);
    
    Refraction.Direction = zeros(size(Surface.BoundaryFacets));
    Refraction.Origin = zeros(numel(Light.Origin)/3,3);

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
                if (Contact.Ray_t(raynum) == 0)
                    Contact.Ray_t(raynum) = t;
                    Contact.Facet(raynum) = i;
                    Contact.RayNumber(i) = raynum;
                elseif (Contact.Ray_t(raynum) > t)
                    Contact.Ray_t(raynum) = t;
                    Contact.Facet(raynum) = i;
                    Contact.RayNumber(i) = raynum;
                end
            end
        end
        if Contact.Facet(raynum)>0
            Contact.Vertex(raynum,:) = Light.Origin(raynum,:) + Contact.Ray_t(raynum)*Light.Direction(numray,:);
            Contact.BoundaryFacets(raynum,:) = Surface.BoundaryFacets(i,:);
            Contact.Mask(Contact.Facet(raynum)) = true;
            if flag == 1
                plot3(G,Contact.Vertex(raynum,1), Contact.Vertex(raynum,2), Contact.Vertex(raynum,3), 'r*')
            end


            nAir = 1;
            nWater = 1.33;
            Refraction.Origin = Contact.Vertex;
            Refraction.Direction(Contact.Facet(raynum),:) = refractLight(Surface.Normal(Contact.Facet(raynum),:), Light.Direction(raynum,:), nAir, nWater);
    %         Reflection.Direction = reflectLight(Contact, Light, nAir, nWater);
            plot3(G,Light.Origin(raynum,1),Light.Origin(raynum,2),Light.Origin(raynum,3),'bx');
            hold on

            plot3(G,[Light.Origin(raynum,1), Light.Origin(raynum,1)+Contact.Ray_t(raynum)*Light.Direction(numray,1)],...
                    [Light.Origin(raynum,2), Light.Origin(raynum,2)+Contact.Ray_t(raynum)*Light.Direction(numray,2)],...
                    [Light.Origin(raynum,3), Light.Origin(raynum,3)+Contact.Ray_t(raynum)*Light.Direction(numray,3)], 'b-')
        end
    end
    Refraction.Direction = Refraction.Direction(Contact.Mask,:);
    Refraction.Origin = Refraction.Origin(Contact.Mask,:);
end

