	; string math 
StringMath:   ; string operators
	; called from Math.asm 
	; r6 will be pointer to right side operand
	; r3 will be operator
	; need to pop left side operand 

        push r11

        ; r6 right value, r3 operator come from math  
       
        popss r7      ; pop left side string

	ci r3,Equals        ; is it an = op
	jne smfollows       ; if not move on to check for ] follows op
	bl @strcmp          ; if yes compare the strings
	pushss r6           ; get an address on string stack
	ci r5,0h            ; if return value is 0 string are =
	jne equalfalse      ; if not the are not equal and jump down
	li r7,MTRUE         ; save true in the result
	movb r7,*r6+        ; and put on string stack
	jmp smterm          ; terminate the string


smfollows:
	ci r3,RightBracket  ; is it an ]  op
	jne Strconcat       ; if not move on to check for _ concatenate
	bl @strcmp          ; if yes compare the strings
	pushss r6           ; get an address on string stack
	ci r5,-1            ; if return value is - f7>f6
	jne equalfalse      ; if not the are not equal and jump down
	li r7,MTRUE         ; save true in the result
	movb r7,*r6+        ; and put on string stack
	jmp smterm          ; terminate the string


equalfalse:
	li r7,MFALSE
	movb r7,*r6+
	jmp smterm				


Strconcat:
	ci r3,Underscore    ; is it an _  op
	jne StringMathExit     ; if not _ then exit
	mov r6,r3           ; save rh value
    mov r7,r6           ; put lh value in r6 for copy
	pushss r7           ; get new adress on string stack to return result
	push r7
	bl @strcopy         ; copy r6 to r7
	pop r7
	mov r7,r6           ; r6 points to str stack value with lh value
	mov r3,r7           ; point to right value for strcat
        bl @strcat          ; 
	jmp StringMathExit  ; 

	
smterm:  ; terminate a string with 0h
	clr r7
	movb r7,*r6

StringMathExit:
	pop r11
	b *r11
