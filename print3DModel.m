
clear
close all;
tic
% Obj = stlread('Bottle_Cola.stl');
% vert = unique(Obj.vertices,'rows');
% csvwrite('ExportBottle.dat',vert(:,3))

% save('Bottle2.mat',vert)
loaded = load('Bottle.mat');
vert = 0.5*loaded.vert;


% Initialize some data vectors for later analysis
above_roof_vec=0:1:28; % choose numbers in [0,29]
IncidenceAngleVec = 180/pi*acos([0.197,0.424,0.627,0.792,0.908,0.968,0.966, ...
    0.904,0.785,0.618,0.413,0.186]); %Values for Venezuela (Caracas), June 16th 2017, [7,...,18] o'clock
InBottleVec = zeros(length(above_roof_vec),length(IncidenceAngleVec));
OnBottleVec = zeros(length(above_roof_vec),length(IncidenceAngleVec));
BottleIntensityVec = zeros(length(above_roof_vec),length(IncidenceAngleVec));
RelativeIntensity = BottleIntensityVec;

%number of sun rays
n_rays=100;

init = struct;
Surface = createSurface(vert);

EPS = 0.01;

% nice visualization of progess
h = waitbar(0,['Calculating...', num2str(0), '%']);

height = 10; % number of iterations of refraction/reflection
C = cell(length(above_roof_vec),length(IncidenceAngleVec),height);
iter = length(above_roof_vec)*length(IncidenceAngleVec);

% F = figure(1);
% plot(Surface.Bottle,'FaceAlpha',0.2,'FaceLighting','gouraud','BackFaceLighting','unlit');
% hold on
for i = 1:length(above_roof_vec)
    above_roof=above_roof_vec(i);
    for j=1:length(IncidenceAngleVec) %elevation angle,i.e. incidence angle w.r.t. the horizontal
        IncidenceAngle=IncidenceAngleVec(j);

        [Origin,Direction,Intensity] = chooseRays(above_roof, IncidenceAngle, n_rays);
        Direction=Direction/norm(Direction);

        Light = createLight(Direction,Origin);
        Light.Intensity=repmat(Intensity,[n_rays,1]);
% tic
        [R.Direction, R.Origin, R.Intensity, T.Direction, T.Origin, T.Intensity] = ...
            LiterofLight(Surface.Normal, Surface.Vertices, Surface.BoundaryFacets, ...
            Light.Direction, Light.Origin, Light.Intensity, false);
%         [R,T] = RayTrace(Surface,Light);  % R represents the rays that are transmitted, T the light rays that are reflected, (but the implementation is correct i think)
% toc
        % ignore rays that are below the "imaginary roof"
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
%         disp(['Radient flux on bottle surface: ',num2str(OnBottleVec(i,j))])
        InBottleVec(i,j)=sum(R.Intensity);
%         disp(['Radient flux transmitted into the bottle: ', ...
%             num2str(InBottleVec(i,j))])
        
        intensity = 0;
        
        C{i,j,1} = R;
%         printRays(R,7,'b');

        BottleIntensity=OnBottleVec(i,j);
        for k = 2:height
            if sum(R.Intensity) < EPS
                break;
            end
            [T.Direction, T.Origin, T.Intensity, R.Direction, R.Origin, R.Intensity] = ...
            LiterofLight(Surface.Normal, Surface.Vertices, Surface.BoundaryFacets, ...
            R.Direction, R.Origin, R.Intensity, true);
%             [T,R] = RayTrace(Surface,R);

            %ignore rays hitting the bottle cap
            R.Direction = R.Direction(R.Origin(:,3)<28.1,:);
            T.Direction = T.Direction(T.Origin(:,3)<28.1,:);

            R.Intensity=R.Intensity(R.Origin(:,3)<28.1,:);
            T.Intensity=T.Intensity(T.Origin(:,3)<28.1,:);

            R.Origin = R.Origin(R.Origin(:,3)<28.1,:);
            T.Origin = T.Origin(T.Origin(:,3)<28.1,:);

            % reflected rays, that carry too little power, will be ignored
            threshold=0.01/n_rays; % We will neglect <1% of the power in the bottle
            R.Direction = R.Direction(R.Intensity>threshold,:);
            R.Origin = R.Origin(R.Intensity>threshold,:);
            R.Intensity = R.Intensity(R.Intensity>threshold,:);

            % ignore rays originating under the "roof" (threshold):
            T.Direction = T.Direction(T.Origin(:,3)<above_roof,:);
            T.Intensity = T.Intensity(T.Origin(:,3)<above_roof,:);
            T.Origin = T.Origin(T.Origin(:,3)<above_roof,:);

            
            BottleIntensity=BottleIntensity + sum(T.Intensity);
            C{i,j,k} = T;
%             printRays(T,10,'b');

%             disp(['Radient flux emitted from bottle under the roof: ', ...
%                 num2str(sum(T.Intensity))]);
        end
        x = (i-1)*length(IncidenceAngleVec);
        waitbar((x+j)/iter,h,['Calculating...', ...
            num2str(round(100*((i-1)*length(IncidenceAngleVec)+j)/iter)), '%']);

        BottleIntensityVec(i,j)=BottleIntensity;
%         disp(['Total radient flux emitted from bottle under the roof: ', ...
%             num2str(BottleIntensity)])
    end
end
close(h)

clear('vert');

toc

[row, col] = find(BottleIntensityVec == max(max(BottleIntensityVec)));


disp(['            Initial intensity : ', num2str(sum(C{row,col,1}.Intensity))]);
disp(['Resulting intensity (maximal) : ', num2str(BottleIntensityVec(row,col))]);
disp(['         Efficiency (maximal) : ', num2str(BottleIntensityVec(row,col)/...
    sum(C{row,col,1}.Intensity))]);

% Print results only if requested ( printresults == 1 ):
% printresults = 0;
printresults = chooseDialog;

x = ['b'; 'r'; 'g'; 'k'; 'm'; 'c'];

if printresults
    % resizes the output windows
    G = gca;
    G.ZLim = [-10, 40];
    G.XLim = [-15, 15];
    G.YLim = [-15, 15];
    F = figure(1);
    plot(Surface.Bottle,'FaceAlpha',0.2,'FaceLighting','gouraud','BackFaceLighting','unlit');
    hold on;
    printRays(Light,10,'y');
    for i = 1:6
        hold on;
        printRays(C{row,col,i},10,x(i));
    end
    % forces 3D view
    view(3)
end

hold off;