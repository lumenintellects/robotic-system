function occupancyGrid = UpdateOccupancyGrid(occupancyGrid, simClient, laserHandle, jointHandle, gridSize, cellSize)
    % UpdateOccupancyGrid updates the occupancy grid based on laser scanner data
    %
    % Inputs:
    %   occupancyGrid - the current occupancy grid (matrix)
    %   simClient - CoppeliaSim remote API object
    %   laserHandle - handle to the laser scanner in the simulation
    %   jointHandle - handle to the joint controlling the scanner
    %   gridSize - the size of the occupancy grid [rows, columns]
    %   cellSize - the size of each cell in the grid
    %
    % Output:
    %   occupancyGrid - the updated occupancy grid

    % Parameters for scanning
    horizontalScanningAngle = 90 * pi / 180; % 90 degrees in radians
    scanningDensity = 2; % Number of points per degree
    numPoints = floor(horizontalScanningAngle * scanningDensity * 180 / pi); % Total points to scan
    stepSize = pi / (scanningDensity * 180); % Angle step size for scanning

    % Loop through each scanning angle
    for i = 0:numPoints
        % Calculate the current angle
        currentAngle = -horizontalScanningAngle / 2 + i * stepSize;

        % Set the laser scanner joint to the current angle
        simClient.setJointPosition(jointHandle, currentAngle);

        % Handle the proximity sensor at the current angle
        [result, distance, detectedPoint] = simClient.handleProximitySensor(laserHandle);

        % If an object is detected
        if result > 0
            % Get the sensor matrix
            sensorMatrix = simClient.getObjectMatrix(laserHandle);

            % Transform the detected point to world coordinates
            detectedPointWorld = simClient.multiplyVector(sensorMatrix, detectedPoint);

            % Convert the detected point coordinates to grid coordinates
            x = round(detectedPointWorld(1) / cellSize) + gridSize(1) / 2;
            y = round(detectedPointWorld(2) / cellSize) + gridSize(2) / 2;

            % Ensure the coordinates are within the bounds of the grid
            if x > 0 && x <= gridSize(1) && y > 0 && y <= gridSize(2)
                % Mark the cell as occupied
                occupancyGrid(x, y) = 1;
            end
        end
    end
end