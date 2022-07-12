display('PUSH button to start the tone');

while (brick.TouchPressed(1) == 0)
    pause(0.01);
end

display('RELEASE button to turn tone OFF');

while (brick.TouchPressed(1) == 1)
    brick.playTone(100, 300, 500);
    pause(0.75);
end

