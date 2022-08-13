   ;; dol.asm - instrinsic functions and $ sys vars

getparams:   ; $*(p1,p2,p3,p4) - flags r0->p1, r12->p2, r15->p3
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

	li r15,1         ; flag param3 on stack
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
	li r3,15       ; missing paren
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
	swpb r7          ; swap byte and move to string
	pushss r6
	mov r7,*r6+      ; move to string
	clr r1           ; put NULL in r1
	mov r7,*r6       ; terminate string	

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
	dec r12          ; position is 0 based so dec counter
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
 dolp1: 
	popss r6         ; get the string
    bl @strtonum     ; make is a number
    mov r7,r15       ; move to r15

dolp2:  
	ci r12,0         ; is there a second param
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




doll:   ; $l(string) returns length of a string
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
	push r11         ; save caller retrun address
	pushss r6        ; get a string address to retrun value
	mov @DolT,*r6    ; get value from DolT from scratch pad
	pop r11          ; get caller return addr
	b *r11           ; return

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
    li r1,22		; bad function call
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



dolx:   ;; $x(num) moves screen position to num
	push r11
	
	bl @getparams    ; get params r0 string
	popss r0         ; get value of param one off string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	mov r7,r2        ; copy value to r2 for gotoxy
	bl @gotoxy       ; set VDP write position in value
	pushss r7        ; get a string stack memory space
	mov r0,r6        ; copy value passed to r6
	bl @strcopy      ; copy to memory to pass back
	pop r11          ; get caller address
	b *r11           ; branch back to caller

dolv:   ; non standard dol function - $v(addr) peek addr
        ; return byte value at address passed
		; 
	
	push r11
	
	bl @getparams    ; get params r0 string
	popss r0         ; get value of param one off string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	clr r3
	movb *r7,r3      ; get value at address passed
	swpb r3
	pushss r6        ; get string space to return the value
	bl @toascstr     ; conver value to a string
	
	pop r11
	b *r11


