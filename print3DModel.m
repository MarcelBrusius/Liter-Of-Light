clear
close all;
tic
% Obj = stlread('Bottle_Cola.stl');
% vert = unique(Obj.vertices,'rows');
% csvwrite('ExportBottle.dat',vert(:,3))

% save('Bottle2.mat',vert)
loaded = load('Bottle.mat');
vert = 0.5*loaded.vert;

above_roof = 18;
%elevation angle,i.e. incidence angle w.r.t. the horizontal
IncidenceAngle=80;
%number of sun rays
n_rays=500;

[Origin,Direction,Intensity] = chooseRays(above_roof, IncidenceAngle, n_rays);
Direction=Direction/norm(Direction);

F = figure(1);

G = gca;
hold on

init = struct;

Surface = createSurface(vert);

clear('vert');

Light = createLight(Direction,Origin);
Light.Intensity=repmat(Intensity,[n_rays,1]);

[R,T] = RayTrace(Surface,Light);

% ignore rays that are above the "imaginary roof"
R.Direction = R.Direction(R.Origin(:,3)>above_roof,:);
T.Direction = T.Direction(T.Origin(:,3)>above_roof,:);

R.Intensity=R.Intensity(R.Origin(:,3)>above_roof,:);
T.Intensity=T.Intensity(T.Origin(:,3)>above_roof,:);

R.Origin = R.Origin(R.Origin(:,3)>above_roof,:);
T.Origin = T.Origin(T.Origin(:,3)>above_roof,:);

%ignore rays hitting the bottle cap

R.Direction = R.Direction(R.Origin(:,3)<28.1,:);
T.Direction = T.Direction(T.Origin(:,3)<28.1,:);

R.Intensity=R.Intensity(R.Origin(:,3)<28.1,:);
T.Intensity=T.Intensity(T.Origin(:,3)<28.1,:);

R.Origin = R.Origin(R.Origin(:,3)<28.1,:);
T.Origin = T.Origin(T.Origin(:,3)<28.1,:);

height = 10; % number of iterations of refraction/reflection
intensity = 0;

% nice visualization of progess
h = waitbar(0,['Calculating...', num2str(0), '%']);

BottleIntensity=0;
for i = 2:height
    [T,R] = RayTrace(Surface,R);

    % ignore rays that are above the "imaginary roof"
%     R.Direction = R.Direction(R.Origin(:,3)<above_roof,:);
    T.Direction = T.Direction(T.Origin(:,3)<above_roof,:);

%     R.Intensity=R.Intensity(R.Origin(:,3)<above_roof,:);
    T.Intensity=T.Intensity(T.Origin(:,3)<above_roof,:);

%     R.Origin = R.Origin(R.Origin(:,3)<above_roof,:);
    T.Origin = T.Origin(T.Origin(:,3)<above_roof,:);

    %ignore rays hitting the bottle cap

    R.Direction = R.Direction(R.Origin(:,3)<28.1,:);
    T.Direction = T.Direction(T.Origin(:,3)<28.1,:);

    R.Intensity=R.Intensity(R.Origin(:,3)<28.1,:);
    T.Intensity=T.Intensity(T.Origin(:,3)<28.1,:);

    R.Origin = R.Origin(R.Origin(:,3)<28.1,:);
    T.Origin = T.Origin(T.Origin(:,3)<28.1,:);

    % print rays, and ignore those originating under the "roof" (threshold):
    T.Direction = T.Direction(T.Origin(:,3)<above_roof,:);
    T.Origin = T.Origin(T.Origin(:,3)<above_roof,:);
    T.Intensity = T.Intensity(T.Origin(:,3)<above_roof,:);
    printRays(T,10,'b-');

    waitbar(i/height,h,['Calculating...', num2str(100*i/height), '%']);
    BottleIntensity=BottleIntensity + sum(T.Intensity);
end

close(h)

toc

% forces 3D view
view(3)

% resizes the output windows
G.ZLim = [-10, 40];
G.XLim = [-15, 15];
G.YLim = [-15, 15];

view(3);

disp(['Initial intensity:   ', num2str(sum(Light.Intensity))]);
disp(['Resulting intensity: ', num2str(BottleIntensity)]);
disp(['Efficiency:          ', num2str(BottleIntensity/sum(Light.Intensity))]);

hold off;