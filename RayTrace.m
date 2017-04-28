function [ Refraction, Reflection ] = RayTrace( Surface , Light , varargin)
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
    else
        error('Too many input arguments');
    end
    
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
        if Surface.Bottle.inShape(Light.Origin(raynum,:))
            Normal = -Surface.Normal;
            possiblelightrays = find(Normal*Light.Direction(raynum,:)'~=0);
            n2 = 1;
            n1 = 1.33;
        else
            Normal = Surface.Normal;
            possiblelightrays = find(Normal*Light.Direction(raynum,:)'~=0);
            n1 = 1;
            n2 = 1.33;
        end
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
                elseif (Contact.Ray_t(raynum) > t)
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
            if flag == 1
%                 plot3(G,Contact.Vertex(raynum,1), Contact.Vertex(raynum,2), Contact.Vertex(raynum,3), 'r*')
%                 hold on
%                 plot3(G,Light.Origin(raynum,1),Light.Origin(raynum,2),Light.Origin(raynum,3),'bx');
                hold on
                plot3(G,[Light.Origin(raynum,1), Light.Origin(raynum,1)+Contact.Ray_t(raynum)*Light.Direction(raynum,1)],...
                        [Light.Origin(raynum,2), Light.Origin(raynum,2)+Contact.Ray_t(raynum)*Light.Direction(raynum,2)],...
                        [Light.Origin(raynum,3), Light.Origin(raynum,3)+Contact.Ray_t(raynum)*Light.Direction(raynum,3)], 'r-')
            end
            
            Refraction.Origin(raynum,:) = Contact.Vertex(raynum,:);
            Reflection.Origin(raynum,:) = Contact.Vertex(raynum,:);
            
            [Reflection.Direction(raynum,:),Refraction.Direction(raynum,:)]...
                = snellsLaw(Normal(Contact.Facet(raynum),:), Light.Direction(raynum,:), n1, n2);
        end
    end
    
    Refraction.Direction = Refraction.Direction(Contact.Mask,:);
    Refraction.Origin = Refraction.Origin(Contact.Mask,:);
    
    Reflection.Direction = Reflection.Direction(Contact.Mask,:);
    Reflection.Origin = Reflection.Origin(Contact.Mask,:);
end

