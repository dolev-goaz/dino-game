; File    : Project.asm
; AUTHOR  : Dolev Goaz
; DATE    :
; CLASS   : yud 4
; ASSUME  :
; VERSION : 1
; GAME    : THE RUNNING DINO
;------------------------------------------

		.486 ; makes dos think the processor is better, so it could run more commands
		IDEAL
		
		include 'Macros.INC'
		include 'Graphics.INC'
		MODEL large

		STACK 100h

		
;----- 	Equates
		;---Keyboard Keys
		EnterKey equ 01Ch
		EscapeKey equ 1d
		UpArrow equ 48h
		DownArrow equ 50h

		KEY_RIGHT_DOWN equ 77 ; 01001101b
		KEY_LEFT_DOWN  equ 75  ; 01001011b
		KEY_UP_DOWN    equ 72    ; 01001000b
		KEY_DOWN_DOWN  equ 80; 01010000b
		
		KEY_RIGHT_UP equ 11001101b
		KEY_LEFT_UP   	equ 11001011b
		KEY_UP_UP     	equ 11001000b
		KEY_DOWN_UP equ 11010000b

		;---- Pic Properties
		PIC_STARTING_X equ 43d
		STANDING_PIC_WIDTH  equ 47d
		STANDING_PIC_HEIGHT equ 45d
		STANDING_PIC_STARTING_Y equ 152d
		
		HEAD_HEIGHT equ 15d
		
		STANDING_PIC_MAXY equ STANDING_PIC_STARTING_Y+STANDING_PIC_HEIGHT
		STANDING_PIC_MAXx equ PIC_STARTING_X+STANDING_PIC_WIDTH ; 87d
		
		;---- Pic Properties
		DUCKING_PIC_WIDTH  equ 66d
		DUCKING_PIC_HEIGHT equ 21d
		DUCKING_PIC_Y equ 174d
		
		DUCKING_PIC_MAXY equ 195d
		DUCKING_PIC_MAXx equ 98d
		
		;---- Pic Properties
		METEOR_WIDTH equ 44
		METEOR_HEIGHT equ 21
		
		METEOR_MAXy equ [obstacleY] + METEOR_HEIGHT
		METEOR_MAXx equ [obstacleX] + METEOR_WIDTH
		
		;---- Pic Properties
		Ground_Obstacle_Width equ 29
		Ground_Obstacle_Height equ 15
		
		Ground_Obstacle_MaxY equ [obstacleY] + Ground_Obstacle_Height
		Ground_Obstacle_MaxX equ [obstacleX] + Ground_Obstacle_Width
		;---- Colours
		Black equ 0
		White equ 0Fh
		;---- Pic Properties
		Bone_Width equ 25d
		Bone_Height equ 12
		Bone_StartingX equ 90d
		; ---- MENU
		OptionDistance equ 28d
		OptionMaxY equ 74+28+28
		OptionMinY equ 74d
		; ---- SCORE
		numberHeight equ 10
		numberWidth equ 6

						 

		DATASEG
		
		include 'BitMaps.INC'
				 
		scoreSingles db -1
		scoreTens db 0
		scoreHundreds db 0
				 
				 
	 endScreen   db 'Hope you enjoyed playing my game!',13,10
				 db 'Credits to Ron Twito for the graphics.',13,10
				 db 'Game made by Dolev Goaz.',13,10, '$'

						 			
		; ---- FOR MENU
		decision db 1d
		y dw 74d
		oldy dw 10d
		
		; ---- FOR DINO
		
		DinosaurY dw 155
		DuckingPicStartingY dw 175
		losingStatus db 0
		enterPress db 0
		duckStatus db 0 ; 0=normal/jumping. 1= ducking
		obstacleWidth db ?
		obstacleHeight db ?
		obstacleY dw 200
		obstacleX dw 0
		IsMeteor db 0 ;0=ground, 1=meteor. bool
		counter dw 0

		; ----- FOR PCX
	
		IntroScreen		DB 'IntroScr.PCX',0
		HelpScreen 		DB 'HelpScr.PCX',0
		LossScreen		DB 'LoseScr.PCX',0
		MenuScreen		DB 'MenuScr.PCX',0
		PauseScreen		DB 'PauseScr.PCX',0
		
		FileHandle      DW ?
		
		FileSize        DW ?
				
		ImageLength     DW ?
		
		PaletteOffset   DW ?
		
		Point_X         DW ?
		Point_Y         DW ?
		Color           DB ?
						
		SEGMENT ImageContainer para public  'DATA'  
			DB 46000 DUP(?)
		ENDS
		; ----- GETPCX AT LOCATION
		arrayPCX db 12*25 dup (?)
		row dw ?
		col dw ?
		
		
		CODESEG

Start:
	mov ax, @data ; load starting address of data segment into ax
	mov ds, ax    ; data segment gets initialized
	mov ax, 0013h  ; Calling graphic mode
	int 10h        ; Calling graphic mode
	
	Call Far Intro

TheMenu:
	call far ResetProperties
	SHOWPCX MenuScreen
