function plotLaserData(laserData, robotPosition, robotOrientation)
    numPoints = length(laserData) / 2; % Number of points (each point has joint position and distance)
    robotX = robotPosition(1);
    robotY = robotPosition(2);
    robotTheta = robotOrientation(3); % Assuming yaw is the third component

    hold on;
    for i = 1:numPoints
        jointPos = laserData(2 * i - 1);
        distance = laserData(2 * i);

        % Calculate the angle relative to the robot's orientation
        angle = jointPos + robotTheta;  % Using the joint position directly since it already covers -45 to 45 degrees

        % Transform laser data into global coordinates
        globalX = robotX + distance * cos(angle);
        globalY = robotY + distance * sin(angle);

        % Plot the laser point
        plot(globalX, globalY, 'b.'); % Blue for laser points
    end
    hold off;
    
    % Add labels and title for better understanding
    xlabel('Global X');
    ylabel('Global Y');
    title('Laser Data Points');
    axis equal;
end
