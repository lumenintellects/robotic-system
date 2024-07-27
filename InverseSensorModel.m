% Initialise the zmqRemoteApi MATLAB client
addpath('C:\Program Files\CoppeliaRobotics\CoppeliaSimEdu\programming\zmqRemoteApi\clients\matlab');
client = RemoteAPIClient();

% Initialize without parameters
sim = client.getObject('sim');

% Function to get laser data from CoppeliaSim
function laserData = getLaserData(sim)
    packedData = sim.getStringSignal('laserData');
    if isempty(packedData)
        laserData = [];
    else
        laserData = sim.unpackFloatTable(packedData);
    end
end

% Get laser data
laserData = getLaserData(sim);

% Define environment bounds
xMin = -5; xMax = 5;
yMin = -2.5; yMax = 2.5;
resolution = 0.1; % Grid resolution

% Create occupancy grid
xGrid = xMin:resolution:xMax;
yGrid = yMin:resolution:yMax;
occupancyGrid = zeros(length(yGrid), length(xGrid));

% Process laser data
for i = 1:3:length(laserData)
    x = laserData(i);
    y = laserData(i+1);
    z = laserData(i+2);
    
    if x >= xMin && x <= xMax && y >= yMin && y <= yMax
        xIdx = round((x - xMin) / resolution) + 1;
        yIdx = round((y - yMin) / resolution) + 1;
        occupancyGrid(yIdx, xIdx) = 1;
    end
end

% Display occupancy grid
figure;
imagesc(xGrid, yGrid, occupancyGrid);
axis xy;
title('Occupancy Grid');
xlabel('X (m)');
ylabel('Y (m)');
