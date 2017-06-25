function printRays( Light, lambda, color )
%PRINTRAYS prints rays of light specified by Light
%   Light.Origin specifies the origin of the ray
%   Light.Direction specifies the direction of the ray
%   
%   lambda specifies the length of the ray
%
%   color specifies the color and line style, e.g. 'b-' for a blue line

G = gca;

[n,~] = size(Light.Origin);
for raynum = 1:n
    % print a light ray
    plot3(G,[Light.Origin(raynum,1), Light.Origin(raynum,1)+lambda*Light.Direction(raynum,1)],...
            [Light.Origin(raynum,2), Light.Origin(raynum,2)+lambda*Light.Direction(raynum,2)],...
            [Light.Origin(raynum,3), Light.Origin(raynum,3)+lambda*Light.Direction(raynum,3)], color)
end

