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
%   Light.Intensity     : representing the intensity of the light rays,
%                         specified by Intensity

    G = gca; %get current axes

    % new struct for light rays:
    Light = struct;
    Light.Direction =  repmat(Direction/norm(Direction,2),[numel(Origin)/3,1]);
    Light.Origin = Origin;
    Light.Intensity= repmat(1000/(numel(Origin)/3),[numel(Origin)/3,1]);
end

