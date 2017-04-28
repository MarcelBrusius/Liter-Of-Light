function printRays( Light, lambda )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

G = gca;

[n,~] = size(Light.Origin);
for raynum = 1:n
    plot3(G,[Light.Origin(raynum,1), Light.Origin(raynum,1)+lambda*Light.Direction(raynum,1)],...
            [Light.Origin(raynum,2), Light.Origin(raynum,2)+lambda*Light.Direction(raynum,2)],...
            [Light.Origin(raynum,3), Light.Origin(raynum,3)+lambda*Light.Direction(raynum,3)], 'b-')
end

