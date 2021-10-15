	; string routines in TMS9900 ASM

	; strlen
	; counts bytes in a string passed in r6
	; returned in r7
strlen:
	;mov r11,*r10+
	pop r6
	push r11

	clr r7         ; lenght counter
slloop:	clr r3         ; clear r3 holding char
        movb *r6+,r3   ; get next char
        ci r3,0        ; is char 0 
        jeq sldone     ; if yes done	 
	inc r7         ; add one to length counter
	jmp slloop     ; loop back up for next one
	;pop r11

sldone:	
	pop r11
	push r7
	b *r11
	

strcopy: ; copy string pointed to by r6 to address in r7
	 ; when calling push source first then dest pop off in revers
         ; assumes NULL termiated string
	 ; call with bl @strcpy	
	;pop r7
	;pop r6
	push r11
cpyloop:
 	clr r3         ; clear r3 holding char
        movb *r6+,r3   ; get next char
        ci r3,0        ; is char 0
        jeq cpydone    ; if yes done
        movb r3,*r7+   ; copy char to position in r7 and move r7 to next char
        jmp cpyloop    ; loop back up for next one
cpydone: 
	movb r3,*r7   ; terminate the string
	pop r11
	b *r11        ; return tocaller


strcmp:   ; compares two strings passed in with r6 and r7 return val in r5
	  ; f6 is string 1, r7 is string 2
	  ; return  1 if string 1 > string 2   r6 > r7 
	  ; return  0 if string 1 = string 2   r6 = r7
	  ; return -1 if strint 1 < string 2   r6 < r7
	clr r5
strcmp1	cb *r6,*r7
	jeq sceq
	jl sclt
	li r5, 1
	jmp scdone

strcmp2 inc r6
	inc r7
	jmp strcmp1		

sceq: 	; need to check if done
	movb *r6,r5
	ci r5,0
	jne strcmp2
	clr r5
	jmp scdone

sclt:	li r5,-1			 
scdone: 
	b *r11



