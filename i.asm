	; if routines

If: 
	push r11

	clr r3           ; zero out r3
        movb *r9+,r3     ; read char after I and advance past
        ci r3,Space      ; is it space should be
        jeq if2          ; if good jump down
        li r1,12         ; missing space syntax error
        mov r1,@ErrNum   ; set error num
        jmp ifend       ; exit out bottom

if2:
        ;movb *r9,r3     ; read char after space
        bl @getmstr      ; get mumps string
        mov @ErrNum,r1   ; check for any errors
        ci r1,0          ; see if any errors
	jne ifend        ; if errors get out      
	popss r6         ; pull result
	bl @strtonum     ; turn into value in R7
	ci r7,0          ; if true execute line so jump down
	jne iftrue
	li r7,MFALSE
	li r6,Dolt
	mov r7,*r6       ; set $T to FALSE
ifeol:  movb *r9,r3      ; skip to eol, get next char
	cb r3,0          ; is it NULL (end of line)
	jeq ifend
	inc r9
	jmp ifeol        ; if not get next one       


iftrue:	li r7,MTRUE      ;
	li r6,DolT
	movb r7,*r6	 ; set $T to True
	
ifend:
	pop r11
	b *r11
