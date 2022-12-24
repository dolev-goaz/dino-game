		;----------------------------------------------------
		;Print - PRINTING A STRING
		;----------------------------------------------------
		;Input:
		;            object
		;Output:
		;            printed STRING on screen(graphic mode)
		;Registers:
		;            AH, DX
		;----------------------------------------------------
		MACRO Print string
				push dx
				push ax
				lea dx, [string] ;mov dx, offset string
				mov ah, 09h ; PRINTING
				int 21h     ; STRING
				pop ax
				pop dx
		ENDM Print

		;----------------------------------------------------
		;ClearKeyboardBuffer- Clearing Keyboard Buffer by reading all keys from it.
		;----------------------------------------------------
		;Input:
		;            NONE
		;Output:
		;            NONE
		;Registers:
		;            AX
		;----------------------------------------------------
		MACRO ClearKeyboardBuffer
		local clear
		local cleared
				push ax
				clear: 
				mov ah, 1               
				int 16h 		; ?Any characters in buffer? 
				JZ  Cleared
				mov ah, 0
				int 16h
				jmp clear 
				Cleared: 
					pop ax
		ENDM ClearKeyboardBuffer
		
		;----------------------------------------------------
		;ClearKeyboardBuffer- Clearing Keyboard Buffer(using interrupt)
		;----------------------------------------------------
		;Input:
		;            NONE
		;Output:
		;            NONE
		;Registers:
		;            AX
		;----------------------------------------------------
		MACRO ClearKeyboardBuffer_INPUT_AFTER
				push ax
				mov ah,0ch
				mov al, 07h
				int 21h
				pop ax
		ENDM ClearKeyboardBuffer_INPUT_AFTER
		
