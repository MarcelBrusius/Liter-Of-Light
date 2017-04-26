function [ Direction ] = refractLight( Normal, Direction, nOutside, nInside )
%REFRACTLIGHT Calculate refraction of light at a surface
%   Compute refraction of light at a surface of an object given by
%   triangular patches using Snell's law
%
%   Light direction is given by Light.Direction, surface normal is given by
%   Surface.Normal. The refraction coefficients are given by nOutside and
%   nInside for the respective media

    % Calculate the direction of the refraction with Snells Law
%     nOutside=1; 
%     nInside=1.33;
    Direction = nOutside/nInside*cross(Norma,cross(-Normal,Direction)) ...
        - Normal*sqrt(1-(nOutside/nInside)^2*dot(cross(Normal,Direction),...
        cross(Normal,Direction))); % Snells Law (vector form)
    
    
%   Test for vectorized version:
    
%     cells = mat2cell(Surface.Normal(Contact_Mask)', size(Surface.Normal(Contact_Mask),2), ones(1,size(Surface.Normal(Contact_Mask),1)));
%     B = sparse(blkdiag(cells{:}));
%     
%     tmp1 = -Surface.Normal(Contact_Mask).*(Surface.Normal(Contact_Mask)*Light.Direction') + Light.Direction.*(diag(B'*B));
%     L_xt = [0 Light.Direction(3) -Light.Direction(2);...
%            -Light.Direction(3) 0 Light.Direction(1);...
%            Light.Direction(2) Light.Direction(1) 0];
%     tmp2 = sqrt(sum((L_xt*Surface.Normal(Contact_Mask)').^2,1));
% 
%     Direction = nOutside/nInside*tmp1 - sqrt(1-(nOutside/nInside)^2*tmp2)*Surface.Normal(Contact_Mask); % Snells Law (vector form)

end

