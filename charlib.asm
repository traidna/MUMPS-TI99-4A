	; ctype.h type routines
	; toupper
	; isalpaha
	; isdigit


toupper:   ; bl @toupper call with r3 set to char to conver
           ; value returned in r3 

        ci r3,96           ;compare to 96 
        jlt toupperend    ;if r0<96 then no conversion 
        ai r3,-32          ;R0=R0-32 (Covert lowercase to upper)
toupperend:
	b *r11



isalpha:    ; determine if character is uppercase alpha
            ; pass char in r3
            ; returns EQ if alpha NE if not

        ci r3,04100h    ; capital A in word format
        jlt isalphaend  ; not alpha
        ci r3,05A00h    ; Z
        jgt isalphalow  ; not alpah
	jmp alphagood	
isalphalow:
	ci r3,06100h
	jlt isalphaend
	ci r3,07A00h
	jgt isalphaend 
	
alphagood:
        c r3,r3        ; is alpha force true
isalphaend
        b *r11



isdigit:   ; determine if a character is a digit
           ; pass char in r3
           ; returns EQ if is digit, NE if not digit
        ci r3,3000h
        jlt isdigitend
        ci r3,3900h
        jgt isdigitend
        c r3,r3     ; set equal
isdigitend:
        b *r11


ishexdigit:    ;  determine if a character is a hex digit 0-9 A-F
	       ;  pass in r3

	push r11
	
	bl @isdigit    ; check if digit
	jeq ishexgood   ; if yes then done
	bl @isalpha    ; check if alpha char
	jne ishexend   ; if not then done
	ci r3,04600h   ; compare to F
	jgt ishexend   ; if greater than F quit
	               
ishexgood:
	pop r11  
	c r3,r3        ; good so force EQ before exiting
	jmp ishexend2
ishexend: 
	pop r11
ishexend2:
	b *r11


toascstr: 
	 ; convert a char (value in a byte) to a string with the ascii code/value
	 ; pass char in lsb of r3
	 ; pass address of string in r6
 	 ; uses r1,r2,r3,r6,r15 
	 

        clr r15        ; zero if nothing in string yet
	clr r2         ;
	mov r3,r2
	andi r2,8000h  ; 
	jeq toas
	li r2,Minus
	movb r2,*r6+
	inv r3 	
	inc r3

toas:	clr r2
	li r1,10000    ; r1 = 1000
	div r1,r2      ; div r2,r3 by r1 (1000) 
	ci r2,0        ; if r3 was < 1000
	jeq toascthous ; jmp to hand 10's part	    
	ai r2,30h      ; get 100's character 30h = '0'
	swpb r2        ; put in msb
	movb r2,*r6+   ; put in string
	li r15,1       ; something in sting


toascthous:
	clr r2         ; 
	li r1,1000      ; r1 = 100
	div r1,r2      ; div r2,r3 by r1 (100) 
	ci r15,0       ; was there a 100's place
	jne toascthous2   ; yes so must add a tens place even if 0 
	ci r2,0        ; if r3 was < 100
	jeq toascshuns  ; jmp to hand 10's part	    
toascthous2:
	ai r2,30h      ; get 100's character 30h = '0'
	swpb r2        ; put in msb
	movb r2,*r6+   ; put in string
	li r15,1       ; something in sting


toascshuns:
	clr r2         ; 
	li r1,100      ; r1 = 100
	div r1,r2      ; div r2,r3 by r1 (100) 
	ci r15,0       ; was there a 100's place
	jne toaschuns2   ; yes so must add a tens place even if 0 
	ci r2,0        ; if r3 was < 100
	jeq toascstens  ; jmp to hand 10's part	    
toaschuns2:
	ai r2,30h      ; get 100's character 30h = '0'
	swpb r2        ; put in msb
	movb r2,*r6+   ; put in string
	li r15,1       ; something in sting

toascstens:
	               ;  remainder in r3
	clr r2         ; clear r2 so r2,r3 is only r3 
	li r1,10       ; divide by 10
	div r1,r2      ; divid r2,r3 by r1 (10)
	ci r15,0       ; was there a 100's place
	jne toastens2   ; yes so must add a tens place even if 0 
	ci r2,0
	jeq toascsones  ; if zero jump to ones place
toastens2:
	ai r2,30h      ; get char for tens place  30h = '0'
	swpb r2        ; put in msb
	movb r2,*r6+   ; put in string
	li r15,1

toascsones:
	               ; ones place in remainder in r3
        ai r3,30h      ; char ones place char  30h='0'
	swpb r3        ; move to msb 
	movb r3,*r6+   ; put ones place char
	clr r2
	movb r2,*r6     ; terminat the string

	b *r11         ; return 
