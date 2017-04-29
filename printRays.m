function printRays( Light, lambda, color )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

G = gca;

[n,~] = size(Light.Origin);
for raynum = 1:n
    plot3(G,[Light.Origin(raynum,1), Light.Origin(raynum,1)+lambda(raynum)*Light.Direction(raynum,1)],...
            [Light.Origin(raynum,2), Light.Origin(raynum,2)+lambda(raynum)*Light.Direction(raynum,2)],...
            [Light.Origin(raynum,3), Light.Origin(raynum,3)+lambda(raynum)*Light.Direction(raynum,3)], color)
end