inputMenu:
	Call Far PrintMark
	Call Far InputProc
	cmp [enterPress], 1
	je checkPressed
	jmp inputMenu

checkPressed:
		cmp [decision], 1
		je GamePlayProc
		cmp [decision], 2
		je HowToPlayProc
		jmp exit
backFromProcs:
	cmp [losingStatus], 1
	je LOSS
	jmp TheMenu
LOSS: 
	Call Far LosingScreen
	jmp TheMenu


;----------Calling PROCEDURES----------;
GamePlayProc:
	Call Far GamePlay
	jmp backFromProcs
	
HowToPlayProc:
	Call Far HowToPlay
	jmp backFromProcs

;----ACCESS NEEDED----;
PrintMarkCall :
	Call Far PrintMark
;--------------------------------------------------------------------------------------
;----------------------------------------------------
;Input- getting input from the user
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            AL
;----------------------------------------------------
PROC InputProc

input:
	in al, 60h
	cmp al, DownArrow ; checking if down arrow was pressed
	je downPress
	cmp al, UpArrow ; checking if up arrow was pressed
	je upPress
	cmp al, EnterKey ; checking if Enter was pressed
	je enterPressed
	jmp input
	
	downPress:
		push [y]
		pop [oldy]
		inc [decision]
		add [y], OptionDistance
		; checking if choice is in range of 1-3(3 choices)
		cmp [decision], 4
		jb nextdecision
		mov [decision], 1 ; decision is out of range
		mov [y], OptionMinY
		jmp nextdecision
	
	upPress:
		push [y]
		pop [oldy]
		dec [decision]
		sub [y], OptionDistance
		; checking if choice is in range of 1-3(3 choices)
		cmp [decision], 0 
		ja nextdecision
		mov [decision], 3 ; decision is out of range
		mov [y], OptionMaxY
		jmp nextdecision
		
	enterPressed:
		mov [enterPress], 1
		
	nextdecision:
		ret
ENDP InputProc

;----------------------------------------------------
;GamePlay - the start of the game
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            DX, AX, BX, CL, DI
;----------------------------------------------------
PROC GamePlay
	DeletePart 0, 0, 320, 200, white ; WHITE SCREEN
	jmp actualGame
GamePauseProc:
	Call Far GamePause
	DeletePart 0, 0, 320, 200, white ; WHITE SCREEN

actualGame:
	Call Far DinoWalking
; - GOT INPUT FROM PROC
	cmp ah, EscapeKey
	je GamePauseProc
	cmp ah, UpArrow
	je JumpingProc
	cmp ah, DownArrow
	je DuckingProc
backFromActions:
	cmp [losingStatus], 1
	je GAME_LOST
	ClearKeyboardBuffer
	jmp actualGame
GAME_LOST:
	ret
	
ENDP GamePlay


JumpingProc:
	Call Far Jumping
	jmp backFromActions
DuckingProc:
	Call Far Ducking
	jmp backFromActions
	
;----------------------------------------------------
;Ducking - Dinosaur ducking
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            DX, AX, BX, CX, DI
;----------------------------------------------------
PROC Ducking
	mov [duckStatus], 1
	DeletePart PIC_STARTING_X, STANDING_PIC_STARTING_Y, STANDING_PIC_MAXx, STANDING_PIC_MAXY, white
	Call Far DuckingAnimation
	DeletePart PIC_STARTING_X+STANDING_PIC_WIDTH, DUCKING_PIC_Y, DUCKING_PIC_MAXx+10, DUCKING_PIC_MAXY, white ;delete duck head
	mov [duckStatus], 0
	ret
ENDP Ducking

;----------------------------------------------------
;ShowScore- Printing the player's score.
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            AL, BX, CL, DX, DI
;----------------------------------------------------
PROC ShowScore

	cmp [scoreSingles], 10
	je ScoreTen
checkNumbers1:
	cmp [scoreSingles], 1
	je DrawOne
	cmp [scoreSingles], 2
	je DrawTwo
	cmp [scoreSingles], 3
	je DrawThree
	cmp [scoreSingles], 4
	je DrawFour
	cmp [scoreSingles], 5
	je DrawFive
	cmp [scoreSingles], 6
	je DrawSix
	cmp [scoreSingles], 7
	je DrawSeven
	cmp [scoreSingles], 8
	je DrawEight
	cmp [scoreSingles], 9
	je DrawNine
	;scoreSingles=0
DrawZero:
	DrawPic zero, numberHeight,numberWidth,160,5
	jmp checkNumbers2
DrawOne:
	DrawPic one, numberHeight,numberWidth,160,5
	jmp checkNumbers2
DrawTwo:
	DrawPic two, numberHeight,numberWidth,160,5
	jmp checkNumbers2
DrawThree:
	DrawPic Three, numberHeight,numberWidth,160,5
	jmp checkNumbers2
DrawFour:
	DrawPic Four, numberHeight,numberWidth,160,5
	jmp checkNumbers2
