clear

% Obj = stlread('Bottle_Cola.stl');
% vert = unique(Obj.vertices,'rows');
% csvwrite('ExportBottle.dat',vert(:,3))

% save('Bottle2.mat',vert)
loaded = load('Bottle2.mat');
vert = loaded.vert;

F = figure(1);

G = gca;
hold on

init = struct;

Surface = createSurface(vert);

% new struct for light rays:
x = [0 0.5 1.25];
Origin = 5*(2*rand(10,3)-1)+160*x/norm(x);
% Origin = 5*(2*x/norm(x)-1)+80*x/norm(x);
Direction = [0 -.75 -1];
Light = createLight(Direction,Origin);

[R,T] = RayTrace(Surface,Light);

init.Origin = R.Origin;
init.Direction = Light.Direction;
printRays(init,-30,'y-');

height = 10;

% Ind = [2*(1:(2^(height-1)-1))', 2*(1:(2^(height-1)-1))'+1];
% Ind(Ind>(2^(height)-1)) = 0;

% C = cell(2^(height)-1,2);

above_roof = 40;
h = waitbar(0,['Calculating...', num2str(0), '%']);

for i = 2:height
    [T,R] = RayTrace(Surface,R);
%     C{floor(i/2)
%     C{i,1} = T;
    % print rays, and ignore those originating under the "roof" (threshold):
    T.Direction = T.Direction(T.Origin(:,3)<above_roof,:);
    T.Origin = T.Origin(T.Origin(:,3)<above_roof,:);
    printRays(T,20,'b-');
%     C{i,2} = R;
    waitbar(i/height,h,['Calculating...', num2str(100*i/height), '%']);
end
close(h)

% G.ZLim = [-20, 80];
% G.XLim = [-25, 25];
% G.YLim = [-25, 25];

