warning off;
InitKeyboard();
hardExit = false;

disp('--- Main Menu ---');
disp("Press 'A' for auto control");
disp("Press 'M' for manual control");
disp("Press 'C' to terminate program");

% Main Menu %
while (true)
    % Wait for key
    keyDown = getKey();
    switch keyDown
        case 'a'
            aiControl(brick);
        case 'm'
           manualControl(brick);
        case 'c'
            CloseKeyboard();
            disp('Program Terminated!');
            return
    end
    disp('--- Main Menu ---');
end

function keyDown = getKey()
    global key
    while (true)
        pause (0.1);
        if (key)
            keyDown = key;
            return
        end
    end
end

function pauseUntilKeyRelease()
    global key
    while (true)
        pause (0.1);
        if (~key)
            return
        end
    end
end

function aiControl(brick)
    vehicleController           = Vehicle(brick);
    hardExit                    = false;
    NineDegreeTurnTime          = 1.10;
    
    autoTurnTimeout             = getTimeInSeconds();
    autoCorrectTimeout          = getTimeInSeconds();
    autoTurnRightTimeout        = getTimeInSeconds();
    autoStopSignTimeout         = getTimeInSeconds();
    stopSignPause               = getTimeInSeconds();
    
    pickUpEnabled                = true;
    dropOffEnabled               = true;
    
    while (true)
        pause(0.1);
       
        if (stopSignPause < getTimeInSeconds())
            vehWallDist = vehicleController.getDistance();

            % Turning.
            if (autoTurnTimeout < getTimeInSeconds())
                while (vehicleController.ButtonsPressed())
                    disp('Wall detected!');
                    vehicleController.MoveVehicleBackwards();
                    pause(2);
                    vehicleController.MoveVehicleForwards();
                    pause(1);
                    if (vehWallDist > 40)
                        vehicleController.MoveVehicleRight();
                    else
                        vehicleController.MoveVehicleLeft();
                    end
                    pause(NineDegreeTurnTime);
                    vehicleController.MoveVehicleForwards();
                    autoTurnTimeout = getTimeInSeconds() + 2;
                end
            end

            if (autoCorrectTimeout < getTimeInSeconds() && autoTurnTimeout < getTimeInSeconds())
                if (vehWallDist < 40)
                    if (vehWallDist <= 7)
                        disp("Turning Left...");
                        vehicleController.MoveVehicleLeft();
                        pause(0.15*3);
                        vehicleController.MoveVehicleForwards();
                    elseif (vehWallDist <= 15)
                        disp("Turning Left...");
                        vehicleController.MoveVehicleLeft();
                        pause(0.10*3);
                        vehicleController.MoveVehicleForwards();
                    elseif (vehWallDist >= 35)
                        disp("Turning Right...");
                        vehicleController.MoveVehicleRight();
                        pause(0.15*3);
                        vehicleController.MoveVehicleForwards();
                    elseif (vehWallDist >= 30)
                        disp("Turning Right...");
                        vehicleController.MoveVehicleRight();
                        pause(0.10*3);
                        vehicleController.MoveVehicleForwards();
                    end
                    autoCorrectTimeout = getTimeInSeconds() + 1;  
                end
            end

            if (autoTurnRightTimeout < getTimeInSeconds())
                if (vehWallDist > 50) 
                    disp("No Wall Detected, turning right in 1 seconds.");
                    pause(1);
                    vehicleController.MoveVehicleRight();
                    pause(NineDegreeTurnTime);
                    vehicleController.MoveVehicleForwards();
                    autoTurnRightTimeout = getTimeInSeconds() + 2;
                end
            end

            vehicleController.vehicleStatus();
            vehicleController.MoveVehicleForwards();

            switch (vehicleController.parseColorSensor())
                case 1
                    if (pickUpEnabled)
                        disp("PICKUP: Auto control deactivated! Dropping to manual control.");
                        vehicleController.stopVehicle();
                        manualControl(brick);
                        if (hardExit)
                            hardExit = false;
                           return; 
                        end
                        pickUpEnabled = false;
                    end
                case 2
                    if (dropOffEnabled && ~pickUpEnabled)
                        disp("DROPOFF: Auto control deactivated! Dropping to manual control.");
                        vehicleController.stopVehicle();
                        manualControl(brick);
                        if (hardExit)
                            hardExit = false;
                           return; 
                        end
                        dropOffEnabled = false;
                    end
                case 3 % stop
                    if (autoStopSignTimeout < getTimeInSeconds())
                        disp('Stop detected!');
                        vehicleController.stopVehicle();
                        stopSignPause           =       getTimeInSeconds() + 3;
                        autoStopSignTimeout     =       stopSignPause + 4;
                        %autoTurnTimeout         =       stopSignPause + 2;
                        autoTurnRightTimeout    =       stopSignPause + 2;
                        autoCorrectTimeout      =       stopSignPause + 1;  
                    end
            end
        end
    end
end

function manualControl(brick)
    vehicleController = Vehicle(brick);
    currentMotor = 'A';
    motorSpeedDiff = 2;
    
    disp('Manual Control Initialized');
    
    while (true)
        pause (0.1);
        
        % Wait for key
        keyDown = getKey();
        switch keyDown
            case 'uparrow'
                disp('Moving Forward');
                vehicleController.MoveVehicleForwards();
            case 'downarrow'
                disp('Moving Backwards');
                vehicleController.MoveVehicleBackwards();
            case 'leftarrow'
                disp('Moving Left');
                vehicleController.MoveVehicleLeft();
            case 'rightarrow'
                disp('Moving Right');
                vehicleController.MoveVehicleRight();
            case 'hyphen'
                vehicleController.ChangeMotorSpeed(currentMotor, -motorSpeedDiff);
                fprintf('Motor Speed A: %d B: %d\n', vehicleController.movementSpeedMotorA, vehicleController.movementSpeedMotorB);
            case 'equal'
                vehicleController.ChangeMotorSpeed(currentMotor, motorSpeedDiff);
                fprintf('Motor Speed A: %d B: %d\n', vehicleController.movementSpeedMotorA, vehicleController.movementSpeedMotorB);
           case 'a'
                currentMotor = 'A';
                disp('Changing speed for motor A');
            case 'b'
                currentMotor = 'B';
                disp('Changing speed for motor B');
            case 'q'
                currentMotor = 'Q';
                disp('Changing speed for both motors A and B');
            case 'space'
                vehicleController.vehicleMoving = true; % Force Stop
                vehicleController.stopVehicle();
            case 'c'
                disp("Exiting...");
                vehicleController.stopVehicle();
                vehicleController.Deinit();
                break;
            case 'x'
                disp('Force Exit To Main Menu');
                vehicleController.stopVehicle();
                vehicleController.Deinit();
                hardExit = true;
                break;
            case 's'
                vehicleController.UseMotorArm(~vehicleController.useMotorArmInsteadOfWheels);
                fprintf('Arm Status: %d\n', vehicleController.useMotorArmInsteadOfWheels);
                vehicleController.loadingMode();
        end
        
        % This slows down control surfaces if the vehicle isnt moving.
        if (vehicleController.vehicleMoving)
            % Wait until they release the key.
            pauseUntilKeyRelease();
            vehicleController.stopVehicle();
            vehicleController.vehicleStatus();
        end
        
    end
end

function seconds = getTimeInSeconds()
    seconds = uint32((hour(datetime)*3600)+minute(datetime)*60+second(datetime));
end
