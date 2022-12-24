;------------------------------------------
; File    : Base.asm
; AUTHOR  : Dolev Goaz
; DATE    :
; CLASS   : yud 4
; ASSUME  :
; VERSION : 1
;------------------------------------------

		IDEAL
		
		MODEL small

		STACK 256

;----- 	Equates
		
		DATASEG

		;array db 0EFFFh dup (?)

		CODESEG
Start:
        mov ax, @data
        mov ds, ax

	TOP:
		MOV AH,2Ch
		INT 21
		MOV BH,DH  ; BH has current second
	GETSEC:      ; Loops until the current second is not equal to the last, in BH
		MOV AH,2Ch
		INT 21
		CMP BH,DH  ; Here is the comparison to exit the loop and print 'A'
		JNE PRINTA
		JMP GETSEC
	PRINTA:
		MOV AH,02
		MOV DL,'A'
		INT 21
		JMP TOP



Exit:
        mov ax, 4C00h
        int 21h
;-----------------------------------
;FunctionName - What it does
;-----------------------------------    
;Input:
;            REGISTERS WITH INPUT
;Output:
;            REGISTERS FOR OUTPUT
;Registers:
;            REGISTERS FOR PROCEDURE
;-----------------------------------
END start
