;;;;;;;;;;;;;;;;;;;;
; Print Char R0
;;;;;;;;;;;;;;;;;;;;


PrintCharR3:
        mov r3,r0  

PrintChar:  ; pass char in msb of r0
	; call toupper if needed

PrintCharOk:
	movb r0,@8C00h		;DataPort - put next char on screen	
	mov @CursorPos,r0
	inc r0
	mov r0,@CursorPos
	b *r11				;Return
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print NULL terminated string in *r1	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
PrintString:			
	push r11

PrintStringAgain:
	clr r0
	movb *r1+,r0	;Read a Byte
	ci r0,00000h
	jeq PrintStringDone
	ci r0,EOF
	jeq PrintStringDone
	bl @PrintChar	;Print the Character!
	jmp PrintStringAgain
PrintStringDone:
	pop r11
	b *r11 


CR: 	; carriage return - move to first pos in next line down

	push r11
	push r1
	push r2
	mov @CursorPos,r1   ; get current screen pos
	clr r0              ; set r1 to 0
	li r2,32            ; set r2 to 32 ( may need to use screen width)
	div r2,r0           ; divides r0r1 by r2 
			    ; current line num in r0, xpos in r1
	inc r0              ; move to next line
	mpy r2,r0           ; answer in r1,r2 ( but just r2 lsw)
	mov r1,@CursorPos   ; store screen pos
	mov r1,r2           ; gotoxy needs screen pos in r2
	bl @gotoxy          ; move to screen pos ori 4000h to r fyi
	pop r2
	pop r1
	pop r11
	b *r11

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Cls:
	push r11

        clr r0
        li r1,2000h
        li r0,0000h             ;Write 0000 - Vram for text chars
        ;bl @VDP_SetWriteAddress
	bl @setVDPwaddr
        li r4,24
	li r0,SPACE
clslp   li r1,32
cls2	movb r0,@8C00h		;DataPort - put next char on screen	
	dec r1
	jne cls2 	
        dec r4
        jne clslp
        li r1,2000h
        li r0,0000h             ;Write 0000 - Vram for text chars
        ;bl @VDP_SetWriteAddress
	bl @setVDPwaddr
	clr r0
	mov r0,@CursorPos
	pop r11
	b *r11
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