DrawFive:
	DrawPic five, numberHeight,numberWidth,160,5
	jmp checkNumbers2
DrawSix:
	DrawPic six, numberHeight,numberWidth,160,5
	jmp checkNumbers2
DrawSeven:
	DrawPic seven, numberHeight,numberWidth,160,5
	jmp checkNumbers2
DrawEight:
	DrawPic eight, numberHeight,numberWidth,160,5
	jmp checkNumbers2
DrawNine:
	DrawPic nine, numberHeight,numberWidth,160,5
	jmp checkNumbers2

	
CheckNumbers2:
	cmp [scoreTens], 1
	je DrawOneTens
	cmp [scoreTens], 2
	je DrawTwoTens
	cmp [scoreTens], 3
	je DrawThreeTens
	cmp [scoreTens], 4
	je DrawFourTens
	cmp [scoreTens], 5
	je DrawFiveTens
	cmp [scoreTens], 6
	je DrawSixTens
	cmp [scoreTens], 7
	je DrawSevenTens
	cmp [scoreTens], 8
	je DrawEightTens
	cmp [scoreTens], 9
	je DrawNineTens
	;scoreTens=0
	DrawPic zero, numberHeight,numberWidth,153,5
	jmp CheckNumbers3
DrawOneTens:
	DrawPic one, numberHeight,numberWidth,153,5
	jmp CheckNumbers3
DrawTwoTens:
	DrawPic two, numberHeight,numberWidth,153,5
	jmp CheckNumbers3
DrawThreeTens:
	DrawPic Three, numberHeight,numberWidth,153,5
	jmp CheckNumbers3
DrawFourTens:
	DrawPic Four, numberHeight,numberWidth,153,5
	jmp CheckNumbers3
DrawFiveTens:
	DrawPic five, numberHeight,numberWidth,153,5
	jmp CheckNumbers3
DrawSixTens:
	DrawPic six, numberHeight,numberWidth,153,5
	jmp CheckNumbers3
DrawSevenTens:
	DrawPic seven, numberHeight,numberWidth,153,5
	jmp CheckNumbers3
DrawEightTens:
	DrawPic eight, numberHeight,numberWidth,153,5
	jmp CheckNumbers3
DrawNineTens:
	DrawPic nine, numberHeight,numberWidth,153,5
	jmp CheckNumbers3

	
CheckNumbers3:
	cmp [scoreHundreds], 1
	je DrawOneHundreds
	cmp [scoreHundreds], 2
	je DrawTwoHundreds
	cmp [scoreHundreds], 3
	je DrawThreeHundreds
	cmp [scoreHundreds], 4
	je DrawFourHundreds
	cmp [scoreHundreds], 5
	je DrawFiveHundreds
	cmp [scoreHundreds], 6
	je DrawSixHundreds
	cmp [scoreHundreds], 7
	je DrawSevenHundreds
	cmp [scoreHundreds], 8
	je DrawEightHundreds
	cmp [scoreHundreds], 9
	je DrawNineHundreds
	;scoreHundreds=0
	DrawPic zero, numberHeight,numberWidth,146,5
	jmp endScore
DrawOneHundreds:
	DrawPic one, numberHeight,numberWidth,146,5
	jmp endScore
DrawTwoHundreds:
	DrawPic two, numberHeight,numberWidth,146,5
	jmp endScore
DrawThreeHundreds:
	DrawPic Three, numberHeight,numberWidth,146,5
	jmp endScore
DrawFourHundreds:
	DrawPic Four, numberHeight,numberWidth,146,5
	jmp endScore
DrawFiveHundreds:
	DrawPic five, numberHeight,numberWidth,146,5
	jmp endScore
DrawSixHundreds:
	DrawPic six, numberHeight,numberWidth,146,5
	jmp endScore
DrawSevenHundreds:
	DrawPic seven, numberHeight,numberWidth,146,5
	jmp endScore
DrawEightHundreds:
	DrawPic eight, numberHeight,numberWidth,146,5
	jmp endScore
DrawNineHundreds:
	DrawPic nine, numberHeight,numberWidth,146,5
	jmp endScore

	
ScoreTen:
		mov [scoreSingles], 0
		inc [scoreTens]
		cmp [scoreTens], 10
		je scoreHundred
		jmp DrawZero
scoreHundred:
		mov [scoreTens], 0
		inc [scoreHundreds]
		jmp DrawZero
endScore:
	ret
ENDP ShowScore


