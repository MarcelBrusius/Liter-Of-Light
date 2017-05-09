function [R,T] = fresnel(n1,n2,c1,c2)
%FRESNEL computes the rate of reflection R
%and the rate of transmission T when light moves
%from medium M1 into medium M2, 
%using the fresnel equations.
%Input: - n1 refractive index from medium M1
%       - n2 refractive index from medium M2
%       - c1 cosine value of incidence angle
%       - c2 cosine value of refraction angle.

nrel=n2/n1;
frel=c2/c1;

%s-polarized light
rs=((-nrel*frel+1)/(nrel*frel+1))^2;
%p-polarized light
rp=((nrel-frel)/(nrel+frel))^2;
%assume unpolarised light
R=mean([rs,rp]);
%conservation of energy
T=1-R;

end

