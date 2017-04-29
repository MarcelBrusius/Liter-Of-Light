function [ Refraction, Reflection ] = RayTrace( Surface , Light)
%RAYTRACE Computes ray tracing for light rays
%   Computes intersection of light rays given in Light.Origin with
%   direction Light.Direction onto a triangular surface given in Surface
%   with vertices Surface.Vertices and boundary facets
%   Surface.BoundaryFacets
%
%   Return a struct containing the intersection points of rays with
%   triangles on surface as Refraction.Origin and their direction via
%   Fresnel's equations and Snell's Law (external function)
    
    G = gca; %get current axes

    [Origin_row, Origin_col] = size(Light.Origin);
    
    Contact.RayNumber = zeros(Origin_row,1);
    Contact.Vertex = zeros(Origin_row, Origin_col);
    Contact.BoundaryFacet = zeros(Origin_row, Origin_col);
    Contact.Ray_t = zeros(Origin_row,1);
    Contact.Mask = false(Origin_row,1);
    Contact.Facet = zeros(Origin_row,1);
    
    Refraction.Direction = zeros(size(Light.Origin));
    Refraction.Origin = zeros(size(Light.Origin));
    
    Reflection.Direction = zeros(size(Light.Origin));
    Reflection.Origin = zeros(size(Light.Origin));

    for raynum = 1:numel(Light.Origin)/3
        possiblelightrays = find(Surface.Normal*Light.Direction(raynum,:)'~=0);
        for i = possiblelightrays'
            rs = Light.Origin(raynum,:)' - Surface.Vertices(Surface.BoundaryFacets(i,1),:)'; % right hand side of equation
            sysmat = [-Light.Direction(raynum,:)', ...
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
                elseif (Contact.Ray_t(raynum) > t & t > 10^-7)
                    Contact.Ray_t(raynum) = t;
                    Contact.Facet(raynum) = i;
                    Contact.RayNumber(i) = raynum;
                end
            end
        end
        if Contact.Facet(raynum)>0
            Contact.Vertex(raynum,:) = Light.Origin(raynum,:) + Contact.Ray_t(raynum)*Light.Direction(raynum,:);
            Contact.BoundaryFacets(raynum,:) = Surface.BoundaryFacets(i,:);
            Contact.Mask(raynum) = true;
            plot3(G,Contact.Vertex(raynum,1), Contact.Vertex(raynum,2), Contact.Vertex(raynum,3), 'r*')
            hold on
%           plot3(G,Light.Origin(raynum,1),Light.Origin(raynum,2),Light.Origin(raynum,3),'bx');
            hold on
            plot3(G,[Light.Origin(raynum,1), Contact.Vertex(raynum,1)],...
                    [Light.Origin(raynum,2), Contact.Vertex(raynum,2)],...
                    [Light.Origin(raynum,3), Contact.Vertex(raynum,3)], 'r-')
            
            Refraction.Origin(raynum,:) = Contact.Vertex(raynum,:);
            Reflection.Origin(raynum,:) = Contact.Vertex(raynum,:);
            if Surface.Bottle.inShape(Light.Origin(raynum,:))
                [Reflection.Direction(raynum,:),Refraction.Direction(raynum,:)]...
                = snellsLaw(-Surface.Normal(Contact.Facet(raynum),:), Light.Direction(raynum,:), 1.33, 1);
            else
                [Reflection.Direction(raynum,:),Refraction.Direction(raynum,:)]...
                = snellsLaw(Surface.Normal(Contact.Facet(raynum),:), Light.Direction(raynum,:), 1, 1.33);
            end
        end
    end
    Refraction.Direction = Refraction.Direction(Contact.Mask,:);
    Refraction.Origin = Refraction.Origin(Contact.Mask,:);
    
    Reflection.Direction = Reflection.Direction(Contact.Mask,:);
    Reflection.Origin = Reflection.Origin(Contact.Mask,:);
end

