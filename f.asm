	; for f.asm
	; f var=1:1:10
	; f var=1:1
	; f  ...


For:
	push r11

	; should check if f space space 

	bl @Set         ; handels f var=val assigns val to var leaves on : after val
	mov @ErrNum,r1  ; get error status
	ci r1,0         ; if error is 0
	jne forexit     ; not zero so error

	clr r3          ; clr reg for char
	bl @forgetint   ; get increment and push on stack
	mov r7,r2       ; save inc in R2
	push r2

	bl @forgetint   ; get max and push on stack
	mov r7,r4       ; save max in r4
	push r4

	mov @LastSet,r6 ; address of variable in this for statement
	bl @strtonum    ; return value in r7
	mov r7,r1       ; 
	pop r4          ; get max 
	pop r2	        ; get increment
	pushm r9        ; address of char in code front of for loop 
	mov @Forflg,r11
	ai r11,1
	mov r11,@Forflg
	mov @LastSet,r6  ; address of index variable in for loop for updating
	
floop:
	ci r2,0       ; is increment 0
	jlt floop1b   ; if less than (negative)
	c r1,r4       ; is var beyond the max
	jle floop1a   ; if not at max loop back up
	jmp forexit   ; exit for at max

floop1b:         ; negative increment
	c r1,r4      ; is var under min
	jlt forexit  ; if less than get out

floop1a:
	push r6      ; save address of index var
	popm r9      ; pop char location of first command in for loop
	pushm r9     ; save it back for next time
	push r1
	push r2
	push r4

floop1:          ; execute all commands on line
	clr r3
	movb *r9+,r3 ; get next char 
	ci r3,0      ; check if end of line
	jeq floopeol ; if yes eol jump out to increment var
	ci r3,0FF00h ; end of command/file
	jeq floopff ; 
	ci r3,Space  ; check if Space	
	jne forerr   ; for error

	movb *r9+,r3 ; get next char 	
	swpb r3      ; swap bytes for jump table in Parse
	bl @Parse    ; call parse to execute this command
	ci r3,0      ; check if end of line
	jeq floopeol ; if yes eol jump out to increment var
	jmp floop1   ; loop back up to get next command	

floopff ;
	dec r9       ; if FF then move back one char
	
floopeol:
   	
	pop r4        ; max
	pop r2        ; increment 
	pop r1        ; value numeric of variable
	pop r6        ; address of data for variable in for 
	a r2,r1       ; add increment to variable
	mov r1,r3     ; set up for call to toascii

	push r6
	push r1
	push r2
	push r4
	bl @toascstr  ; convert value in r3 to string at *r6  
	pop r4
	pop r2
	pop r1
	pop r6

	jmp floop     ;



forerr:
	li r1,1
	mov r1,@ErrNum
	
forexit:
	;pop r11 ; pop the max
	;pop r11 ; pop the increment
	mov @Forflg,r1
	ai r1,-1
	mov r1,@Forflg
	popm r11 ; waste pop of r9 from after for no longer needed
	pop r11 ; return address
	b *r11


forgetint:    ; read increment and max value

	push r11

	movb *r9+,r3 ; get next char 
	ci r3,Colon  ; check if colon		
	jne forerr   ; if not error
	bl @getmstr  ; get value after : the increment 
	popss r6     ; get string value
	bl @strtonum ; convert to numeric value in R7
	pop r11
	;push r7      ; push increment/max
	
	b *r11
