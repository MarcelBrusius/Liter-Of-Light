function [ Reflection, Refraction ] = snellsLaw( Normal, Direction, n1, n2 )
%REFLECTLIGHT Calculate reflection of light at a surface
%   Compute reflection of light at a surface of an object given by
%   triangular patches.
%
%   Light direction is given by Light.Direction, surface normal is given by
%   Surface.Normal. (The refraction coefficients are given by nOutside and
%   nInside for the respective media).

% Reflection = Direction - 2*dot(Normal,Direction)/(norm(Normal,2)^2)*Normal;

cos_theta_1 = dot(Normal, -Direction);
cos_theta_2 = sqrt(1-(n1/n2)^2*(1-cos_theta_1^2));

if cos_theta_1 > 0
    Refraction = (n1/n2)*Direction + ((n1/n2)*cos_theta_1 - cos_theta_2)*Normal;
    Refraction = Refraction/norm(Refraction,2);
else
    Refraction = (n1/n2)*Direction + ((n1/n2)*cos_theta_1 + cos_theta_2)*Normal;
    Refraction = Refraction/norm(Refraction,2);
end

Reflection = Direction + 2*cos_theta_1*Normal;
Reflection = Reflection/norm(Reflection,2);


end

