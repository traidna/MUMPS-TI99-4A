	; string math 
StringMath:   ; string operators

        push r11

        popss r6      ; pop right side string ptr
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
	jne StringMathExit  ; if not move on to check for ] follows op
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


smterm
	clr r7
	movb r7,*r6

StringMathExit:
	pop r11
	b *r11
