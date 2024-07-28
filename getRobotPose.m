function [position, orientation] = getRobotPose(sim)
    robotHandle = sim.getObject('/PioneerP3DX'); % Adjust the object path to your robot
    position = sim.getObjectPosition(robotHandle, -1);
    orientation = sim.getObjectOrientation(robotHandle, -1);

    % Ensure the position and orientation are numeric
    position = cellfun(@(x) double(x), position, 'UniformOutput', true);
    orientation = cellfun(@(x) double(x), orientation, 'UniformOutput', true);

    %Debug prints
    %disp('Robot Position:');
    %disp(position);
    %disp('Robot Orientation:');
    %disp(orientation);
end
