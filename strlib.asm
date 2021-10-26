	; string routines in TMS9900 ASM

	; strlen
	; counts bytes in a string passed on the stack
	; returned in on the stack
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
         ; assumes NULL termiated string
	 ; call with bl @strcpy	
	;pop r7
	;pop r6
	push r11
	push r3
cpyloop:
 	clr r3         ; clear r3 holding char
        movb *r6+,r3   ; get next char
        ci r3,0        ; is char 0
        jeq cpydone    ; if yes done
        movb r3,*r7+   ; copy char to position in r7 and move r7 to next char
        jmp cpyloop    ; loop back up for next one
cpydone: 
	movb r3,*r7   ; terminate the string
	pop r3
	pop r11
	b *r11        ; return tocaller


strcat:   ; adds the string pointed to in R7 to the end for string in r6
          ; it's up to the caller to make sure there is space in r7
        
          ; find end of r7
	push r11
	push r6
	push r7
	clr r11
strcat2:
	movb *r6+,r11   ; get current char 
	ci r11,0h       ; is it the end of string
	jne strcat2     ; if not keep going
        dec r6          ; back to end of string
strcat3:
	movb *r7+,r11   ; get next char of
        movb r11,*r6+   ; add on end of r6
	ci r11,0        ; is it end of string in r7?
        jne strcat3     ; if not get next char

	pop r7
	pop r6
	pop r11
	b *r11



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



