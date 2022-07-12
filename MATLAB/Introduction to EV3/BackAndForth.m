i = 10

while (i > 0)  
    display('PUSH button to start');

    while (brick.TouchPressed(1) == 0) 
    end

    while (brick.TouchPressed(1) == 1) 
        brick.MoveMotorAngleRel('A', 50, 90, 'Brake');
        brick.MoveMotorAngleRel('B', 50, -90, 'Brake');
    end
    
    while (brick.TouchPressed(1) == 0) 
        brick.MoveMotorAngleRel('A', 50, -90, 'Brake');
        brick.MoveMotorAngleRel('B', 50, 90, 'Brake');
    end
    
    i = i - 1;
end