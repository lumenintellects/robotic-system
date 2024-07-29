function [position, orientation] = getRobotPose(sim)
    robotHandle = sim.getObject('/PioneerP3DX');
    position = sim.getObjectPosition(robotHandle, -1);
    orientation = sim.getObjectOrientation(robotHandle, -1);

    % Ensure the position and orientation are numeric
    position = cellfun(@(x) double(x), position, 'UniformOutput', true);
    orientation = cellfun(@(x) double(x), orientation, 'UniformOutput', true);
end
