function [ Light ] = createLight( Direction, Origin, varargin )
%CREATELIGHT Creates a light object
%   flag: controls if light rays should be displayed (dev only)
%
%   Light object contains the fields:
%
%   Light.Direction     : representing the direction of the light rays,
%                         specified by Direction
%   
%   Light.Origin        : representing the starting points of the light
%                         rays specified by Origin
%

    if numel(varargin) == 1
        flag = varargin{1};
    elseif numel(varargin) == 0
        flag = 0;
    else
        error('To many input arguments.');
    end
    
    G = gca; %get current axes

    % new struct for light rays:
    Light = struct;
    Light.Direction =  repmat(Direction/norm(Direction,2),[numel(Origin)/3,1]);
    Light.Origin = Origin;


    lambda = 90;
    if flag == 1
        plot3(G,Light.Origin(:,1),Light.Origin(:,2),Light.Origin(:,3),'x');
        hold on
        for i = 1:numel(Light.Origin)/3
            plot3(G,[Light.Origin(i,1), Light.Origin(i,1)+lambda*Light.Direction(1)],...
                  [Light.Origin(i,2), Light.Origin(i,2)+lambda*Light.Direction(2)],...
                  [Light.Origin(i,3), Light.Origin(i,3)+lambda*Light.Direction(3)], '-')
        end
    end

end

