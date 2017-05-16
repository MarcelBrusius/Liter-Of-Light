function [ Reflection, Refraction, ReflectionIntensity, RefractionIntensity] = snellsLaw( Normal, Direction, Intensity, n1, n2 )
%REFLECTLIGHT Calculate reflection and refraction of a light ray at the bottle surface
%   http://www.thefullwiki.org/Snells_law
%   Output:
%   - Reflection: Direction vector of reflected light ray
%   - Refraction: Direction vector of refracted light ray 
%   - ReflectionIntensity: Calculate the intensity of light, that is reflected
%   - RefractionIntensity: Calculate the intensity of light, that is refracted
%   Input:
%   - Normal: Normal vector of the penetrated triangle
%   - Direction: Direction of the incident light ray
%   - Intensity: Intensity of incident light ray
%   - n1: Refractive index of the medium, where the light ray is coming from
%   - n2: Refractive index of the medium of the transmitted light ray



Normal=Normal/norm(Normal,2);
Direction=Direction/norm(Direction,2);
cos_theta_1 = dot(Normal, -Direction);  % angle of incident light ray
cos_theta_2 = sqrt(1-(n1/n2)^2*(1-cos_theta_1^2)); % angle of refracted light ray

if 1-(n1/n2)^2*(1-cos_theta_1^2) > 0  % check for total reflection
    Refraction = (n1/n2)*Direction + ((n1/n2)*cos_theta_1 - sign(cos_theta_1)*cos_theta_2)*Normal;
    Refraction = Refraction/norm(Refraction,2);
    
    %Method 1: Assume plastic doesn't change intensities
    %%{
    [ReflectionRate, RefractionRate]=fresnel(n1,n2,cos_theta_1,cos_theta_2);
    ReflectionIntensity= Intensity* ReflectionRate;
    RefractionIntensity= Intensity* RefractionRate;
    %}
    
    % Method 2: Calculate multiple intensity splitting due to the plastic layer
    %{
    n3=1.5; % refractive index of plastic, i.e. the middle layer
    cos_theta_13 = sqrt(1-(n1/n3)^2*(1-cos_theta_1^2));
    [R13,T13]=fresnel(n1,n3,cos_theta_1,cos_theta_13);
    [R31,T31]=fresnel(n3,n1,cos_theta_13,cos_theta_1);
    [R32,~]=fresnel(n3,n2,cos_theta_13,cos_theta_2);
    newRefIntensity = Intensity*T13*R32*T31;
    ReflectionIntensity = Intensity*R13; % first (direct) reflection
    tol=0.0001; % If changes in intensity are low, the recursion will be stopped
    counter=0;
    while newRefIntensity*R32*R31 > tol
        newRefIntensity=newRefIntensity*R32*R31;
        ReflectionIntensity=ReflectionIntensity + newRefIntensity;
        counter=counter+1;
    end
    RefractionIntensity = Intensity - ReflectionIntensity;
    %}
    
    
       
else
    Refraction = [0,0,0];
    ReflectionIntensity=Intensity;
    RefractionIntensity=0;
end
    
Reflection = Direction + 2*cos_theta_1*Normal;
Reflection = Reflection/norm(Reflection,2);
end

