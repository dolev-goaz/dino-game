		;----------------------------------------------------------
		; SaveRectangle - save whats displayed on the screen in a specific part into an array
		;----------------------------------------------------------
		; Input:
		; part starting X, part starting Y, width, height, array to save it into
		; Output:
		; 	array contains the content of that part.(pixels)
		; Registers
		;	AX, BX, CX, DX, DS
		;----------------------------------------------------------
		MACRO SaveRectangle x,y,array,PictureHeight,PictureWidth
		local loopY
		local loopX
			lea di,[array] ; mov di, offset array
			mov cx,PictureHeight
			mov ax,x
			mov [col],ax
			mov ax,Y
			mov [row],ax
		loopY:
			push cx
			mov cx,PictureWidth

		loopX:	
			push cx
			call Far GetPixel
			mov [di],al
			inc di
			inc [col]
			pop cx
			loop loopX
			inc [row]
			mov ax,x
			mov [col],ax
			pop cx
			loop loopY	
		ENDM SaveRectangle
		
		;----------------------------------------------------------
		; ShowPCX - Printing PCX at given location
		;----------------------------------------------------------
		; Input:
		; Name of file
		; Output:
		; Picture displayed
		; Registers
		;	AX, BX, CX, DX, DS
		;----------------------------------------------------------
		MACRO SHOWPCX fName 
			pusha		
			lea dx, [fName] ; mov dx, offset fName
			call ShowPCXFile
			mov ax, 0A000h ;  Set ES back to graphics screen segment (To print sprites)
			mov es, ax
			popa
		ENDM SHOWPCX

		;----------------------------------------------------------
		; DeletePart- painting a rectangle/square in color
		;----------------------------------------------------------
		; Input:
		; Pic starting x, starting y, ending x, ending y, color
		; Output:
		; 	None
		; Registers
		;	CX, DX, AX
		;----------------------------------------------------------
		MACRO DeletePart startingX, startingY, endingX, endingY, color
		local PaintX
		local PaintY
		local EndPaint
			pusha
			mov cx, startingX
			mov dx, startingY
			mov al,color
			mov ah,0Ch ; draw dot mod
		PaintX:
			int 10h ; draw dot
			cmp cx,endingX ; max x
			je PaintY
			inc cx
			jmp PaintX
		PaintY:  
			cmp dx,endingY ; max y
			je EndPaint
			mov cx, startingX
			inc dx
			jmp PaintX
		EndPaint:
			popa

		ENDM DeletePart
		
		;----------------------------------------------------------
		; DrawPic Drawing sprite (bitmap)
		;----------------------------------------------------------
		; Input:
		; 	AX = picX, BX = picY, DH = PIC_HEIGHT, DL = PIC_WIDTH
		;   SI = address of pic 
		; Output:
		; 	The sprite
		; Registers
		;	AL, BX, CL, DX, DI
		;----------------------------------------------------------
		MACRO DrawPic Picture, PicHeight, PicWidth, startingX, startingY
		local cycle
			pusha
			mov dh, PicHeight
			mov dl, PicWidth

			mov ax, startingX ; starting X of pic
			mov bx, startingY ; starting Y of pic
			lea si, [Picture] ; mov si, offset Picture
		cycle:
			mov cl, [byte si] ; color of the current pixel.

			pusha ; don't affect registers
			Call Far PutPixel ; draw pixel
			popa  ; dont affect registers

			inc si ; move to the next byte
			inc ax ; inc x- draw next pixel
			dec dl ; dec dl- one pixel less to draw. width to draw lowered.
			jnz cycle      ; draw next pixel - next collum. (x)

			mov dl, PicWidth ; new line- width back to start
			sub ax, PicWidth ; ax= starting X of picture
			inc bx ; next line - increased y
			
			dec dh ; new line- height reduced by one.
			jnz cycle       ; draw next pixel- next line, starting x. (y)
			popa
		ENDM DrawPic
