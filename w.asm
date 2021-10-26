	; w.asm - Write routine
	; write can hande # - cls, !, newline strings in "", 
	; numbers or variables or results of operators

Write: 	; R9 is pointer to executing code
	push r11

	clr r3           ; zero out r3
	movb *r9+,r3     ; read char after w and advance past
	ci r3,2000h      ; is it space should be
	jeq wrt2         ; if good jump down
	li r1,12         ; missing space syntax error
	mov r1,@ErrNum   ; set error num
	jmp wrtend       ; exit out bottom			

wrt2:    
	movb *r9,r3      ; read char after space
	ci r3,Hashtag    ; check for #
	jeq wcls         ; if # then cls
	ci r3,ExclamPt   ; is char ! if so do print newline
	jeq wnewln       ; new line
	                 ; let mstring handle syntax from here
	                 ; letters (vars), digits, " operators ok here
	bl @getmstr      ; get mumps string
	mov @ErrNum,r1
	ci r1,0          ; see if any errors
	jne wrtend
	popss r1         ; get address of string on top of string/math stack
	mov @Dolio,r11   ; get output device
	ci r11,ConsIO    ; see if it is console io '0'
	jeq wrt2a        ; if yes jump down to print to screen
	bl @WriteFile    ; print to file 
	jmp wrt3         ; jump over print to screen
wrt2a:	bl @PrintString  ; print the string		 
wrt3:	movb *r9,r3      ; get the current char in code 
	ci r3,Comma      ; is it a comman
	jne  wrt4        ; if no then jump on 
	inc r9           ; if comma then inc code pointer
	jmp wrt2         ; loop back up for next thing to print
wrt4	ci r3,SPACE      ; check for space between commands
	jeq wrtend       ; if a space then done
wrt5	ci r3,NULL       ; not a comma or space so check if NULL 
	jne werror       ; if not a null then syntax error
	jmp wrtend       ; if NULL end of line and write command

werror:	
	li r1,12        ; missing space syntax error
	mov r1,@ERRNUM ; set error num

wrtend:	pop r11
	b *r11
	;b *r7

wcls:   
	mov @Dolio,r11
	ci r11,ConsIO
	jne wcls2
	bl @Cls
wcls2:	inc r9    ; move past #
	jmp wrt3

wnewln:
	mov @DolIO,r11
	ci r11,ConsIO
	jne wnewln2
	bl @CR
wnewln2:
	inc r9
	movb *r9,r3
	ci r3,Exclampt
	jeq wnewln
	jmp wrt3

WriteFile:
	push r11
	push r1           ; push ptr of string to write
 	bl @clrVDPbuf     ; clear PAB read/write buffer

	li r0,BUFADR      ; write location in VDP RAM buffer setVDPaddr uses
	bl @setVDPwaddr   ; reset to top of buffer
	; string in r1 from before call
	pop r2            ; from push of r1 above
	clr r0
copytobuf:                ; copy RAM to VD:P
	clr r1
	movb *r2+,r1
	vsbw              ; vdp single byte write 
	inc r0            ; couunt bytes
	ci r1,0h          ; 
	jne copytobuf     ;
        li r1,3           ; write opcode
        swpb r1           ; swap to msb
        movb r1,@pabopc   ; put in PAB record
	swpb r0           ; move count to msb  
	movb r0,@pabcc    ; write byte count to pab record
	push r2           ; save location of last read
        bl @fileio        ; request the read
        pop r2            ; end of string written, used by zsave - cont. to next line
	pop r11           ; get return address of caller
	b *r11            ; return to caller
