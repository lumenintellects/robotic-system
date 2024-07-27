% Add path to the zmqRemoteApi MATLAB client
addpath('C:\Program Files\CoppeliaRobotics\CoppeliaSimEdu\programming\zmqRemoteApi\clients\matlab');
client = RemoteAPIClient();

% Initialize without parameters
sim = client.getObject('sim');

% Define environment bounds
xMin = -5; xMax = 5;
yMin = -2.5; yMax = 2.5;
resolution = 0.1; % Grid resolution

% Create occupancy grid with prior probabilities (0.5 = unknown)
xGrid = xMin:resolution:xMax;
yGrid = yMin:resolution:yMax;
occupancyGrid = 0.5 * ones(length(yGrid), length(xGrid));

% Log-odds representation of probabilities
logOddsGrid = log(occupancyGrid ./ (1 - occupancyGrid));

% Define sensor model probabilities
p_occ = 0.9; % Probability that a cell is occupied given a measurement
p_free = 0.3; % Probability that a cell is free given no measurement

% Log-odds values
l_occ = log(p_occ / (1 - p_occ));
l_free = log(p_free / (1 - p_free));
l_prior = log(0.5 / (1 - 0.5));

%start simulations
sim.startSimulation();

% Fetch and process laser data in a loop (or single call for testing)
figure;
while true
    % Get laser data
    laserData = getLaserData(sim);
    
    if isempty(laserData)
        continue; % Skip if no data
    end

    % Get robot's position and orientation
    [robotPosition, robotOrientation] = getRobotPose(sim);
    
    % Update occupancy grid using inverse sensor model
    logOddsGrid = updateOccupancyGrid(logOddsGrid, laserData, robotPosition, robotOrientation, xMin, xMax, yMin, yMax, resolution, l_occ, l_free, l_prior);

    % Convert log-odds to probabilities
    occupancyGrid = exp(logOddsGrid) ./ (1 + exp(logOddsGrid));

    % Display occupancy grid
    imagesc(xGrid, yGrid, occupancyGrid);
    axis xy;
    hold on;
    
    % Plot robot position
    plot(robotPosition(1), robotPosition(2), 'ro', 'MarkerFaceColor', 'r');
    
    % Set plot limits and labels
    xlim([xMin xMax]);
    ylim([yMin yMax]);
    title('Occupancy Grid');
    xlabel('X (m)');
    ylabel('Y (m)');
    pbaspect([2 1 1]); % Set aspect ratio to be elongated (2:1)
    colorbar;
    hold off;
    
    drawnow;
end
