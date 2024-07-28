function logOddsGrid = updateOccupancyGrid(logOddsGrid, laserData, robotPosition, robotOrientation, xMin, xMax, yMin, yMax, resolution, l_occ, l_free, l_prior)
    % Robot position
    robotX = robotPosition(1);
    robotY = robotPosition(2);
    robotTheta = robotOrientation(3); % Assuming yaw is the third component

    % Number of laser data points
    numPoints = length(laserData) / 2;

    % Process laser data
    for i = 1:numPoints
        % Extract joint position and distance
        jointPos = laserData(2 * i - 1);
        distance = laserData(2 * i);

        % Calculate the angle of the laser measurement relative to the robot
        angle = jointPos + robotTheta;  % Using the joint position directly since it already covers -45 to 45 degrees

        % Calculate the global coordinates of the detected point
        globalX = robotX + distance * cos(angle);
        globalY = robotY + distance * sin(angle);

        % Calculate cell indices
        if globalX >= xMin && globalX <= xMax && globalY >= yMin && globalY <= yMax
            xIdx = round((globalX - xMin) / resolution) + 1;
            yIdx = round((globalY - yMin) / resolution) + 1;

            % Update log-odds for the occupied cell
            logOddsGrid(yIdx, xIdx) = logOddsGrid(yIdx, xIdx) + l_occ - l_prior;

            % Update log-odds for free cells along the beam
            beamLength = sqrt((globalX - robotX)^2 + (globalY - robotY)^2);
            for d = 0:resolution:beamLength
                freeX = robotX + d * (globalX - robotX) / beamLength;
                freeY = robotY + d * (globalY - robotY) / beamLength;
                freeXIdx = round((freeX - xMin) / resolution) + 1;
                freeYIdx = round((freeY - yMin) / resolution) + 1;
                if freeXIdx >= 1 && freeXIdx <= size(logOddsGrid, 2) && freeYIdx >= 1 && freeYIdx <= size(logOddsGrid, 1)
                    logOddsGrid(freeYIdx, freeXIdx) = logOddsGrid(freeYIdx, freeXIdx) + l_free - l_prior;
                end
            end
        end
    end
end
