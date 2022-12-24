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
