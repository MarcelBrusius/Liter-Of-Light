function [ Reflection, Refraction ] = snellsLaw( Normal, Direction, n1, n2 )
%REFLECTLIGHT Calculate reflection and refraction of light at a surface
%   Compute reflection and refraction of light at a surface of an object 
%   given by triangular patches.
%
%   Light direction is given by Light.Direction, surface normal is given by
%   Surface.Normal. (The refraction coefficients are given by n1 and n2 for
%   the respective media).
%
%   http://www.thefullwiki.org/Snells_law

cos_theta_1 = dot(Normal, -Direction);
cos_theta_2 = sqrt(1-(n1/n2)^2*(1-cos_theta_1^2));

if 1-(n1/n2)^2*(1-cos_theta_1^2) > 0
    Refraction = (n1/n2)*Direction + ((n1/n2)*cos_theta_1 - sign(cos_theta_1)*cos_theta_2)*Normal;
    Refraction = Refraction/norm(Refraction,2);
else
    Refraction = [0,0,0];
end
    
Reflection = Direction + 2*cos_theta_1*Normal;
Reflection = Reflection/norm(Reflection,2);
end

