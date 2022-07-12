classdef Vehicle < handle
    properties
        brick
        motorMoving
        movementSpeedMotorA 
        movementSpeedMotorB
        vehicleMoving
        useMotorArmInsteadOfWheels
    end
    
    methods
        
        function obj = Vehicle(brk)
            obj.brick = brk;
            obj.brick.playTone(100, 800, 500);
            obj.motorMoving = false;
            obj.vehicleMoving = false;
            obj.useMotorArmInsteadOfWheels = false;
            
            obj.loadingMode(); % Init speed vars
        end
        
        function obj = stopVehicle(obj)
            if (obj.vehicleMoving)
                disp('Stopping Motor(s)');
                obj.brick.StopMotor('A');
                obj.brick.StopMotor('B');
                obj.brick.StopMotor('C');
                obj.vehicleMoving = false;
            end
        end
        
        function obj = UseMotorArm(obj, on)
            obj.useMotorArmInsteadOfWheels = on;
        end
        
        function result = parseColorSensor(obj)
           result = 0; % Nothing
           obj.brick.ColorColor(1); % No idea
           switch obj.brick.ColorColor(1)
            case 0
                disp("Nothing");
            case 1
            case 2 
                result = 1; % blue
            case 3 
                result = 2; %green
            case 4
            case 5
                result = 3; %red
            case 6 
            case 7 
            end 
        end
        
        function distanceInCm = getDistance(obj)
            obj.brick.UltrasonicDist(2);
            distanceInCm = obj.brick.UltrasonicDist(2);
        end
        
        function obj = setMotorSpeeds(obj, MotorA, MotorB)
            obj.movementSpeedMotorA = MotorA;
            obj.movementSpeedMotorB = MotorB;
        end
        
        function obj = loadingMode(obj)
            if (obj.useMotorArmInsteadOfWheels)
                obj.movementSpeedMotorA = int8(10);
                obj.movementSpeedMotorB = int8(10);
            else
                obj.movementSpeedMotorA = int8(40-10);
                obj.movementSpeedMotorB = int8(38-10);
            end 
        end
        
        function vehicleStatus(obj)
           fprintf("Vehicle Distance From Wall: %.2f cm | Vehicle Color Sensor: %d\n", obj.getDistance() * 1.0, obj.parseColorSensor());
        end
        
        function MoveVehicleForwards(obj)
            obj.processMotorMovement(-1, -1);

        end
        
        function MoveVehicleBackwards(obj)
            obj.processMotorMovement(1, 1);
        end
        
        function MoveVehicleLeft(obj)
            obj.processMotorMovement(1, -1);
        end

        function MoveVehicleRight(obj)
            obj.processMotorMovement(-1, 1);
        end
        
        % 1 = Foward, -1 = Backwards, 0 = No Movement
        function obj = processMotorMovement(obj, MotorAForward, MotorBForward)
            obj.processMotorMovementFine(MotorAForward, MotorBForward, obj.movementSpeedMotorA, obj.movementSpeedMotorB)
        end
        
        % 1 = Foward, -1 = Backwards, 0 = No Movement
        function obj = processMotorMovementFine(obj, MotorAForward, MotorBForward, MotorASpeed, MotorBSpeed)
            if (obj.useMotorArmInsteadOfWheels)
                obj.brick.MoveMotor('C', MotorASpeed * MotorAForward);
            else
                obj.brick.MoveMotor('A', MotorASpeed * MotorAForward);
                obj.brick.MoveMotor('B', MotorBSpeed * MotorBForward);
            end
            obj.vehicleMoving = true;
        end
        
        function obj = Deinit(obj)
            obj.motorMoving = false;
            obj.movementSpeedMotorA = int8(40);
            obj.movementSpeedMotorB = int8(40);
            obj.vehicleMoving = false;
            obj.useMotorArmInsteadOfWheels = false;
        end
        
        function result = ButtonsPressed(obj)
            result = ((obj.brick.TouchPressed(3) == 1) || (obj.brick.TouchPressed(4) == 1));
        end
        
        % Motor = A OR B OR Q (for both)
        function obj = ChangeMotorSpeed(obj, motor, diff)
            if (motor == 'A')
                obj.movementSpeedMotorA = obj.movementSpeedMotorA + diff;
            elseif (motor == 'B')
                obj.movementSpeedMotorB = obj.movementSpeedMotorB + diff;
            elseif (motor == 'Q')
                obj.movementSpeedMotorA = obj.movementSpeedMotorA + diff;
                obj.movementSpeedMotorB = obj.movementSpeedMotorB + diff;
            end
            
            % Underflow / Overflow check
            if (obj.movementSpeedMotorA < 0)
                obj.movementSpeedMotorA = 0;
            end
            if (obj.movementSpeedMotorA > 100)
                obj.movementSpeedMotorA = 100;
            end 
            if (obj.movementSpeedMotorB < 2)
                obj.movementSpeedMotorB = 2;
            end
            if (obj.movementSpeedMotorB > 98)
                obj.movementSpeedMotorB = 98;
            end    
        end
    end
end