;----------------------------------------------------
;Obstacles - Summon and move enemy objects
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            DX, AX, BX, CL, DI
;----------------------------------------------------
PROC Obstacles
	pusha
	cmp [obstacleX], 0
	ja MoveObstacle
	DeletePart [obstacleX], 50, PIC_STARTING_X, 200, white; deleting obstacles
	mov [obstacleX], 280
	inc [scoreSingles]
	mov al, 2 ; two options
	Call Far RandNum
	cmp al, 1 ; ground obstacle
	je @ground
	jmp @air

	@ground:
		mov [IsMeteor], 0
		mov [obstacleY], 195-Ground_Obstacle_Height
		DrawPic groundObstacle, Ground_Obstacle_Height, Ground_Obstacle_Width, [obstacleX], [obstacleY]
		jmp ReturnFromObstacles
		
	@air:
		mov [IsMeteor], 1
		mov al, 3 ; - input for RandNum
		Call Far RandNum
		cmp al, 1
		je HighestObastacle
		cmp al, 2
		je MiddleObstacle
		jmp LowestObstacle
	HighestObastacle:
		mov [obstacleY], 110
		DrawPic meteor, METEOR_HEIGHT, METEOR_WIDTH, [obstacleX], [obstacleY]
		jmp ReturnFromObstacles
	MiddleObstacle:
		mov [obstacleY], 140
		DrawPic meteor, METEOR_HEIGHT, METEOR_WIDTH, [obstacleX], [obstacleY]
		jmp ReturnFromObstacles
	LowestObstacle:
		mov [obstacleY], 170
		DrawPic meteor, METEOR_HEIGHT, METEOR_WIDTH, [obstacleX], [obstacleY]
		jmp ReturnFromObstacles
		
		
	MoveObstacle:
		
		cmp [IsMeteor], 1
		je meteorMovement
		cmp [IsMeteor], 0
		je GroundMovement
		meteorMovement:
		;	DeletePart PIC_STARTING_X, STANDING_PIC_STARTING_Y, STANDING_PIC_MAXx, STANDING_PIC_MAXY, white
			
			;DeletePart [obstacleX], [obstacleY], ax, bx, white
			sub [obstacleX], 10
			DrawPic meteor, METEOR_HEIGHT, METEOR_WIDTH, [obstacleX], [obstacleY]
			jmp CheckIfHit
			jmp ReturnFromObstacles

		GroundMovement:
;			DeletePart [obstacleX], [obstacleY], ax, bx, white
			sub [obstacleX], 10
			DrawPic groundObstacle, Ground_Obstacle_Height, Ground_Obstacle_Width, [obstacleX], [obstacleY]
			jmp CheckIfHit
	returnGround:		;returning to RET
			jmp ReturnFromObstacles
			
CheckIfHit:
	cmp [duckStatus], 1
	je duckCheckHit
	; here=normal/jumping
	cmp [obstacleX], PIC_STARTING_X+STANDING_PIC_WIDTH
	jbe CheckXRange2
	jmp returnGround
	
CheckXRange2:
	cmp [IsMeteor], 0
	je GroundCheckX
	; AX= OBSTACLE ENDINGX
	mov ax, [obstacleX]
	add ax, 26
	cmp ax, PIC_STARTING_X
	jae CheckYRangeTopRightPoint
	jmp returnGround
	
GroundCheckX:
	mov ax, [obstacleX]
	add ax, 19
	cmp ax, PIC_STARTING_X
	jae CheckYRangeTopRightPoint
	jmp returnGround
;NEED TO CHECK Y HIT(top right pixel)
CheckYRangeTopRightPoint:
	mov ax, [DinosaurY] ; ax= starting y of pic
	cmp [obstacleY], ax
	jae CheckYRangeBottomRightPoint
	jmp CheckYRangeBottomLeftPoint1
	
CheckYRangeBottomRightPoint:
	add ax, STANDING_PIC_HEIGHT ; ax= ending y of pic
	cmp [obstacleY], ax
	jbe GameLost
	jmp CheckYRangeBottomLeftPoint1
	
CheckYRangeBottomLeftPoint1:
	mov bx, [obstacleY]
	add bx, 20 ; bx= highest y of obstacle(works for both meteor and ground)
	mov ax, [DinosaurY] ; ax = starting y of pic
	cmp bx, ax
	jae CheckYRangeBottomLeftPoint2
	jmp returnGround
	
CheckYRangeBottomLeftPoint2:
	add ax, STANDING_PIC_HEIGHT ; ax= ending y of pic
	cmp bx, ax ; cmp (ObstacleEndingY, EndingYOfPic)
	jbe GameLost
	jmp returnGround
	
	
duckCheckHit:
       	cmp [obstacleX], PIC_STARTING_X+DUCKING_PIC_WIDTH+1;(exactly nose)
       	jbe duckCheckHit2
       	jmp returnGround
		
