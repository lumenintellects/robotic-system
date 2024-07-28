function Connect_CreateWall
    % Initialise the zmqRemoteApi MATLAB client
    addpath('C:\Program Files\CoppeliaRobotics\CoppeliaSimEdu\programming\zmqRemoteApi\clients\matlab');
    client = RemoteAPIClient();

    % Initialize without parameters
    sim = client.getObject('sim');

    % Global variables to store motor handles and client
    global motorLeftHandle motorRightHandle simClient isStreaming

    sphereSize = 0.6; % Radius of the sphere
    cuboidSize = [0.5, 0.6, 0.4]; % Dimensions of the cuboid [length, width, height]

    sphereHandle1 = sim.createPrimitiveShape(sim.primitiveshape_spheroid, [sphereSize sphereSize sphereSize], 0);
    sphereHandle2 = sim.createPrimitiveShape(sim.primitiveshape_spheroid, [sphereSize sphereSize sphereSize], 0);
    cuboidHandle1 = sim.createPrimitiveShape(sim.primitiveshape_cuboid, cuboidSize, 0);
    cuboidHandle2 = sim.createPrimitiveShape(sim.primitiveshape_cuboid, cuboidSize, 0);
    cuboidHandle3 = sim.createPrimitiveShape(sim.primitiveshape_cuboid, cuboidSize, 0);
    cuboidHandle4 = sim.createPrimitiveShape(sim.primitiveshape_cuboid, cuboidSize, 0);


    % Define paths to models (ensure these paths are correct)
    woodenFloorModelPath = 'C:\Program Files\CoppeliaRobotics\CoppeliaSimEdu\models\infrastructure\floors\5mX5m wooden floor.ttm';
    robotModelPath = 'C:\Program Files\CoppeliaRobotics\CoppeliaSimEdu\models\robots\mobile\pioneer p3dx.ttm';%change robot if required?
    laserScannerModelPath = 'C:\Program Files\CoppeliaRobotics\CoppeliaSimEdu\models\components\sensors\Hokuyo URG 04LX UG01.ttm'; % Path to 2D laser scanner model
    laserScannerScriptPath = 'C:\Users\tayla\Documents\MATLAB\CSCK505_ROBOTICS2\TestOcc\robotic-system-1\robotic-system\HokuyaScript.txt';

    % Explicitly remove specific objects by name
    objectsToRemove = {'Floor'}; % Add any other specific objects you want to remove

    for i = 1:length(objectsToRemove)
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
    createWall(sim, [0, 1.5], [1.5, 1.5], wallThickness, wallHeight); % Horizontal right
    createWall(sim, [3.5, 2.5], [3.5, 1.5], wallThickness, wallHeight); % Short vertical top-right

    sim.setObjectPosition(cuboidHandle1, -1, [4, -0.5, 0.4]);
    sim.setObjectPosition(sphereHandle1, -1, [3, -1.5, 0.4]);
    sim.setObjectPosition(cuboidHandle2, -1, [-0.5, 1, 0.2]);
    sim.setObjectPosition(sphereHandle2, -1, [-4.5, 2, 0.2]);
    sim.setObjectPosition(cuboidHandle3, -1, [-4.5, -2, 0.2]);
    sim.setObjectPosition(cuboidHandle4, -1, [0.5, 1, 0.2]);

    % Function to add a laser scanner to a robot
    function addLaserScanner(sim, robotHandle, laserScannerModelPath)
        % Load the laser scanner model
        laserScannerHandle = sim.loadModel(laserScannerModelPath);

        % Set the parent of the laser scanner to the robot
        sim.setObjectParent(laserScannerHandle, robotHandle, true);

        % Adjust the position and orientation of the laser scanner on the robot
        sim.setObjectPosition(laserScannerHandle, robotHandle, [0, 0, 0.1]);
        sim.setObjectOrientation(laserScannerHandle, robotHandle, [0, 0, 0]);
    end

    function addLaserScannerScript(sim, laserScannerScriptPath)
        % Read the Lua script from the file
        fid = fopen(laserScannerScriptPath, 'r');
        if fid == -1
            error('Could not open Lua script file: %s', laserScannerScriptPath);
        end
        luaScript = fread(fid, '*char')';
        fclose(fid);
    
        % Get the handle of the laser scanner child object
        laserScannerHandle = sim.getObject('./Hokuyo');
    
        % Check if the laser scanner is already associated with a child script
        existingScriptHandle = sim.getScript(sim.scripttype_childscript, laserScannerHandle);
        if existingScriptHandle == -1
            % Add the new Lua script to the laser scanner
            scriptHandle = sim.addScript(sim.scripttype_childscript);
            sim.setScriptText(scriptHandle, luaScript);
    
            % Associate the new script with the laser scanner
            sim.associateScriptWithObject(scriptHandle, laserScannerHandle);
            disp('Lua script added to the laser scanner');
        else
            % Update the existing script's text
            sim.setScriptText(existingScriptHandle, luaScript);
            disp('Existing Lua script updated on the laser scanner');
        end
    end


    % Place the robot in the environment
    robotHandle = placeObject(sim, robotModelPath, [0, 0, 0.22], [0, 0, 0]);


    % Get handles for the robot's motors
    motorLeftHandle = sim.getObject('./leftMotor');
    motorRightHandle = sim.getObject('./rightMotor');
    
    % Store the client globally
    simClient = sim;

    % Add a laser scanner to the robot
    addLaserScanner(sim, robotHandle, laserScannerModelPath);
    
											 
    addLaserScannerScript(sim, laserScannerScriptPath)

    disp('Environment created in CoppeliaSim. You can now interact with it in the CoppeliaSim window.');
end