dolw:   ; non standard dol function - $s(addr) vdp memory peek addr
        ; return byte value at address passed
		; 
	
	push r11
	
	bl @getparams    ; get params r0 string
	popss r0         ; get value of param one off string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	clr r3
	
	; movb *r7,r3      ; get value at address passed replace with VDP single byte read
	;[ vdp single byte read
	; inputs: r0=address in vdp to read, r1(msb), the byte read from vdp
	; side effects: none
	; vsbr:    
    ; R7 has address (replace r0 with R7 from VSBR and return addr into R3 instead of R1
	swpb r7                 ; get low byte of address
    movb r7,@8C02h           ; write it to vdp address register
    swpb r7                 ; get high byte
	andi r7,03FFFh
    movb r7,@8C02h          ; write
    movb @8800h,r3           ; read payload
    
    ;;;;;;;
	
	swpb r3
	pushss r6        ; get string space to return the value
	bl @toascstr     ; conver value to a string
	
	pop r11
	b *r11



dolk:   ; poke $k(addr, value) pokes value into CPU addressable address

	push r11
	
	bl @getparams    ; get params r0 string
	ci r12,0
	jeq dolkerr      ; 
	popss r0         ; get value of param one addressoff string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	push r7
	popss r0         ; get value of param one addressoff string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	pop r8
	swpb r8
	movb r8,*r7       ; move value to address in r7
        pushss r6
	mov r8,r3
	swpb r3
	bl @toascstr
dolkend:
	pop r11
	b *r11

dolkerr:
	li r1,21
	mov r1,@ErrNum
	jmp dolkend


dolq:   ; poke $Q(addr, value) pokes value into VDP addressable address
        ; poke $Q(value) at current VDP address VDP is auto incrementing

	push r11
	
	bl @getparams    ; get params r0 string
	ci r12,0
	jeq dolqerr      ; 
	popss r0         ; get value of param one addressoff string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	push r7
	popss r0         ; get value of param one addressoff string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	
	mov r7,r0        ; move VDP write address to R0 for setVDPwadddr
	bl @setVDPwaddr  ; set up write to address
	;mov r8,r1
	pop r1           ; pop param that is the byte to write
	swpb r1          ; put byte in msb position
	vsbw             ; write the value to VDP memory
	pushss r6        ; get a string stack address 
	;mov r8,r3        ;        
	mov R1,R3
	swpb r3          ; move the value written to R3 to be retrun value
	bl @toascstr     ; convert value in msb of R3 to string at R6
dolqend:
	pop r11
	b *r11

dolqerr:
	li r1,27
	mov r1,@ErrNum
	jmp dolkend
	
	

dolb:   ; mapbank  $m(page, block) maps page 0-247 to block address
	; 
        ; R1 - pass in page in msb of R1 xx00h
        ; R2 - pass in 4k block address to map to ()
		; Block   Register    Address
        ;  2        4004h     2000h
		;  3        4006h     3000h
        ; 10        4014h     A000h
		; 11        4016h     B000h
		; 12        4018h     C000h
        ; 13        401Ah     D000h
		; 14        401Ch     E000h
		; 15        401Eh     F000h

	push r11
	
	bl @getparams    ; get params
	ci r12,0         ; 
	jeq dolberr      ; 
	popss r0         ; get value of param two addressoff string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	push r7
	popss r0         ; get value of param one addressoff string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	clr r1
	mov r7,r1        ; page number
	swpb r1
	pop r2           ; bank number
	bl @savemap
	a  r2,r2         ; double bank number to create address
	ai r2,16384      ; base of 4000h = 16384
	bl @mappage
	pushss r6        ; gets popped by caller (set or write)

dolbend:
	mapperoff        ; seting up map does not turn it on
	pop r11
	b *r11

dolberr:
	li r1,20
	mov r1,@ErrNum
	jmp dolbend

	
savemap:   ; save page to CPU scratch pad for tracking

	push r2          ; save r2 bank number
	ci r2,10         ; compare r2 to 10
	jlt savemap2     ; if less than 10 jump
	ai r2,-8         ; else map number to address
	jmp savemap3
savemap2:
	ai r2,-2        ; it's either 2 or 3 so offset 0 or 1
savemap3:	
	ai r2,Bank2Map  ; get storege address of bank in Scratchpad
	movb r1,*r2     ; store it
	pop r2          ; bank number
	b *r11
	

dolm:   ;  turn on/off SAMS card mapping
	; if param = 1 turn on mapper
	; if param =0 turn off mapper 
	; if second parameter, copy code to SAMSTRAMP and set R9 to SAMSTRAMP
	
	push r11
	clr r3             ; clear r3
	movb *r9,r3        ; move current char to r3 msb
	ci r3,OpenParen    ; is it a Open paren
	jne dolmvalue      ; if not then just return current mapper value
	
	bl @getparams      ; get params
	ci r12,0           ; check if a second param exisits
	jeq dolmonlyswitch ; no second param
	
	popss r6           ; get code off string stack
	li r7,SAMSTRAMP    
	bl @strcopy         ; copy to code to trampoline area
	pushm r9
	li r9,SAMSTRAMP
	
dolmonlyswitch:
	popss r6         ; get value of param two addressoff string stack
	bl @strtonum
	ci r7,0
	jne dolm2
	mapperoff
	jmp dolmend
dolm2:	
	mapperon

dolmend:
	pushss r6
	pop r11
	b *r11

	
dolmvalue:
	clr r3
	mov @MemMapper,r3
	;swpb r3 
	pushss r6
	bl @toascstr
	pop r11
	b *r11
	
	

dols:   ; non-standard - sound
	; $s(channel, tone, volume)
	; channel 0,1,2,3 - tone .XXXh - volume - 0 - 15 15 = mute 
	push r11

	bl @getparams    ; get params
	ci r15,0         ; check that 3 params are entered 
	jeq dolspch      ; 
	popss r0         ; get value of param 3 addr (volume) string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	push r7          ; push volume to stack
	popss r0         ; get value of param two (tone) addressoff string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	push r7          ; push tone to stack
	popss r0         ; get value of param 1 addr (channel) string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	push r7          ; push channel to stack
	pop r2           ; channel
	pop r3           ; tone
	pop r4           ; volume
	push r2          ; push channel to return
	li r14,b1Sound_a
	bl @GoBank1
	;bl @Sound        ; play sound
dolstrn:
	pop r3           ; chanel / speech addr
	pushss r6        ; get string addrss on string stack
	bl @toascstr     ; convert chanel to string
	jmp dolsend

dolspch:             ; is it speech?
	ci r12,0
	jne dolserr
	ci r0,1
	jne dolserr
	popss r0         ; get value of param 1 addr (channel) string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	push r7
	mov r7,r0
	li r14,b1Speech_a
	bl @GoBank1
	jmp dolstrn
	
		
dolserr:
	li r1,19
	mov r1,@Errnum
	
dolsend:

	pop r11
	b *r11

dolh:   ; pass in hex string return decmimal number
	    ; $h(string) string must be valid hex string
        ; error checking?
		
	push r11
	
	bl @getparams    ; get params r0 string
	ci r12,1         ; r12 is flag for param 2
	jeq dolherr      ; if not zero wrong number of params
	popss r0         ; get value of param one address off string stack
	push r0          ; copy pointer to string to stack for hstrtonum later
	push r0          ; push address of string to stack
	bl @strlen       ; get length of string returned on stack
	pop r2           ; pop length off stack
	ci r2,4          ; compare length to 4
	jgt dolherr      ; if larger then error
	mov r2,r2        ; check if length of sting is 0
	jeq dolherr      ; if 0 then err
	pop r6
	bl @hstrtonum    ; convert hex string to it's decimal equiv.
	mov r7,r3        ; move value to R3 for toascstr
	pushss r6        ; get string space to return the value
	bl @toascstr     ; conver value to a string
	jmp dolhend
	
dolherr:
    li r1,18
	mov r1,@Errnum

dolhend:	
	pop r11
	bl *r11

doln:    ; screen parameters
		 ; first parameter set (32 or 40 columns)
		 ; Seconpar (>$XY) X Fg COLOR y bG COLOR
		 ; Third par - border color
		 ;  S BL=$N(40,23,1) 
		 
	push r11
	
	bl @getparams    ; get params r0 string
	ci r15,0         ; make sure three params
	jeq dolnerr
	popss r0         ; get value of param 3 off string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	mov r7,r0        ; border color in r0 lsb
	push r0
	
	popss r0         ; get value of param 2 off string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	mov r7,r1        ; border color in r0 
	swpb r1
	push r1
	
	popss r0         ; get value of param 1 off string stack
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r7
	ci r7,40         ; check if request for 40 columns
	jne doln32       ; if not check for 32 column
	
	mov r7,@ScreenWidth    ; update system var for screen width
	bl @Cls                ; Clear screen
	pop r1
	pop r0
	li r14,b1Text40_a      ; set addr for call to Text40
	bl @GoBank1            ; make call
	
	jmp doln2              ; jump to code to return value

doln32:
	ci r7,32
	jne dolnerr
	mov r7,@ScreenWidth   ; update system var for screen width	
	pop r1
	pop r0
	li r14,b1Graph32_a
	bl @GoBank1
	bl @Cls

doln2:
	mov r7,r3
	pushss r6        ; get string space to return the value
	bl @toascstr     ; conver value to a string
	jmp dolnend
	
dolnerr:
	li r1,26
	mov r1,@Errnum

dolnend:
	pop r11
	b *r11
	
	
dolj:   ; joystick ( pass in stick one or two ??)
	
	push r11

	bl @getparams    ; get params r0 string
	popss r0
	mov r0,r6        ; copy pointer to string to r6 
	bl @strtonum     ; uses r6 to convert string to num in r8
	
	li r6,0

	li r2,2500h			;Pause
Delay:		
	dec r2
	jne Delay
	
	
chkjoy:		
	mov r10,r8
	li r10,0100h		;Byte=1
	LI R12,0024h     	;Point CR reg (R12) to Keyboard Matrix 0024h
	LI R1,0600h       	;Line 6 - Joy 1  modify this for joy 2 later
	LDCR R1,3           ;Select 
	LI R12,0006h      	;CRU address of the keyboard rows 
	mov r8,r10
	
Fire:
	tb 0
	jeq NoFire
	li r3,15
	jmp chkjoyexit
	
NoFire:	
	tb 1				;Test Bit 1 (Left)
	jeq NoLeft
	li r3,1
	jmp chkjoyexit      
	
NoLeft:
	tb 2				;Test Bit 2 (Right)
	jeq NoRight
	li r3,2
	jmp chkjoyexit      
NoRight:
	tb 3				;Test Bit 3 (Down)
	jeq NoDown
	li r3,3
	jmp chkjoyexit      
NoDown:
	tb 4				;Test Bit 4 (Up)
	jeq NoUp
	li r3,4
	jmp chkjoyexit      

NoUp:
		
chkjoyexit:  
	pushss r6
	bl @toascstr

	pop r11
	b *r11