duckCheckHit2: ; x behind dino
       	cmp [IsMeteor], 0
       	je DuckGroundCheckX
       	; AX= OBSTACLE ENDINGX
       	mov ax, [obstacleX]
       	add ax, 34 
       	cmp ax, PIC_STARTING_X
       	jae DuckCheckYRangeTopRightPoint1
       	jmp returnGround
       
       DuckGroundCheckX:
       	; AX= OBSTACLE ENDINGX
       	mov ax, [obstacleX]
       	add ax, 19
       	cmp ax, PIC_STARTING_X
       	jae DuckCheckYRangeTopRightPoint1
       	jmp returnGround
       	
       DuckCheckYRangeTopRightPoint1:
       	cmp [obstacleY], DUCKING_PIC_Y
       	jae DuckCheckYRangeTopRightPoint2
       	jmp DuckCheckYRangeBottomLeftPoint1
       
       DuckCheckYRangeTopRightPoint2:
       	cmp [obstacleY], DUCKING_PIC_Y + DUCKING_PIC_HEIGHT
       	jbe GameLost
       	jmp DuckCheckYRangeBottomLeftPoint1
       	
       DuckCheckYRangeBottomLeftPoint1:
       	mov bx, [obstacleY]
       	add bx, 20 ; bx= highest y of obstacle(works for both meteor and ground)
       	cmp bx, DUCKING_PIC_Y
       	jae DuckCheckYRangeBottomLeftPoint2
       	jmp returnGround
       	
       DuckCheckYRangeBottomLeftPoint2:
       	cmp bx, DUCKING_PIC_Y+STANDING_PIC_HEIGHT ; cmp (ObstacleEndingY, EndingYOfPic)
       	jbe GameLost
       	jmp returnGround

GameLost:
	mov [losingStatus], 1 ; TRUE
ReturnFromObstacles:
	popa
	call Far ShowScore
	ret

ENDP Obstacles


;----------------------------------------------------
;LosingScreen - Loss screen
;----------------------------------------------------
;Input:
;            AL
;Output:
;            NONE
;Registers:
;            AX, BX, CX, DX, DS
;----------------------------------------------------
PROC LosingScreen
	SHOWPCX LossScreen
	losingScreenInput:
		in al, 60h
		cmp al, EscapeKey ;checking if escape button was pressed
		je returnFromLoss
		jmp losingScreenInput
returnFromLoss:
	ret
ENDP LosingScreen

;----------------------------------------------------
;DuckingAnimation - Animation while duck
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            CX, DX, AX, BX, DI 
;----------------------------------------------------
PROC DuckingAnimation
mov [counter], 0
	DrawPic dinosaurDuck1, DUCKING_PIC_HEIGHT, DUCKING_PIC_WIDTH, PIC_STARTING_X, DUCKING_PIC_Y
startDucking:
		delayDuck1:
		inc [counter]
		; DELAY - 0.02 SECONDS
		mov cx, 0
		mov dx, 09C40h
		;cx,dx = 4E20h=20,000
		mov ah, 86h
		int 15h ; delay 20,000/1,000,000 sec = 1/50 sec
		
		Call Far obstacles
		cmp [losingStatus], 1 
		je endDuck ; hit an object, GameOver
		
		cmp [counter], 4
		je firstFrameDuck
		jmp delayDuck1

firstFrameDuck:	
	mov [counter], 0
	DrawPic dinosaurDuck2, DUCKING_PIC_HEIGHT, DUCKING_PIC_WIDTH, PIC_STARTING_X, DUCKING_PIC_Y
	
	in al, 60h
	cmp al, KEY_DOWN_DOWN
	jne endDuck

		delayDuck2:
		
		inc [counter]
		; DELAY - 0.02 SECONDS
		mov cx, 0
		mov dx, 09C40h
		;cx,dx = 4E20h=20,000
		mov ah, 86h
		int 15h ; delay 20,000/1,000,000 sec = 1/50 sec
		
		Call Far obstacles
		cmp [losingStatus], 1
		je endDuck ; hit an object, GameOver
		
		cmp [counter], 4
		je secondFrameDuck
		jmp delayDuck2
		
secondFrameDuck:
	mov [counter], 0
	DrawPic dinosaurDuck1, DUCKING_PIC_HEIGHT, DUCKING_PIC_WIDTH, PIC_STARTING_X, DUCKING_PIC_Y
	in al, 60h
	cmp al, KEY_DOWN_DOWN
	jne endDuck
	jmp startDucking
endDuck:
	ret

ENDP DuckingAnimation

;----------------------------------------------------
;DinoWalking- Walking animation of the dinosaur
;----------------------------------------------------
;Input:
;            AH
;Output:
;            AL
;Registers:
;            AX, BX, CL, DX, DI
;----------------------------------------------------
PROC DinoWalking
mov [duckStatus], 0 ; dino doesnt duck
mov [counter], 0
DrawPic dinosaurNormal2, STANDING_PIC_HEIGHT, STANDING_PIC_WIDTH, PIC_STARTING_X, STANDING_PIC_STARTING_Y
startWalking:
	delayWalking1:
	inc [counter]
	; DELAY - 0.02 SECONDS
	mov cx, 0
	mov dx, 09C40h
	;cx,dx = 4E20h=20,000
	mov ah, 86h
	int 15h ; delay 20,000/1,000,000 sec = 1/50 sec
	Call Far Obstacles
	cmp [losingStatus],1
	je endWalk ; hit an object while walking
	
	mov ah, 1
	int 16h
	jnz endWalkCheck1
returnFromCheck1:
	
	cmp [counter], 4
	je firstFrame
	jmp delayWalking1
	
	
