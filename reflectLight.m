function [ Direction ] = reflectLight( Surface,Light ,NumFacet)
%REFLECTLIGHT Calculate reflection of light at a surface
%   Compute reflection of light at a surface of an object given by
%   triangular patches.
%
%   Light direction is given by Light.Direction, surface normal is given by
%   Surface.Normal. (The refraction coefficients are given by nOutside and
%   nInside for the respective media).

Direction = Light.Direction - dot(Surface.Normal(NumFacet,:),Light.Direction)*Surface.Normal(NumFacet,:);

end

