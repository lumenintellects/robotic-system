
% Initialise the zmqRemoteApi MATLAB client
addpath('/Users/ahmedelsenousi/Downloads/coppeliaSim.app/Contents/Resources/programming/zmqRemoteApi/clients/matlab');
client = RemoteAPIClient();

% Initialize without parameters
sim = client.getObject('sim');

 gridSize = [50, 100]; % 50x100 grid cells
 gridResolution = 0.1; % each cell represents a 0.1m x 0.1m area
 occupancyGrid = zeros(gridSize); % Initialize the grid with zeros (free space)
 

% Example function to convert world coordinates to grid coordinates
function [row, col] = worldToGrid(x, y, gridResolution, gridSize)
    col = min(max(round(x / gridResolution) + gridSize(2) / 2, 1), gridSize(2));
    row = min(max(round(y / gridResolution) + gridSize(1) / 2, 1), gridSize(1));
end

axis equal;
title('Occupancy Grid');
xlabel('X (grid cells)');
ylabel('Y (grid cells)');
colorbar;

robo=sim.getObject('/PioneerP3DX');
front_Sensor = sim.getObjectHandle('Pioneer_p3dx_ultrasonicSensor5');
for i=1:300
   result=sim.readProximitySensor(front_Sensor);
   if result > 0
     p=sim.getObjectPosition(robo);
     x=p(1,1);
     y=p(1,2);
     [row, col] = worldToGrid(x{1}, y{1}, gridResolution, gridSize);
     occupancyGrid(row, col) = 1; % Mark the cell as occupied
   end
   
   pause(0.1);
   imagesc(occupancyGrid);

end

