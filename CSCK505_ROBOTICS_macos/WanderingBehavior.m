function WanderingBehavior()
    % Initialize the connection to CoppeliaSim
    addpath('/Applications/coppeliaSim.app/Contents/Resources/programming/zmqRemoteApi/clients/matlab');
    client = RemoteAPIClient();
    sim = client.getObject('sim');

    % Get handles for the robot's motors and laser scanner
    robotName = '/PioneerP3DX';
    motorLeftHandle = sim.getObject(strcat(robotName, '/leftMotor'));
    motorRightHandle = sim.getObject(strcat(robotName, '/rightMotor'));
    laserScannerHandle = sim.getObject(strcat(robotName, '/LaserScanner2D'));

    % Print handles to verify they are correct
    disp(['Left motor handle: ', num2str(motorLeftHandle)]);
    disp(['Right motor handle: ', num2str(motorRightHandle)]);
    disp(['Laser scanner handle: ', num2str(laserScannerHandle)]);

    % Set parameters
    maxSpeed = 2; % Maximum motor speed
    turnSpeed = 1; % Speed for turning
    obstacleThreshold = 0.5; % Minimum distance to consider an obstacle
    wanderTime = 300; % Total wandering time in seconds

    % Main loop
    startTime = sim.getSimulationTime();
    while (sim.getSimulationTime() - startTime) < wanderTime
        % Get laser scanner data
        [detectionState, detectedPoints] = getLaserScannerData(sim, laserScannerHandle);

        disp(['Current time: ', num2str(sim.getSimulationTime() - startTime)]);
        disp(['Detection state: ', num2str(detectionState)]);
        disp(['Number of detected points: ', num2str(size(detectedPoints, 1))]);

        if ~isempty(detectedPoints)
            % Obstacle detected
            distances = sqrt(sum(detectedPoints.^2, 2));
            [minDist, minIdx] = min(distances);

            disp(['Minimum distance: ', num2str(minDist)]);

            if minDist < obstacleThreshold
                % Avoid obstacle
                if detectedPoints(minIdx, 2) > 0
                    disp('Turning right to avoid obstacle');
                    sim.setJointTargetVelocity(motorLeftHandle, turnSpeed);
                    sim.setJointTargetVelocity(motorRightHandle, -turnSpeed);
                else
                    disp('Turning left to avoid obstacle');
                    sim.setJointTargetVelocity(motorLeftHandle, -turnSpeed);
                    sim.setJointTargetVelocity(motorRightHandle, turnSpeed);
                end
            else
                disp('Moving forward, no immediate obstacle');
                sim.setJointTargetVelocity(motorLeftHandle, maxSpeed);
                sim.setJointTargetVelocity(motorRightHandle, maxSpeed);
            end
        else
            % No obstacle detected, random wandering
            if rand() < 0.05 % 5% chance to change direction
                turnDuration = 0.5 + rand() * 1.5; % Random turn duration between 0.5 and 2 seconds
                turnDirection = sign(rand() - 0.5); % Random turn direction

                disp(['Random turn for ', num2str(turnDuration), ' seconds']);

                turnStartTime = sim.getSimulationTime();
                while (sim.getSimulationTime() - turnStartTime) < turnDuration
                    sim.setJointTargetVelocity(motorLeftHandle, turnDirection * turnSpeed);
                    sim.setJointTargetVelocity(motorRightHandle, -turnDirection * turnSpeed);
                    sim.step();
                end
            else
                disp('Moving forward, no obstacle detected');
                sim.setJointTargetVelocity(motorLeftHandle, maxSpeed);
                sim.setJointTargetVelocity(motorRightHandle, maxSpeed);
            end
        end

        sim.step();
    end

    % Stop the robot
    sim.setJointTargetVelocity(motorLeftHandle, 0);
    sim.setJointTargetVelocity(motorRightHandle, 0);

    disp('Wandering behavior completed.');
end

function [detectionState, detectedPoints] = getLaserScannerData(sim, laserScannerHandle)
    % Get the data from the laser scanner
    data = sim.readCustomStringData(laserScannerHandle, 'LaserScannerData');
    
    % Debug: Print the raw data
    disp('Raw laser scanner data:');
    disp(data);
    
    % Initialize default values
    detectionState = 0;
    detectedPoints = [];
    
    % Check if data is valid
    if isempty(data) || all(isnan(data))
        disp('No valid laser scanner data available.');
        return;
    end
    
    % Ensure data is a character vector
    if isnumeric(data)
        data = num2str(data);
    elseif iscell(data)
        data = char(data{1});
    elseif isstring(data)
        data = char(data);
    end
    
    try
        parts = strsplit(data, ';');
        detectionState = str2double(parts{1});
        for i = 2:length(parts)-1  % Last element is empty due to trailing semicolon
            if ~isempty(parts{i})
                point = str2num(parts{i});  % Convert string to array
                if ~isempty(point) && length(point) == 3
                    detectedPoints = [detectedPoints; point];
                end
            end
        end
    catch e
        % If there's an error parsing the data, print it and return empty results
        disp('Error parsing laser scanner data:');
        disp(e.message);
    end
    
    % Debug: Print parsed results
    disp('Parsed laser scanner data:');
    disp(['Detection state: ' num2str(detectionState)]);
    disp(['Number of detected points: ' num2str(size(detectedPoints, 1))]);
end