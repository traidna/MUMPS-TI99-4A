	; Open command
	; O devicenumber:filename:Mode - 0 reserved for console
	; 1 - 9 available otherwise
	; O:"DSK1.FILE":W
	; FILE NAME NEEDS TO HAVE DKSX.FILENAME
	; MODE = R-READ, W-WRITE 
	
Use:
	push r11

	bl @getdevnum     ; returns devnumber in r3 or ErrNum is set
	mov @ErrNum,r1    ; check errnum
	ci r1,0           ; is it 0
	jne usend	  ; not 0 have error
	ci r3,ConsIO      ; is it the console
	jeq setdolio
	mov @openio,r2     ; see what device is open
	c r2,r3           ; does it math one requested
	jne userr	  ; if not it is an error
setdolio:
	mov r3,@Dolio     ; set current device to r3
	jmp usend         ; all done
	
userr:
	li r1,30          ; log error
	mov r1,@ErrNum   
usend:
	pop r11           ; return to caller
	b *r11

