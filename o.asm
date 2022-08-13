	; Open command
	; O devicenumber:filename:Mode - 0 reserved for console
	; 1 - 9 available otherwise
	; O 1:"DSK1.FILE":"W"
	; FILE NAME NEEDS TO HAVE DSKX.FILENAME X is drive number
	; MODE = R-READ, W-WRITE 
	
Getdevnum:  ; returns devnum in r3 or sets ErrNum if not successful

	push r11

	clr r3           ; zero out r3
    movb *r9+,r3     ; read char after O and advance past
    ci r3,2000h      ; is it space? should be
    jeq getdev2      ; if good jump down
    li r1,1          ; missing space syntax error
    mov r1,@ErrNum   ; set error num
    ; b @openend     ; exit out bottom
	jmp getdevexit	

getdev2:  ; get device number
	bl @getmstr        ; read device number
	popss r1           ; pop from string stack
	push r1            ; push ptr to string
	bl @strlen         ; length must be one
	pop r7             ; pop return value
	ci r7,1h           ; is it one
	jne baddevice      ; if not error
	clr r3
	movb *r1,r3        ; get the digit
	bl @isdigit        ; if length is good then is it a digit
	jne baddevice      ; if not error
	movb r3,@tmpio     ; store devnum in tmpio
	jmp getdevexit

baddevice:
    li r1,9            ; bad device number
    mov r1,@ErrNum     ; set error num
    ;jmp openend       ; exit out bottom
			
getdevexit:
	pop r11
	b *r11



Open:
Open3:
	push r11

	bl @getdevnum

	mov @ErrNum,r2
	ci r2,0
	jne openend	

	clr r3           ; zero out r3
    movb *r9+,r3     ; read char after device number
    ci r3,Colon      ; is it colon? should be
    jeq Open4        ; if good jump down
	
 opennocolon:
	li r1,10	    ; missing colon
	mov r1,@ErrNum  ;
	jmp openend
Open4:
	;li r6,pabopc   ; get start of ram pab to clear it
	;clr r7
	;li r1,30
;open4clr:
	;movb r7,*r6+   ; clear *r6 and increment to next addr
	;dec r1         ; decrease counter
	;jne open4clr

	li r14,b1clrampab_a
	bl @GoBank1
	;bl @clrampab   ; clear out ram pab ( real peb 	
	
	bl @getmstr    ; get filename
	popss r6       ; pop from string stack
	li r7,pabfil   ; copy into pabfil ; clear first?? 
	bl @strcopy

	; get mode "R" or "W" (maybe apend later)

	clr r3           ; zero out r3
        movb *r9+,r3     ; read char after device number
        ci r3,Colon      ; is it colon? should be
        jeq Open5        ; if good jump down
	jmp opennocolon  ; no colon when thre should be

Open5:
	bl @getmstr
	popss r1        ; pop from string stack
	push r1
	bl @strlen      ; length must be one
	pop r7
	ci r7,1h        ; is it one
	jeq Open6

badfilemode:
	li r1,7       ; bad file mode
	mov r1,@ErrNum ; 
	jmp openend

Open6: 
	clr r3
	mov *r1,r3
	clr r1
	ci r3,ReadMode
	jne Open7
	li r1,14h   ; r1 0014h  msb 00 - open lsb 14h read,variable,display
	jmp setpabopc

Open7:	ci r3,WriteMode
	jne badfilemode
	li r1,12h   ; r1 0012h  msb 00 open  lsb 12h write,variable,display 

setpabopc:
	mov r1,@pabopc     ; put 0012 into first two bytes of pab
	li r1,BUFADR       ; copy BUFADR in r1
	mov r1,@pabbuf     ; copy to PAB in ram
	li r1,05000h       ; set up size of records (80bytes)
	mov r1,@pablrl     ; write to pab in ram
	li r6,pabfil       ; get pointer to file name
	push r6            ; push for string length to use
	bl @strlen         ; get length of file name
	pop r7             ; pop string length pushed by strlen
	swpb r7            ; move to msb
	movb r7,@pabnln    ; with to PAB in ram

	li r14,b1fileio_a
	bl @GoBank1
	;bl @fileio         ; request IO transaction

	clr r3             ; ??
	li r0,PABERR       ; get VDP address of PAB error byte
	bl @vsbr           ; read error bye from VDP memory
	andi r1,0E000h     ; 1110 0000 0000 0000 b 1400 is ok F400 error
	ci r1,0            ; compare masked off bits check for error code
	jne openerr        ; if not zero then error
	li  r1,MTRUE       ; if no error set $T MUMPS system var to true
	mov r1,@DolT       ; set $t
	mov @tmpio,@openio ; set current open device for MUMPS 
openend:
	mov @CursorPos,r2  ; rest VDP write register to last screen position
	bl @gotoxy         ; set screen pos 
	
	pop r11            ; get retrun address
	b *r11             ; return to caller

openerr:
		
	li r1,MFALSE       ; error from fileio
	mov r1,@DolT       ; set MUMPS $t to false (read failed)
	jmp openend        ; jump out
