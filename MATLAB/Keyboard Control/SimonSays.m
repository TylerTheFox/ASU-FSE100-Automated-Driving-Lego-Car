global key
InitKeyboard();
while 1
    pause (0.1);
    disp(key);
    while (strcmp(key, 'leftarrow') || strcmp(key, 'rightarrow'))
        pause (0.1);
        if (strcmp(key, 'leftarrow'))
            brick.MoveMotor('A', -100);
        elseif (strcmp(key, 'rightarrow'))
            brick.MoveMotor('A', 100);
        end
    end
    brick.StopMotor('A');
end