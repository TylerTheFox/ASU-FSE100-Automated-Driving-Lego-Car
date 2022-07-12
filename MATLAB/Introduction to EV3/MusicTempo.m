display('PUSH button to start');

while (brick.TouchPressed(1) == 0) 
end

down_count = 0;

while (brick.TouchPressed(1) == 1)
    down_count = down_count + 1;
end

fprintf('Button was held down for %d processor cycles', down_count);

brick.playTone(100, down_count*400, 500);
pause(down_count/25);
brick.playTone(100, down_count*120, 500);
pause(down_count/25);
brick.playTone(100, down_count*98, 500);
pause(down_count/25);
brick.playTone(100, down_count*60, 500);