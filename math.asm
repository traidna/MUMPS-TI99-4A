
Math:   ; send operator in r3
	; left and rigth values on string stack 
	push r11
	;push r3

	popss r6      ; pop right side string ptr
	bl @strtonum  ; convert to value
	mov r7,r5     ; right value

	popss r6
	mov *r6,r3    ; get operator

	push r3
	popss r6      ; pop left side string
	bl @strtonum  ; convert to value returns value in r7

	pop r3              ; get operator

add:	ci r3,Plus    ; is it a plus sign 
	jne sub       ; if not jump to next operator
	a r7,r5       ; add left to right store in right
	jmp math2     
sub:
	ci r3,Minus  ; is it subtraction
	jne mult     ; jump to next operator
	neg r5       ; make right side negative
	a  r7,r5     ; add (which is subtract) 
	jmp math2    

mult:	ci r3,Asteric ; is it a plus sign 
	jne div       ; if not jump to next operator
	mpy r7,r5     ; value in r5,r6
	mov r6,r5     ; need to charlib to 4 bytes 
	jmp math2     

div:    ci r3,Slash  ; is it a '/'
	jne mathgrtr
	clr r6
	div r5,r6    ; divide r4-r5 by r7
	mov r6,r5
	jmp math2

mathgrtr:
        ci r3,Greater  ; is it a '>'
	jne mathlessthan
	c r7,r5        ; r7 left > r5 right
	jgt istrue
	jmp isfalse

mathlessthan:   
        ci r3,LessThan  ; is it a '<'
	jne modolo
	c r7,r5        ; r7 left < r5 right
	jlt istrue
	jmp isfalse

	

modolo:    
        ci r3,Hashtag  ; is it a '#'
	jne matherr
	clr r6
	div r5,r6    ; divide r4-r5 by r7
	mov r7,r5
	jmp math2

istrue:
	li r3,1	
	jmp math3

isfalse:
	clr r3
	jmp math3

math2:	mov r5,r3     ; move to r3 for toascstr

math3:	pushss r6     ; get new string stack ptr for result
	bl @toascstr  ; convert value to a string

exitmath:
	pop r11       ; done with ADD return
	b *r11

matherr: 
	li r1,17       ; unknow math operator
	mov r1,@Errnum ;
	jmp exitmath

unaryop:
	;push r11
	push r3          ; operator
        pushss r6        ; create left side of op expression
 
	li r3,Zero       ; load with 0
        movb r3,*r6+     ; '0'
        clr r3           ; 
        movb r3,*r6      ; terminate with null

	pushss r6
	pop r3
	mov r3,*r6+
	push r3

	bl @getvalue      ; right side
	pop r3           ; get operator back
	bl @math         ; do operator
        b @exitgetmstr    ; jump back to mstr - exit getvalue 


strtonum:   ; converts a number in a string to a value in a register
	    ; pass string address in r6
	    ; value returned in r7
	    ; if string is not a number then return 0
	    ; will interpret digits until not a digit "12ab" returns 12
	    ; integer values only for now

	push r11
	clr r8
	clr r3            ; intialize return value
	clr r1
	movb *r6+,r3       ; get first char
	ci r3,Minus
	jne stn1
	mov r3,r1
	movb *r6+,r3
	
stn1:	bl @isdigit       ; check if digit
	jne strtonumexit  ; no more digits
	swpb r3
	ai r3,-30h        ; subtract acsii value of '0' to get value
	mov r3,r7         ; value of first digit
	li r2,10
stnloop:
	clr r3
	movb *r6+,r3      ; get next char
	bl @isdigit       ; check for digit
	jne strtonumexit  ; no more digits
	swpb r3           ; move to lsb
	ai r3,-30h        ; calc val r3-'0'
	mpy r2,r7         ; answer in r7,r8 smaller amount in r8
	a r3,r8           ; add current digit to prev value *10
	mov r8,r7
	jmp stnloop       ; loop up to check next digit



strtonumexit:
	ci r1,0h
	jeq stnexit
	neg r7

stnexit	pop r11
	b *r11
