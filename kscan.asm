GetStr: ; get string  - place in TIB - must be defined in calling prog 
	;               for know
	;; need to add checks for length and backspace etc
	;; pass in screen pos on stack
	;; add Cursor

	pop r2          ; starting screen location 
	push r11
	mov r2,r15      ; save starting pos
	;ori r15,4000h   ; 
	li r8,TIB       ; TIB is where getstring returns entered string
	bl @gotoxy
	li r0,Cursor    ; cusor char
	bl @PrintChar   ; 
	bl @gotoxy
gskey:
	bl @getkey      ; call keyscan - ascii code returned in r7
	ci r7,0D00h     ; is it a enter? 
	jeq endgs       ; if yes done

	ci r7,0800h     ; is it backspace
	jeq backspace   ; proccess backspace
	
	movb r7,*r8+    ; store it and inc TIB pointer
	bl @gotoxy      ; uses screen pos in r2
	mov r7,r0       ; copy ascii value from kscan to r0
	bl @PrintChar   ; ascii value in r0 
	inc r2          ; inc screen pos
	li r0,Cursor    ; cusor char
	bl @PrintChar   ; 
	;xor @bit1,r0	; reset bit 1
	jmp gskey       ; go back up and get next one

	
endgs:
	clr r0
	movb r0,*r8   ; terminate the string in TIB

	;mov @CursorPos,r2
	;dec r2
	bl @gotoxy
	li r0,SPACE
	bl @PrintChar

	pop r11
	b *r11

backspace:
	; r2 has screen position
	c r2,r15
	;jmp $
	jeq gskey
	bl @gotoxy
	li r0,Space
	bl @PrintChar
	dec r2
	bl @gotoxy
	li r0,Cursor
	bl @PrintChar
	dec r8
	movb NULL,*r8
	jmp gskey



gotoxy: ; screen position in r2
	limi 2                  ; briefly enable interrupts
	limi 0                  ; disable interupts
	ori r2,04000h           ; tell VDP processor this is a *write*
	swpb r2                 ; get low byte of address
	movb r2,@8c02h          ; write it to vdp address register
	swpb r2                 ; get high byte of address
	movb r2,@8c02h          ; write address to VDP register
	andi r2,00FFFh
	mov r2,@CursorPos       ; update MUMPS system var screen pos
	b *r11                  ; return to caller


        ; keyqsr
getkeyb: ; reads key from keyboard - returned in @keyin  
	push r11

	li r1,0500h          ; parameter for scanning 
	;mov r1,@keydev       ; keydev in rom not writeable   
	movb r1,@8374h  ; set keyboard to scan

	; detect key down
	clr r7            ; clear for call to kscan
getkeyb2 lwpi 083e0h       ; use gpl workspace
        bl   @000eh       ; call keyboard scanning routine
        lwpi WKSPACE      ; restore to our workspace
	movb @keyin,r7    ; a new key was pressed: get ascii code in r7 msb
	ci r7,0FF00h      ; check if no key pressed
        jeq getkeyb2       ; if no key try again

        ; wait for key up
	clr r11
getkeyb3 lwpi 083e0h       ; use gpl workspace
        bl @000eh         ; call keyboard scanning routine
        lwpi WKSPACE      ; restore to our workspace
	movb @keyin,r11   ; a new key was pressed: get ascii code in r11 msb
	ci r11,0FF00h     ; check if no key pressed key up
        jne getkeyb3       ; if key down repeat

	;mov r12,@83d6h   ; defeat auto screen blanking

	push r2
	mov @CursorPos,r2
	;li r2,0h
	bl @gotoxy        ; reset screen pos
	pop r2
	pop r11

	b *r11
	

        ; keyqsr
getkey: ; reads key from keyboard - returned in @keyin
        push r11

	li r1,0500h          ; parameter for scanning 
	;mov r1,@keydev       ; keydev in rom not writeable   
	movb r1,@8374h  ; set keyboard to scan


        ; wait for key up
        clr r11
getkey3 lwpi 083e0h       ; use gpl workspace
        bl @000eh         ; call keyboard scanning routine
        lwpi WKSPACE      ; restore to our workspace
        movb @keyin,r11   ; a new key was pressed: get ascii code in r11 msb
        ci r11,0FF00h     ; check if no key pressed key up
        jne getkey3       ; if key down repeat


        ; detect key down
        clr r7            ; clear for call to kscan
getkey2 lwpi 083e0h       ; use gpl workspace
        bl   @000eh       ; call keyboard scanning routine
        lwpi WKSPACE      ; restore to our workspace
        movb @keyin,r7    ; a new key was pressed: get ascii code in r7 msb
        ci r7,0FF00h      ; check if no key pressed
        jeq getkey2       ; if no key try again

        push r2
        mov @CursorPos,r2
        ;li r2,0h
        bl @gotoxy        ; reset screen pos
        pop r2
        pop r11

        b *r11


