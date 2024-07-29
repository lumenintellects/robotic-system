function userInput = keyboardControl(sim, leftMotor, rightMotor, speed)

    disp('Waiting for user input');
    userInput = waitforbuttonpress;
    
    % up arrow -> move forward
    % down arrow -> move backwards
    % left arrow -> move left
    % right arrow -> move right
    % 0 key -> pause
    % esc key -> terminate
    val = double(get(gcf, 'CurrentCharacter'));
    
    sim.addLog(sim.verbosity_scriptinfos, sprintf('%d, button has been pressed!', val)); 
    if val == 30 % forward
        sim.setJointTargetVelocity(leftMotor, speed);
        sim.setJointTargetVelocity(rightMotor, speed);
    elseif val == 28 % left
        sim.setJointTargetVelocity(leftMotor, 0);
        sim.setJointTargetVelocity(rightMotor, speed);
    elseif val == 29 % right
        sim.setJointTargetVelocity(leftMotor, speed);
        sim.setJointTargetVelocity(rightMotor, 0);
    elseif val == 31 % backwards
        sim.setJointTargetVelocity(leftMotor, -1 * speed);
        sim.setJointTargetVelocity(rightMotor, -1 * speed);
    elseif val == 48 % pause
        sim.setJointTargetVelocity(leftMotor, 0);
        sim.setJointTargetVelocity(rightMotor, 0);
    elseif val == 27 % esc key to terminate
        sim.setJointTargetVelocity(leftMotor, 0);
        sim.setJointTargetVelocity(rightMotor, 0);
    end
end