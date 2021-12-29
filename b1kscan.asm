GetStr: ; get string  - place in TIB - must be defined in calling prog 
	;               for know
	;; need to add checks for length and backspace etc
	;; pass in screen pos on stack

	pop r2          ; starting screen location 
	push r11
	mov r2,r15      ; save starting pos
	li r8,TIB       ; TIB is where get string returns entered string
	bl @gotoxy
	bl @Setcur
gs2	bl @PrintChar   ;  print cursor
	bl @gotoxy      ; move cursor
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
	;li r0,Cursor    ; cusor char
	bl @Setcur
	bl @PrintChar   ; 
	;xor @bit1,r0	; reset bit 1
	jmp gskey       ; go back up and get next one

	
endgs:
	clr r0
	movb r0,*r8   ; terminate the string in TIB
	bl @gotoxy
	li r0,SPACE
	bl @PrintChar

	pop r11
	b *r11


Setcur: 
	push r11
	li r0,Cursor    ; cusor char
	mov @PrtMode,r7 ; get inverse value
	ci r7,0         ; 0 not invers
	jeq setcurend         ; skip to gs2
	li r0,Space-6000h  ; inverse so so cursor to space-96
setcurend:
	pop r11
	b *r11

backspace:
	; r2 has screen position
	c r2,r15
	jeq gskey
	bl @gotoxy
	li r0,Space
	bl @PrintChar
	dec r2
	bl @gotoxy
	;li r0,Cursor
	bl @Setcur
	bl @PrintChar
	dec r8
	movb NULL,*r8
	jmp gskey

	

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


