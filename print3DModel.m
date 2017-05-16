clear
tic
% Obj = stlread('Bottle_Cola.stl');
% vert = unique(Obj.vertices,'rows');
% csvwrite('ExportBottle.dat',vert(:,3))

% save('Bottle2.mat',vert)
loaded = load('Bottle.mat');
vert = 0.5*loaded.vert;


% Initialize some data vectors for later analysis
above_roof_vec=0:7:28; % choose numbers in [0,29]
IncidenceAngleVec=180/pi*acos([0.197,0.424,0.627,0.792,0.908,0.968,0.966,0.904,0.785,0.618,0.413,0.186]); %Values for Venezuela (Caracas), June 16th 2017, [7,...,18] o'clock
InBottleVec=zeros(length(above_roof_vec),length(IncidenceAngleVec));
OnBottleVec=zeros(length(above_roof_vec),length(IncidenceAngleVec));
BottleIntensityVec=zeros(length(above_roof_vec),length(IncidenceAngleVec));
for i = 1:length(above_roof_vec)
above_roof=above_roof_vec(i);
for j=1:length(IncidenceAngleVec) %elevation angle,i.e. incidence angle w.r.t. the horizontal
IncidenceAngle=IncidenceAngleVec(j);
    
%number of sun rays
n_rays=20;

[Origin,Direction,Intensity] = chooseRays(above_roof, IncidenceAngle, n_rays);
Direction=Direction/norm(Direction);

F = figure(1);

G = gca;
hold on

init = struct;

Surface = createSurface(vert);

Light = createLight(Direction,Origin);
Light.Intensity=repmat(Intensity,[n_rays,1]);

[R,T] = RayTrace(Surface,Light);  % R represents the rays that are transmitted, T the light rays that are reflected, (but the implementation is correct i think)

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
OnBottleVec(i,j)=sum(R.Intensity)+sum(T.Intensity);
disp(['Radient flux on bottle surface: ',num2str(OnBottleVec(i,j))])
InBottleVec(i,j)=sum(R.Intensity);
disp(['Radient flux transmitted into the bottle: ',num2str(InBottleVec(i,j))])

init.Origin = R.Origin;
init.Direction=Light.Direction;
%init.Direction = Light.Direction(R.Origin(:,3)>above_roof,:);
printRays(init,-10,'y-');



height = 10; % number of iterations of refraction/reflection

% Ind = [2*(1:(2^(height-1)-1))', 2*(1:(2^(height-1)-1))'+1];
% Ind(Ind>(2^(height)-1)) = 0;

% C = cell(2^(height)-1,2);


% nice visualization of progess
h = waitbar(0,['Calculating...', num2str(0), '%']);

BottleIntensity=0;
for k = 2:height
        [T,R] = RayTrace(Surface,R);
%     C{floor(i/2)
%     C{i,1} = T;
    % reflected rays, that carry too little power, will be ignored
    threshold=0.01/n_rays; % We will neglect <1% of the power in the bottle
    R.Direction = R.Direction(R.Intensity>threshold,:);
    R.Origin = R.Origin(R.Intensity>threshold,:);
    R.Intensity = R.Intensity(R.Intensity>threshold,:);
    
    % print rays, and ignore those originating under the "roof" (threshold):
    T.Direction = T.Direction(T.Origin(:,3)<above_roof,:);
    T.Intensity = T.Intensity(T.Origin(:,3)<above_roof,:);
    T.Origin = T.Origin(T.Origin(:,3)<above_roof,:);
    %disp(length(T.Origin))
    %printRays(T,10,'b-');
%     C{i,2} = R;
    waitbar(k/height,h,['Calculating...', num2str(100*k/height), '%']);
    BottleIntensity=BottleIntensity + sum(T.Intensity);
    disp(['Iteration: ',num2str(k),', Radient flux emitted from bottle under the roof: ',num2str(sum(T.Intensity))]);
end
BottleIntensityVec(i,j)=BottleIntensity;
disp(['Total radient flux emitted from bottle under the roof: ',num2str(BottleIntensity)])
close(h)
end
end

clear('vert');

% forces 3D view
view(3)


% resizes the output windows
G.ZLim = [-10, 40];
G.XLim = [-15, 15];
G.YLim = [-15, 15];

view(3);
toc