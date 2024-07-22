function Connect_CreateWall()
    
    % Initialise the zmqRemoteApi MATLAB client
    addpath('/Applications/coppeliaSim.app/Contents/Resources/programming/zmqRemoteApi/clients/matlab');
    client = RemoteAPIClient();

    % Initialize without parameters
    sim = client.getObject('sim');

    % Global variables to store motor handles and client
    global motorLeftHandle motorRightHandle simClient

    % Define paths to models (ensure these paths are correct)
    woodenFloorModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/infrastructure/floors/5mX5m wooden floor.ttm';
    chairModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/furniture/chairs/dining chair.ttm';
    tableModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/furniture/tables/diningTable.ttm';
    plantModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/furniture/plants/indoorPlant.ttm';
    robotModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/robots/mobile/pioneer p3dx.ttm';%change robot if required?
    laserScannerModelPath = '/Applications/coppeliaSim.app/Contents/Resources/models/components/sensors/2D laser scanner.ttm'; % Path to 2D laser scanner model

    % Explicitly remove specific objects by name
    objectsToRemove = {'Floor'}; % Add any other specific objects you want to remove

    for i = 1: length(objectsToRemove)
        try
            objectHandle = sim.getObject(objectsToRemove{i});
            if ~isempty(objectHandle)
                sim.removeObject(objectHandle);
                pause(0.1); % Add a short delay to ensure the object is removed
            end
        catch ME
            warning('Could not remove object %s: %s', objectsToRemove{i}, ME.message);
        end
    end

    % Function to place objects
    function objectHandle = placeObject(sim, modelPath, position, orientation)
        if isfile(modelPath)
            objectHandle = sim.loadModel(modelPath);
            sim.setObjectPosition(objectHandle, -1, position);
            sim.setObjectOrientation(objectHandle, -1, orientation);
        else
            error('Model file does not exist: %s', modelPath);
        end
    end

    % Create wooden floors to cover 10x5 meters area
    placeObject(sim, woodenFloorModelPath, [-2.5, 0, 0], [0, 0, 0]); % Bottom-left floor
    placeObject(sim, woodenFloorModelPath, [2.5, 0, 0], [0, 0, 0]); % Bottom-right floor

    % Wall properties
    wallHeight = 1;
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
    createWall(sim, [-5, -2.5], [5, -2.5], wallThickness, wallHeight); % Bottom
    createWall(sim, [-5, -2.5], [-5, 2.5], wallThickness, wallHeight); % Left
    createWall(sim, [5, -2.5], [5, 2.5], wallThickness, wallHeight); % Right
    createWall(sim, [-5, 2.5], [5, 2.5], wallThickness, wallHeight); % Top

    % Inner walls
    createWall(sim, [-2.5, -1.5], [-2.5, 0.5], wallThickness, wallHeight); % Vertical left
    createWall(sim, [-2.5, 0.5], [0, 0.5], wallThickness, wallHeight); % Horizontal bottom
    createWall(sim, [0, 1.5], [0, 0.5], wallThickness, wallHeight); % Vertical right
    createWall(sim, [0, 1.5], [1.5, 1.5], wallThickness, wallHeight); % Vertical right
    createWall(sim, [3.5, 2.5], [3.5, 1.5], wallThickness, wallHeight); % Short vertical top-right

    % Place furniture in the middle of rooms and central corners of the labyrinth
    placeObject(sim, tableModelPath, [4, -1.5, 0.4], [0, -pi/2, 0]); % Bottom-right room (rotate around y-axis)
    placeObject(sim, chairModelPath, [4, -0.5, 0.4], [0, 0, 0]); % Bottom-right room chair 1
    placeObject(sim, chairModelPath, [3, -1.5, 0.4], [0, 0, pi/2]); % Bottom-right room chair 2
    placeObject(sim, plantModelPath, [-0.5, 1, 0.2], [0, 0, 0]); % Top-left room
    placeObject(sim, plantModelPath, [-4.5, 2, 0.2], [0, 0, 0]); % Top-left room
    placeObject(sim, plantModelPath, [-4.5, -2, 0.2], [0, 0, 0]); % Top-left room
    placeObject(sim, plantModelPath, [0.5, 1, 0.2], [0, 0, 0]); % Center-right

    % Function to add a laser scanner to a robot
    function addLaserScanner(sim, robotHandle, laserScannerModelPath)
        % Load the laser scanner model
        laserScannerHandle = sim.loadModel(laserScannerModelPath);

        % Set the parent of the laser scanner to the robot
        sim.setObjectParent(laserScannerHandle, robotHandle, true);

        % Adjust the position and orientation of the laser scanner on the robot
        sim.setObjectPosition(laserScannerHandle, robotHandle, [0, 0, 0.15]);
        sim.setObjectOrientation(laserScannerHandle, robotHandle, [0, 0, -pi/2]);
    end

    % Function to remove Lua scripts from a robot
    function removeLuaScripts(sim, robotHandle)
        % Get the child script associated with the robot
        scriptHandle = sim.getScript(sim.scripttype_childscript, robotHandle);
        if scriptHandle ~= -1
            sim.removeScript(scriptHandle);
        end
    end

    % Place the robot in the environment
    robotHandle = placeObject(sim, robotModelPath, [0, 0, 0.22], [0, 0, 0]);

    % Remove Lua scripts from the robot
    removeLuaScripts(sim, robotHandle);

    % Get handles for the robot's motors
    motorLeftHandle = sim.getObject('./leftMotor');
    motorRightHandle = sim.getObject('./rightMotor');

    % Store the client globally
    simClient = sim;

    % Add a laser scanner to the robot
    addLaserScanner(sim, robotHandle, laserScannerModelPath);

    disp('Environment created in CoppeliaSim. You can now interact with it in the CoppeliaSim window.');
end
