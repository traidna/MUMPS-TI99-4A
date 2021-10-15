	; Else routines

Else: 
	push r11

	clr r3           ; zero out r3
        movb *r9+,r3     ; read char after I and advance past
        ci r3,Space      ; is it space should be
        jeq else2          ; if good jump down
        li r1,12         ; missing space syntax error
        mov r1,@ErrNum   ; set error num
        jmp elseend       ; exit out bottom

else2:
        movb *r9,r3      ; read char after space
        ci r3,Space      ; is it space should be
        jeq else3        ; if good jump down
        li r1,12         ; missing space syntax error
        mov r1,@ErrNum   ; set error num
        jmp elseend      ; exit out bottom

else3:
	li r6,DolT
	clr r3
	movb *r6,r3
	li r4,'0'
	swpb r4
        cb r3,r4        ; if $T is False then execute ine
	jeq elseend	 ; by exiting here

elseeol:   ; if $T is true then do not do else and advance to eol
	movb *r9,r3      ; skip to eol, get next char
	cb r3,0          ; is it NULL (end of line)
	jeq elseend
	inc r9
	jmp elseeol        ; if not get next one       

elseend:
	pop r11
	b *r11
