clear

% Obj = stlread('Cocacola_bottle.stl');
% vert = unique(Obj.vertices,'rows');
% csvwrite('ExportBottle.dat',vert(:,3))

% save('Bottle.mat',vert)
loaded = load('Bottle.mat');
vert = loaded.vert;

F = figure(1);

G = gca;
hold on

Surface = createSurface(vert);

% new struct for light rays:
x = [0 0.5 1.25];
% Origin = 5*(2*rand(10,3)-1)+80*x/norm(x);
Origin = 5*(2*x/norm(x)-1)+80*x/norm(x);
Direction = [0 -.75 -1];
Light = createLight(Direction,Origin);

[Refract, Reflect] = RayTrace(Surface,Light,1);

[T1,R1] = RayTrace(Surface,Refract,1);
[T2,R2] = RayTrace(Surface,T1,1);
[T3,R3] = RayTrace(Surface,R2,1);
% [T4,R4] = RayTrace(Surface,R3,1)
% [~,R] = RayTrace(Surface,R,1);
% [~,R] = RayTrace(Surface,R,1);
% [~,R] = RayTrace(Surface,R,1);
% 
% height = 5;
% 
% Ind = [2*(1:(2^(height-1)-1))', 2*(1:(2^(height-1)-1))'+1];
% Ind(Ind>(2^(height)-1)) = 0;
% 
% C = cell(2^(height)-1,1);
% C{1} = [Refract,Reflect];
% 
% for i = 2:2:2^(height)-1
%     [T,R] = RayTrace(Surface,C{floor(i/2)}(1),1);
%     C{ i } = [T,R];
%     
%     [T,R] = RayTrace(Surface,C{floor(i/2)}(2),1);
%     C{i+1} = [T,R];
% end
% 
% for i = 2^(height-1):2^(height)-1
%     RayTrace(Surface,C{i}(1),1);
%     RayTrace(Surface,C{i}(2),1);
% end
