	; Charlib routines for bank1
	; when returning a eq/ne can't go through bank switch code

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


ispchar:    ; is printable char 32 to 126 ( may expand for inverse chars...)
            ; pass char in lsb r3
            ; returns EQ if alpha NE if not

        ci r3,SPACE     ; space in word format
        jlt ispcharend  ; not printable char
        ci r3,TILDA     ; ~
        jgt ispcharend  ; not printable char
pchargood:
        c r3,r3        ; is alpha force true
ispcharend:
        b *r11


