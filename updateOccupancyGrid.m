function logOddsGrid = updateOccupancyGrid(logOddsGrid, laserData, robotPosition, robotOrientation, xMin, xMax, yMin, yMax, resolution, l_occ, l_free, l_prior)
    % Robot position
    robotX = robotPosition(1);
    robotY = robotPosition(2);
    robotTheta = robotOrientation(3); % Assuming yaw is the third component

    % Coverage angle (240 degrees) in radians
    coverageAngle = 240 * pi / 180;
    halfCoverageAngle = coverageAngle / 2;

    % Number of laser data points
    numPoints = length(laserData) / 3;

    % Process laser data
    for i = 1:numPoints
        % Calculate the angle of the laser measurement
        angle = (i / numPoints) * coverageAngle - halfCoverageAngle;
        
        % Transform laser data into local coordinates
        x = laserData(3 * i - 2);
        y = laserData(3 * i - 1);
        z = laserData(3 * i);

        % Rotate local coordinates to align with robot's orientation
        globalX = robotX + x * cos(angle + robotTheta) - y * sin(angle + robotTheta);
        globalY = robotY + x * sin(angle + robotTheta) + y * cos(angle + robotTheta);

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
                if freeXIdx >= 1 && freeXIdx <= length(logOddsGrid(1,:)) && freeYIdx >= 1 && freeYIdx <= length(logOddsGrid(:,1))
                    logOddsGrid(freeYIdx, freeXIdx) = logOddsGrid(freeYIdx, freeXIdx) + l_free - l_prior;
                end
            end
        end
    end
end
