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
above_roof_vec=0:7:28; % choose numbers in [0,29]
IncidenceAngleVec = 180/pi*acos([0.197,0.424,0.627,0.792,0.908,0.968,0.966, ...
    0.904,0.785,0.618,0.413,0.186]); %Values for Venezuela (Caracas), June 16th 2017, [7,...,18] o'clock
InBottleVec = zeros(length(above_roof_vec),length(IncidenceAngleVec));
OnBottleVec = zeros(length(above_roof_vec),length(IncidenceAngleVec));
BottleIntensityVec = zeros(length(above_roof_vec),length(IncidenceAngleVec));

%number of sun rays
n_rays=20;

init = struct;
Surface = createSurface(vert);


% nice visualization of progess
h = waitbar(0,['Calculating...', num2str(0), '%']);

for i = 1:length(above_roof_vec)
    above_roof=above_roof_vec(i);
    for j=1:length(IncidenceAngleVec) %elevation angle,i.e. incidence angle w.r.t. the horizontal
        IncidenceAngle=IncidenceAngleVec(j);

        [Origin,Direction,Intensity] = chooseRays(above_roof, IncidenceAngle, n_rays);
        Direction=Direction/norm(Direction);

        Light = createLight(Direction,Origin);
        Light.Intensity=repmat(Intensity,[n_rays,1]);

        [R,T] = RayTrace(Surface,Light);  % R represents the rays that are transmitted, T the light rays that are reflected, (but the implementation is correct i think)

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
        disp(['Radient flux on bottle surface: ',num2str(OnBottleVec(i,j))])
        InBottleVec(i,j)=sum(R.Intensity);
        disp(['Radient flux transmitted into the bottle: ',num2str(InBottleVec(i,j))])

        height = 10; % number of iterations of refraction/reflection
        intensity = 0;

        C = cell(height,1);

        BottleIntensity=0;
        for k = 2:height
            [T,R] = RayTrace(Surface,R);

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

            % print rays, and ignore those originating under the "roof" (threshold):
            T.Direction = T.Direction(T.Origin(:,3)<above_roof,:);
            T.Intensity = T.Intensity(T.Origin(:,3)<above_roof,:);
            T.Origin = T.Origin(T.Origin(:,3)<above_roof,:);

            
            BottleIntensity=BottleIntensity + sum(T.Intensity);
            C{k} = T;

            disp(['Radient flux emitted from bottle under the roof: ',num2str(sum(T.Intensity))]);
        end
        waitbar(((i-1)*length(above_roof_vec)+j)/(length(above_roof_vec)*length(above_roof_vec))...
            ,h,['Calculating...', num2str(100*((i-1)*length(above_roof_vec)+j)/...
            (length(above_roof_vec)*length(above_roof_vec))), '%']);

        BottleIntensityVec(i,j)=BottleIntensity;
        disp(['Total radient flux emitted from bottle under the roof: ',num2str(BottleIntensity)])
    end
end
close(h)

clear('vert');

toc

disp(['            Initial intensity : ', num2str(sum(Light.Intensity))]);
disp(['Resulting intensity (maximal) : ', num2str(max(sum(BottleIntensityVec)))]);
disp(['         Efficiency (maximal) : ', num2str(max(sum(BottleIntensityVec))/sum(Light.Intensity))]);


% resizes the output windows
G.ZLim = [-10, 40];
G.XLim = [-15, 15];
G.YLim = [-15, 15];

view(3);

% Print results only if requested ( printresults == 1 ):
% printresults = 0;
printresults = chooseDialog;

if printresults
    F = figure(1);
    G = gca;
    plot(Surface.Bottle,'FaceAlpha',0.2,'FaceLighting','gouraud','BackFaceLighting','unlit');
    for i = 2:height
        printRays(C{i},10,'b-');
    end
end
% forces 3D view
view(3)

hold off;