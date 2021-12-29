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


