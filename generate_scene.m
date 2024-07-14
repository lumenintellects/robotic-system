% Initialise the zmqRemoteApi MATLAB client
addpath('/Applications/coppeliaSim.app/Contents/Resources/programming/zmqRemoteApi/clients/matlab');
client = RemoteAPIClient();

% Define paths to models (ensure these paths are correct)
% To test it on Windows env make sure you changed the path variables like addpath, woodenFloorModelPath, chairModelPath etc.
woodenFloorModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/infrastructure/floors/5mX5m wooden floor.ttm';
chairModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/furniture/chairs/dining chair.ttm';
tableModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/furniture/tables/diningTable.ttm';
plantModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/furniture/plants/indoorPlant.ttm';

% Initialize without parameters
sim = client.getObject('sim');

% Function to place objects
function placeObject(sim, modelPath, position, orientation)
    if isfile(modelPath)
        [objectHandle] = sim.loadModel(modelPath);
        sim.setObjectPosition(objectHandle, -1, position);
        sim.setObjectOrientation(objectHandle, -1, orientation);
    else
        error('Model file does not exist: %s', modelPath);
    end
end

% Create wooden floors to cover 10x5 meters area
placeObject(sim, woodenFloorModelPath, [-2.5, -1.5, 0], [0, 0, 0]); % Bottom-left floor
placeObject(sim, woodenFloorModelPath, [2.5, -1.5, 0], [0, 0, 0]);  % Bottom-right floor
placeObject(sim, woodenFloorModelPath, [-2.5, 1.5, 0], [0, 0, 0]);  % Top-left floor
placeObject(sim, woodenFloorModelPath, [2.5, 1.5, 0], [0, 0, 0]);   % Top-right floor

% Wall properties
wallHeight = 1.5;
wallThickness = 0.1;

% Function to create a wall
function createWall(sim, startPoint, endPoint, wallThickness, wallHeight)
    length = norm(endPoint - startPoint);
    midPoint = (startPoint + endPoint) / 2;
    angle = atan2(endPoint(2) - startPoint(2), endPoint(1) - startPoint(1));
    
    [wallHandle] = sim.createPrimitiveShape(sim.primitiveshape_cuboid, [length, wallThickness, wallHeight], 1);
    sim.setObjectPosition(wallHandle, -1, [midPoint(1), midPoint(2), wallHeight / 2]);
    sim.setObjectOrientation(wallHandle, -1, [0, 0, angle]);
end

% Create walls based on the new image
createWall(sim, [-5, -4], [5, -4], wallThickness, wallHeight);  % Bottom
createWall(sim, [-5, -4], [-5, 4], wallThickness, wallHeight);  % Left
createWall(sim, [5, -4], [5, 4], wallThickness, wallHeight);    % Right
createWall(sim, [-5, 4], [5, 4], wallThickness, wallHeight);    % Top

% Inner walls
createWall(sim, [-2.5, -3], [-2.5, 0], wallThickness, wallHeight);  % Vertical left
createWall(sim, [-2.5, 0], [0, 0], wallThickness, wallHeight);        % Horizontal bottom
createWall(sim, [0, 0], [0, 1.5], wallThickness, wallHeight);         % Vertical right
createWall(sim, [0, 1.5], [2.5, 1.5], wallThickness, wallHeight);     % Horizontal top
createWall(sim, [3.5, 4], [3.5, 1.5], wallThickness, wallHeight);     % Short vertical top-right

% Place furniture in the middle of rooms and central corners of the labyrinth
placeObject(sim, tableModelPath, [3.5, -2.3, 0.5], [0, -pi/2, 0]);  % Bottom-right room (rotate around y-axis)
placeObject(sim, chairModelPath, [3.5, -1.3, 0.5], [0, 0, 0]);    % Bottom-right room chair 1
placeObject(sim, chairModelPath, [2.2, -2.2, 0.5], [0, 0, pi/2]);    % Bottom-right room chair 2
placeObject(sim, plantModelPath, [-0.6, 1.1, 0.5], [0, 0, 0]);   % Top-left room
placeObject(sim, plantModelPath, [-4.5, 3.2, 0.5], [0, 0, 0]);   % Top-left room
placeObject(sim, plantModelPath, [-4.5, -3.5, 0.5], [0, 0, 0]);   % Top-left room
placeObject(sim, plantModelPath, [1.25, 0.75, 0.5], [0, 0, 0]);    % Center-right

disp('Environment created in CoppeliaSim. You can now interact with it in the CoppeliaSim window.');
