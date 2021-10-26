getparams:   ; $*(p1,p2,p3,p4) - flags r0->p1, r12->92, r15->9
	push r11
	clr r0
	clr r12
	clr r15
	clr r3

        movb *r9+,r3
        ci r3,OpenParen
        jeq getparam1
        li r3,14          ; missing paren
        mov r3,@ErrNum    ;
	pop r11           ; pop getparams rtn so that final pop 
                          ; returns to dolx caller without going back to dolx
        jmp gpexit        ;


getparam1:    ; get param 1 - typicall the string to act on
	li r0,1          ; flag that param one on stack	
	push r0
	push r12
	push r15
	bl @getmstr      ; get mumps string
	pop r15
	pop r12
	pop r0
	movb *r9+,r3     ; get next char
	ci r3,Comma
	jne getparmclose


	li r12,1         ; flag param2 on stack
	push r0
	push r12
	push r15
	bl @getmstr      ; get mumps string
	pop r15
	pop r12
	pop r0
	movb *r9+,r3     ; get next char

	ci r3,Comma
	jne getparmclose

	li r15,1         ; flag param2 on stack
	push r0
	push r12
	push r15
	bl @getmstr      ; get mumps string
	pop r15
	pop r12
	pop r0
	movb *r9+,r3     ; get next char

getparmclose:
	;inc r9
	ci r3,CloseParen
	jeq gpexit	
	li r3,14       ; missing paren
	mov r3,@ErrNum ; 
        pop r11        ; if error pop dolx return address to return to caller 

gpexit:
	pop r11
	b *r11


dola:   ; $a() - returns ascii value a character
        ; $a(string) returns ascii of first character
        ; $a(string,x) returns ascii of character in pos x, 1 if leftmost
	; value is returned on the MUMPS string stack 
	push r11

	bl @getparams
        ci r12,0         ; is there a second param
        jeq dola3        ; if no jump down
        popss r6         ; if yes get address of string
        bl @strtonum     ; conver to num
        mov r7,r12       ; move num to r12
        dec r12           ; position is 0 based so dec counter

dola3:
	popss r0
	a r12,r0
	movb *r0,r3
	pushss r6
	swpb r3
	bl @toascstr

dolaexit:
	pop r11
	b *r11


dolc:   ;; $c(num) return the character whose value is in the string passed
	push r11
	
	bl @getparams    ; get params r0 string
	popss r0
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r8
	swpb r8          ; swap byte and move to string
	pushss r6
	mov r8,*r6+      ; move to string
	clr r1           ; put NULL in r1
	mov r8,*r6       ; terminate string	

	pop r11
	b *r11




dole:   ; $e() - returns ascii value a character
        ; $e(string) returns ascii of first character
        ; $e(string,x) returns ascii of character in pos x, 1 if leftmost
        ; value is returned on the MUMPS string stack
        push r11

        bl @getparams

	ci r15,0         ; third param?
	jeq dole2        ; if not jump down
	popss r6         ; get the string
	bl @strtonum     ; make is a number
	mov r7,r15	 ; move to r15
	dec r15          ; decrease by one for offset from base address

dole2:	ci r12,0         ; is there a second param
	jeq dole3        ; if no jump down
	popss r6         ; if yes get address of string
	bl @strtonum     ; conver to num
	mov r7,r12       ; move num to r12
	dec r12           ; position is 0 based so dec counter
dole3:	
	popss r0         ; get string of data
	a r0,r15         ; calc end address base + param 3 offset
	a r12,r0         ; start pos address + offset param 2		
	pushss r6
	
dole4:	movb *r0+,r3      ; get first char       
        movb r3,*r6+     ; put char in first pos
	c r0,r15
	jgt dole5
	jmp dole4

dole5:	clr r1
	movb r1,*r6      ; terminate
doleexit:
        pop r11
        b *r11



dolp:   ; $p() - returns ascii value a character
        ; $p(string) returns ascii of first character
        ; $p(string,x) returns ascii of character in pos x, 1 if leftmost
        ; value is returned on the MUMPS string stack
        push r11

        bl @getparams

        ci r15,0         ; third param?
        jne dolp1        ; r15 not zero (piece num) jump down
	li r15,1         ; otherwise default to piece one
	jmp dolp2        ; jump down to param two (delimiter)
 dolp1: popss r6         ; get the string
        bl @strtonum     ; make is a number
        mov r7,r15       ; move to r15

dolp2:  ci r12,0         ; is there a second param
        jeq dolperr      ; if no jump down
        popss r6         ; if yes get address of string
	clr r1           ; clear out r1 for delimeter
        movb *r6,r1      ; delimiter char to piece by (only single char)

dolp3:
        popss r0         ; get string of data
	li r2,1          ; piece counter to first piece
	clr r5           ; null
dolp3a:	c r2,r15        ; is it thispiece piece counter to piece num
	jne nextpc

	pushss r6        ; destination string
copypc  movb *r0+,r3
	cb r3,r1         ; does char match delimeter
	jeq dolp5 	 ; if yes then have full piece data	
	cb r3,r5         ; is it end of string
	jeq dolp5        ; end of string yes done
        movb r3,*r6+     ; copy to char to dext
	jmp copypc       ; go back up get next char

nextpc: movb *r0+,r3
	cb r3,r5        ; check for end of string
	jeq dolp5        ; end of string jump out
	cb r3,r1        ; end of piece
	jne nextpc      ; not end of peice
	inc r2          ; increment piece counter
	jmp dolp3a      ; process this piece  


dolp5:  movb r5,*r6      ; terminate

dolpexit:
        pop r11
        b *r11

dolperr:
	li r1,15
	mov r1,@ErrNum
	jmp dolpexit




doll:   ; $l() - returns ascii value a character
        ; $l(string) returns length of first character
        ; value is returned on the MUMPS string stack

        push r11

        bl @getparams
        popss r0         ; get address of string on top of string/math stack	
	push r0
	bl @strlen
	pop r7
        mov r7,r3
	pushss r6        ; get string stack address
	bl @toascstr

dollexit:
        pop r11
        b *r11



Doltt:  ; $t value
	push r11
	pushss r6
	mov @DolT,*r6
	pop r11
	b *r11

dolu:
	push r11
	clr r3
	movb @fioerr,r3
	swpb r3 
	pushss r6
	bl @toascstr	
	pop r11
	b *r11

	
doli:   ; dolio $IO
	push r11
        clr r3
	movb *r9+,r3
	ci r3,04F00h   ; 'O' of $io

	jne dolierr
        pushss r6
	mov @Dolio,*r6

doliexit:
	pop r11
	b *r11

dolierr:
       li r1,18		; bad function call
	mov r1,@ErrNum  
	jmp doliexit


dolo:  ; $o
	b *r11
;	push r11
;	li r1,debug1
;	bl @PrintString

	; $o(x(""))
;	mov *r9+,r3
;	ci r3,Openpaen
;	jne 

;	mov @head,r6
;	bl @treemin
;	jmp $	
;	pop r11
;	b *r11

