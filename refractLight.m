function [ Direction ] = refractLight( Surface, Light, nOutside, nInside )
%REFRACTLIGHT Calculate refraction of light at a surface
%   Compute refraction of light at a surface of an object given by
%   triangular patches using Snell's law.
%
%   Light direction is given by Light.Direction, surface normal is given by
%   Surface.Normal. The refraction coefficients are given by nOutside and
%   nInside for the respective media.

    Direction = nOutside/nInside*cross(Surface.Normal,cross(-Surface.Normal,Light.Direction)) ...
        - Surface.Normal*sqrt(1-(nOutside/nInside)^2*dot(cross(Surface.Normal,Light.Direction),...
        cross(Surface.Normal,Light.Direction))); % Snells Law (vector form)
end

