	; close command
	; O devicenumber:filename:Mode - 0 reserved for console
	; 1 - 9 available otherwise
	; O:"DSK1.FILE":W
	; FILE NAME NEEDS TO HAVE DKSX.FILENAME
	; MODE = R-READ, W-WRITE 
	
Close:
	push r11            ; save return address from caller

	bl @getdevnum       ; read device number from code
	mov @ErrNum,r1      ; check if error returned
	ci r1,0             ; if 0 no error
	jne closend         ; if not 0 then get out
	
	; check open devices
	
Close3:
	li r1,00100h      ; r1 00100 move only msb to pab rest of record is good
	movb r1,@pabopc   ; store 01 in pab to request close

	bl @fileio        ; request io 

	jeq closerr       ; 


closend:
	pop r11          ; get address of caller
	b *r11           ; return from caller

closerr:
	li r1,debug1
	bl @PrintString
	jmp closend
