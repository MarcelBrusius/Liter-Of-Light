function [ Refraction, Reflection ] = RayTrace( Surface , Light )
%RAYTRACE Computes ray tracing for light rays
%   Computes intersection of light rays given in Light.Origin with
%   direction Light.Direction onto a triangular surface given in Surface
%   with vertices Surface.Vertices and boundary facets
%   Surface.BoundaryFacets
%
%   Return a struct containing the intersection points of rays with
%   triangles on surface as Refraction.Origin and their direction via
%   Fresnel's equations and Snell's Law (external function)

    Contact.RayNumber = zeros(size(Surface.Illuminated));
    Contact.Vertex = zeros(size(Light.Origin));
    Contact.BoundaryFacet = zeros(size(Light.Origin));
    Contact.Ray_t = zeros(numel(Light.Origin)/3,1);

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
                elseif (Contact.Ray_t(raynum) > t)
                    Contact.Ray_t(raynum) = t;
                end
            end
        end
        Contact.RayNumber(i) = raynum;
        Contact.Vertex(raynum,:) = Light.Origin(raynum,:) + Contact.Ray_t(raynum)*Light.Direction;
        Contact.BoundaryFacets(raynum,:) = Surface.BoundaryFacets(i,:);
        plot3(Contact.Vertex(raynum,1), Contact.Vertex(raynum,2), Contact.Vertex(raynum,3), 'r*')

        nAir = 1;
        nWater = 1.33;
        Refraction.Origin = Contact.Vertex;
        Refraction.Direction = refractLight(Contact, Light, nAir, nWater);
%         Reflection.Direction = reflectLight(Contact, Light, nAir, nWater);
        
    end
end