firstFrame:
	mov [counter], 0
	DrawPic dinosaurNormal1, STANDING_PIC_HEIGHT, STANDING_PIC_WIDTH, PIC_STARTING_X, STANDING_PIC_STARTING_Y

	delayWalking2:
	inc [counter]
	; DELAY - 0.02 SECONDS
	mov cx, 0
	mov dx, 09C40h
	;cx,dx = 4E20h=20,000
	mov ah, 86h
	int 15h ; delay 20,000/1,000,000 sec = 1/50 sec
	Call Far Obstacles
	cmp [losingStatus],1
	je endWalk ; hit an object while walking
	
	mov ah, 1
	int 16h
	jnz endWalkCheck2
returnFromCheck2:
	
	cmp [counter], 4
	je secondFrame
	jmp delayWalking2
	
secondFrame:
	mov [counter], 0
	DrawPic dinosaurNormal2, STANDING_PIC_HEIGHT, STANDING_PIC_WIDTH, PIC_STARTING_X, STANDING_PIC_STARTING_Y
	jmp startWalking
	
endWalkCheck2:
	cmp ah, DownArrow
	je endWalk
	cmp ah, UpArrow
	je endWalk
	cmp ah, EscapeKey
	je endWalk
	ClearKeyboardBuffer
	jmp returnFromCheck2
	
endWalkCheck1:
	cmp ah, DownArrow
	je endWalk
	cmp ah, UpArrow
	je endWalk
	cmp ah, EscapeKey
	je endWalk
	ClearKeyboardBuffer
	jmp returnFromCheck1
	
endWalk:
	ret
ENDP DinoWalking


;----------------------------------------------------
;Jumping- Dinosaur Jump
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            CX, DX, AX, BX, DI
;----------------------------------------------------
PROC Jumping
		pusha
delayFIRST:
		inc [counter]
		cmp [counter], 14 ; i want the obstacles to move only once in 0.05 seconds
		je JumpObstacles1

		; DELAY - 0.001 SECONDS
		mov cx, 0
		mov dx, 03E8h
		;cx,dx = 03E8h = 1,000
		mov ah, 86h
		int 15h ; delay 1,000/1,000,000 sec = 1/1000 sec
		mov ah, 1
		int 16h
		cmp ah, EscapeKey
		je GamePauseProc
		dec [DinosaurY]
		cmp [DinosaurY], 50
		je delaySecond
		DrawPic dinoJUMP, STANDING_PIC_HEIGHT, STANDING_PIC_WIDTH, PIC_STARTING_X, [DinosaurY]
		jmp delayFIRST
JumpObstacles1:

	Call Far Obstacles
	cmp [losingStatus],1
	je endjump ; hit an object while jumping
	
	mov [counter], 0
	jmp delayFirst
delaySecond:
		inc [counter]
		cmp [counter], 14 ; i want the obstacles to move only once in 0.05 seconds
		je JumpObstacles2
		; DELAY - 0.001 SECONDS
		mov cx, 0
		mov dx, 03E8h
		;cx,dx = 03E8h = 1,000
		mov ah, 86h
		int 15h ; delay 1,000/1,000,000 sec = 1/1,000 sec
		
	incY:
		inc [DinosaurY]
		cmp [DinosaurY], STANDING_PIC_STARTING_Y
		je endjump
		DrawPic dinoJUMP, STANDING_PIC_HEIGHT, STANDING_PIC_WIDTH, PIC_STARTING_X, [DinosaurY]
		jmp delaySecond
JumpObstacles2:
	Call Far Obstacles
	cmp [losingStatus],1
	je endjump ; hit an object while jumping
	mov [counter], 0
	jmp delaySecond
	
endjump:
	popa
	ret	
ENDP Jumping

;----------------------------------------------------
;HowToPlay - instructions about how to play
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            DX, AX
;----------------------------------------------------
PROC HowToPlay
	pusha
	SHOWPCX HelpScreen
	popa
	HTPScreenInput:
	in al, 60h
	cmp al, EscapeKey ;checking if escape button was pressed
	je returnFromHTP
	jmp HTPScreenInput
returnFromHTP:
	ret
 ; checking when escape button was pressed, if it was leave the screen.
ENDP HowToPlay
                   
                   
                   
	               
;----------------------------------------------------
;GamePause - GamePause menu
;----------------------------------------------------
;Input:            
;            NONE  
;Output:           
;            NONE  
;Registers:        
;            AX, BX, CX, DX, DS
;----------------------------------------------------
PROC GamePause
	SHOWPCX PauseScreen
inputPause:
	ClearKeyboardBuffer_INPUT_AFTER
	in al, 60h     
	cmp al, EscapeKey ; checking if escape button was pressed
	je TheMenu
	cmp al, EnterKey
	je endPause    
	jmp inputPause 
endPause:
	ret            
	               
ENDP GamePause	   
                   
