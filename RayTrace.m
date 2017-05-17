function [Refraction,Reflection] = RayTrace( Surface , Light)
%RAYTRACE Computes ray tracing for light rays
%   Computes intersection of light rays given in Light.Origin with
%   direction Light.Direction onto a triangular surface given in Surface
%   with vertices Surface.Vertices and boundary facets
%   Surface.BoundaryFacets
%
%   Return a struct containing the intersection points of rays with
%   triangles on surface as Refraction.Origin and their direction via
%   Fresnel's equations and Snell's Law (external function)
    
%     G = gca; %get current axes
    
    % assert that the input variable "Light" is a matlab struct
    if isstruct(Light)
        [Origin_row, Origin_col] = size(Light.Origin);
    else
        pause;
    end
    
    % initialization of the contact structure containing:
    % - Raynumber: tells which ray is observed (they are numbered in some
    % way
    % - Vertices (Vertex): saves the vertives of the hit triangle
    % - Boundary Facets: indices specifying the corner points of the
    % triangle
    % - Ray_t: length of the ray from origin to hitting point
    % - Facet: gives the indices of the triangle for each ray
    % - Mask: tells if there really has been found a intersection point
    Contact.RayNumber = zeros(Origin_row,1);
    Contact.Vertex = zeros(Origin_row, Origin_col);
    Contact.BoundaryFacet = zeros(Origin_row, Origin_col);
    Contact.Ray_t = zeros(Origin_row,1);
    Contact.Mask = false(Origin_row,1);
    Contact.Facet = zeros(Origin_row,1);
    
    
    % initialization of the Refraction and Reflection struct:
    % - __.Direction specifies the direction of reflection and refraction,
    % respectively.
    % - __.Origin specifies the hitting point on the surface
    
    Refraction.Direction = zeros(Origin_row, Origin_col);
    Refraction.Origin = zeros(Origin_row, Origin_col);
    Refraction.Intensity = zeros(Origin_row, 1);
    
    Reflection.Direction = zeros(Origin_row, Origin_col);
    Reflection.Origin = zeros(Origin_row, Origin_col);
    Reflection.Intensity = zeros(Origin_row, 1);
    
    for raynum = 1:numel(Light.Origin)/3
        
        % Checking which light rays are poissibly hit by the light ray that
        % is currently observed
        %
        % NOTE: may be unstable!
        if norm(Light.Origin(raynum,:) - Surface.Bottle.Points(Surface.Bottle.nearestNeighbor(Light.Origin(raynum,:)),:),2) < 2.25
            possiblelightrays = find(Surface.Normal*Light.Direction(raynum,:)'>0);
        else
            possiblelightrays = find(Surface.Normal*Light.Direction(raynum,:)'<0);
        end
        for i = possiblelightrays'
%         for i = 1:numel(Surface.Normal)/3 % loop for checking every
                                            % single triangle
                                            
            % Defines the right hand side of the equation system that
            % results from the equations for the ray inserted in the
            % equation for the plane the triangle lies in:
            rs = Light.Origin(raynum,:)' - Surface.Vertices(Surface.BoundaryFacets(i,1),:)';
            % System matrix of the equation system:
            sysmat = [-Light.Direction(raynum,:)', ...
                Surface.Vertices(Surface.BoundaryFacets(i,2),:)'-Surface.Vertices(Surface.BoundaryFacets(i,1),:)',...
                Surface.Vertices(Surface.BoundaryFacets(i,3),:)'-Surface.Vertices(Surface.BoundaryFacets(i,1),:)']; % System matrix of equation
            sol = sysmat\rs;
            
            % assign the respective variables that represent the lenth of
            % the light direction vector, and the position of the point of
            % intersection w.r.t. baryzentric coordinates of the triangles
            t = sol(1);
            beta = sol(2);
            gamma = sol(3);

            % check for the conditions that:
            % - t>0: the intersection happens on the correct side of the
            % plane of origin (i.e. on the side of the bottle)
            % - gamma>0 & gamma<1: the intersetion lies on the part of the
            % plane given by two corner points
            % - beta>0 & beta<1: same for one point from above and the 
            % remaining point
            % - beta + gamma <1: it lies not outside the triangle
            if ((beta > 0 && beta < 1) && (gamma > 0 && gamma < 1) && (t >0) && (beta+gamma<1)) %what happens if gamma=1 | beta = 1?    
                if (Contact.Ray_t(raynum) == 0)
                    Contact.Ray_t(raynum) = t;
                    Contact.Facet(raynum) = i;
                    Contact.RayNumber(i) = raynum; % (1) 
                % just check if a closer intersection point has been found
                % and ignore some numerical error:
                elseif (Contact.Ray_t(raynum) > t && t > 10^-7)
                    Contact.Ray_t(raynum) = t;
                    Contact.Facet(raynum) = i;
                    Contact.RayNumber(i) = raynum; % (2)
                end
            end
        end
        
        % If a Facet is found for the observed ray, then it has a strictly
        % positive value at the respective point: (see (1), (2))
        if Contact.Facet(raynum)>0
            % just some assigning of variables:
            Contact.Vertex(raynum,:) = Light.Origin(raynum,:) + Contact.Ray_t(raynum)*Light.Direction(raynum,:);
            Contact.BoundaryFacets(raynum,:) = Surface.BoundaryFacets(i,:);
            Contact.Mask(raynum) = true;
            
            % just some plotting (if wanted):
%             plot3(G,Contact.Vertex(raynum,1), Contact.Vertex(raynum,2), Contact.Vertex(raynum,3), 'r*')
%             hold on
%           plot3(G,Light.Origin(raynum,1),Light.Origin(raynum,2),Light.Origin(raynum,3),'bx');
%             hold on
%             plot3(G,[Light.Origin(raynum,1), Contact.Vertex(raynum,1)],...
%                     [Light.Origin(raynum,2), Contact.Vertex(raynum,2)],...
%                     [Light.Origin(raynum,3), Contact.Vertex(raynum,3)], 'r-')
            
            % further assigning variables:
            Refraction.Origin(raynum,:) = Contact.Vertex(raynum,:);
            Reflection.Origin(raynum,:) = Contact.Vertex(raynum,:);
            
            % compute new ray directions using Snell's Law
            %if Surface.Bottle.inShape(Light.Origin(raynum,:))
            if norm(Light.Origin(raynum,:) - Surface.Bottle.Points(Surface.Bottle.nearestNeighbor(Light.Origin(raynum,:)),:),2) < 2.25
                [Reflection.Direction(raynum,:),Refraction.Direction(raynum,:),...
                Reflection.Intensity(raynum,:),Refraction.Intensity(raynum,:)]...
                = snellsLaw(-Surface.Normal(Contact.Facet(raynum),:), Light.Direction(raynum,:),...
                  Light.Intensity(raynum,:), 1.33, 1);
            else
                [Reflection.Direction(raynum,:),Refraction.Direction(raynum,:),...
                Reflection.Intensity(raynum,:),Refraction.Intensity(raynum,:)]...
                = snellsLaw(Surface.Normal(Contact.Facet(raynum),:), Light.Direction(raynum,:),...
                Light.Intensity(raynum,:), 1, 1.33);
            end
        end
    end
    
    % ignore points and directions where no intersection has been found
    % (may be irrelevant, but not sure):
    Refraction.Direction = Refraction.Direction(Contact.Mask,:);
    Refraction.Origin = Refraction.Origin(Contact.Mask,:);
    Refraction.Intensity = Refraction.Intensity(Contact.Mask,:);
    
    Reflection.Direction = Reflection.Direction(Contact.Mask,:);
    Reflection.Origin = Reflection.Origin(Contact.Mask,:);
    Reflection.Intensity = Reflection.Intensity(Contact.Mask,:);

end

