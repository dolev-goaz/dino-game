@echo off
cycles = 30000
\Users\דולב\Desktop\DinoGame\COMPILE %1.asm
del %1.map
\Users\דולב\Desktop\DinoGame\COMPILE %1.obj > null
del %1.obj
%1.exe
cycles = 3000