;----------------------------------------------------
;PrintMark - Printing mark(menu)
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            AX, BX, CL, DX, DI, DS
;----------------------------------------------------
PROC PrintMark
	push ax
	push dx
	; --- deleting old mark
	SaveRectangle Bone_StartingX, [y], arrayPCX, Bone_Height, Bone_Width ; save the part of the pcx that im going to delete
	DrawPic arrayPCX, Bone_Height, Bone_Width, Bone_StartingX, [oldy] ;print it on the previous part of the mark.(deleting the mark)
	; --- drawing new mark
	DrawPic bone, Bone_Height, Bone_Width, Bone_StartingX, [y]
	ClearKeyboardBuffer_INPUT_AFTER
	pop dx
	pop ax
	ret
ENDP PrintMark

;----------------------------------------------------
;Intro - The intro of the game
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            AX, BX, CX, DX, DS
;----------------------------------------------------
PROC Intro
		pusha
		SHOWPCX IntroScreen
inputIntro:
	in al, 060h
	cmp al, EnterKey ; checking if Enter was pressed
	je return
	jmp inputIntro
return:
	popa
	ret
ENDP Intro

;----------------------------------------------------
;ClearScreen - Clearing the screen.
;----------------------------------------------------
;Input:
;            NONE
;Output:
;            NONE
;Registers:
;            AX
;----------------------------------------------------
PROC ClearScreen
	pusha
	xor cx, cx
	xor dx, dx
	mov al,0 ; colour black
	mov ah,0Ch ; draw dot mod
ClearScreenX:
	int 10h ; draw dot
	cmp cx,319 ; max x
	je ClearScreenY
	inc cx
	jmp ClearScreenX
ClearScreenY:  
	cmp dx,199 ; max y
	je EndClearScreen
	xor cx, cx
	inc dx
	jmp ClearScreenX
EndClearScreen:
	popa
	ret

ENDP ClearScreen

;----------------------------------------------------
;RandNum- Generating a number
;----------------------------------------------------
;Input:
;            AX
;Output:
;            AX
;Registers:
;            AX
;----------------------------------------------------
PROC RandNum
	cmp al, 2
	je Rand2Numbers
	cmp al, 3
	je Rand3Numbers
	jmp EndRand
	
	
Rand2Numbers:
	xor ax, ax
	in al, 40h
	shr al, 6
	and al, 01b
	;if al=0, output=0
	;if al=1, output=1
	jmp EndRand
	
Rand3Numbers:
	xor ax, ax
	in al, 40h
	shr al, 6
	cmp al, 0
	je Rand3Numbers ;output only 1,2,3
	
EndRand:
	ret
ENDP RandNum


;----------------------------------------------------------
; PutPixel Drawing point (direct memory access)
;----------------------------------------------------------
; Input:
; 	AX = x, BX = y, CL = color 
; Output:
; 	The point
; Registers:
;	AL, BX, CL, DX, DI
;----------------------------------------------------------
PROC PutPixel
; in order to get one line lower you to add 320 to the pointer everytime you go one line lower
; you add the x to get to the starting position of the line
		mov dx, bx ; bx = y = dx
		shl bx, 6  ; bx = bx*(2^6) = y*(2^6)
		shl dx, 8  ; dx = dx*(2^8) = y*(2^8)
		
		mov di, ax ; di = ax = x
		add di, bx ; di = y*(2^6) + x
		add di, dx ; di = y*(2^8) + y*(2^6) + x
;		di = y*320+x = y*(2^8) + y*(2^6) + x = (y<<8) + (y<<6) + x. y*320+x = current offset.(320 pixels in each row)
		mov al, cl ; cl = color
		stosb		; mov es:[di], al->mov al, color. show color on locationd byte. inc DI(next byte)
		ret
ENDP PutPixel

; -------- FOR PCX
;-------------------------------------------
; ReadPCXFile - read PCX file into ImageContainer 
;-------------------------------------------
; Input:
; 	File name
; Output:
; 	File into ImageContainer
; Registers:
;       AX, BX, CX, DX, DS
;-------------------------------------------
PROC ReadPCXFile Near
; saves the name of the file into FileHandle, calculates the size of the file, moves the file into ImageContainer
        pusha

;-----  Initialize variables
        mov     [FileHandle],0
        mov     [FileSize],0

;-----  Open file for reading
        mov     ah, 3Dh
        mov     al, 0
        int     21h   ; mov DX,offset FileName  
        mov     [FileHandle],AX   ; save Handle(Handle=Name Of File)

;-----  Get the length of a file by setting a pointer to its end
        mov     ah, 42h
        mov     al ,2
        mov     bx, [FileHandle]
        xor     cx, cx
        xor     dx, dx
        int     21h ; dx:ax= pointer on end of file

;-----  Save size of file
        mov     [FileSize], ax

;----- Return a pointer to the beginning of the file
        mov     ah, 42h
        mov     al, 0
        mov     bx, [FileHandle]
        xor     cx, cx
        xor 	dx, dx
        int 21h ; ds:ax= pointer on start of file

;-----  Read file into ImageContainer
        mov     bx, [FileHandle]
        pusha     
        push    ds
        mov     ax,ImageContainer
        mov     ds, ax
        xor     dx, dx
        mov     cx, 46000
        mov     ah, 3Fh
        int     21H
        pop     ds
        popa

;-----  Close the file
        mov     ah, 3Eh
        mov     bx,[FileHandle]
        int     21H
        popa
        ret
		
ENDP ReadPCXFile

;-------------------------------------------
; ShowPCXFile - show PCX file 
;-------------------------------------------
; Input:
; 	File name
; Output:
; 	The file
; Registers:
;	 AX, BX, CX, DX, DS, DI
;-------------------------------------------
PROC ShowPCXFile Near	
        pusha

        call    ReadPCXFile
		
		mov	ax, ImageContainer
        mov     es, ax

;-----  Set ES:SI on the actual image
        mov     si, 128 ; the header of the file. to start reading the picture itself.

;-----  Calculate the lenght of the image
        mov     ax, [es:42h]
        mov     [ImageLength], ax
        dec     [ImageLength]
		
;-----  Calculate the offset from the beginning of the palette file
        mov     ax, [FileSize]
        sub     ax, 768 ; size of palette, palette exists at the end of the file
        mov     [PaletteOffset], ax
        call    SetPalette
        xor     ch, ch          ; Clear high part of CX for string copies
        mov     [Point_x],0    ; Set start position
        mov     [Point_y],0
NextByte:
        mov     cl, [es:si]     ; Get next byte
		cmp     cl, 0C0h        ; Is it a length byte?
        jb      normal          ;  No, just copy it
        and     cl, 3Fh         ; Strip upper two bits from length byte
        inc     si              ; Advance to next byte - color byte

       	mov     al, [es:si]
		mov 	[Color], al
NextPixel:
        call 	PutPixelPCX
        cmp     cx, 1
		je 	CheckEndOfLine
	
        inc     [Point_X]

		loop 	NextPixel		
        jmp     CheckEndOfLine
Normal:
      	mov 	[Color], cl
        call 	PutPixelPCX

CheckEndOfLine:
        mov     ax, [Point_X]
        cmp     ax, [ImageLength]
;-----  [point_x] >= [WidthPict]
        jae     LineFeed
        inc     [Point_x]
        jmp     cont
LineFeed:
        mov [Point_x], 0
        inc [Point_y]
cont:
        inc     si
        cmp     si, [FileSize]     ; End of file? (written 320x200 bytes)
        jb      nextbyte
        popa
        ret
ENDP ShowPCXFile

;-------------------------------------------
; PutPixelPCX - draw pixel 
;-------------------------------------------
; Input:
; 	x - Point_x, y - Point_y, Color - color
; Output:
; 	The pixel
; Registers:
;	 AX, BH, CX, DX
;-------------------------------------------
PROC PutPixelPCX near
        pusha
        mov 	bh, 0h
        mov 	cx, [Point_x]
        mov 	dx, [Point_Y]
        mov 	al, [color]
        mov 	ah, 0ch
        int 	10h
        popa
        ret
ENDP PutPixelPCX		

;-------------------------------------------
; SetPalette - change palette from 0-255 to from 0-63 
;-------------------------------------------
; Input:
; 	PaletteOffset
; Output:
; 	New palette
; Registers:
;	 AX, BX, CX, DX, SI, ES
;-------------------------------------------
PROC SetPalette near
		pusha
		mov cx, 256*3 ; R, G, B
		mov si, [PaletteOffset] 	
NextColor:
		shr [byte es:si], 2 ; two leftmost bits are for either the number is lenght or not(0C0h=1100 0000b).
		inc si ; next byte
		loop NextColor

		mov dx,	[PaletteOffset] ; es:dx=pointer to table of color
		mov ax, 1012h; ah=10, al=12
		mov bx, 00h ; first color register to set
		mov cx, 256d  ; number of color registers to set
		int 10h ; set palette
		popa
		ret
ENDP SetPalette

;-------------------------------------------
; GetPixel - Get pixel properties.
;-------------------------------------------
; Input:
; 	x,y
; Output:
; 	color->AL
; Registers:
;	 AX, BX, CX, DX, SI, ES
;-------------------------------------------
PROC GetPixel
	mov ah,0Dh
	mov dx,[row]
	mov cx,[col]
	mov bx,0h
	int 10h
	ret
ENDP GetPixel	

;-------------------------------------------
; ResetProperties - Reset game properties
;-------------------------------------------
; Input:
; 	NONE
; Output:
; 	Initialized game variables
; Registers
;	 NONE
;-------------------------------------------
PROC ResetProperties
	mov [losingStatus], 0
	mov [enterPress], 0
	mov [DinosaurY], STANDING_PIC_STARTING_Y
	mov [obstacleX], 0 ; to reset last game played
	mov [scoreSingles], -1
	mov [scoreTens], 0
	mov [scoreHundreds], 0
	ret
ENDP ResetProperties



Exit:
	Call Far ClearScreen ; clear
	mov ax, 0003h ; moving to text mode
	int 10h     ; moving to text mode
	Print endScreen
	; END OF PROGRAM
	mov ah, 4Ch ; program terminate mode
	mov al, 0 ; not a batch file
	int 21h
END start