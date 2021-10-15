vsbw:	macro             ; single byte write to VDP 
	movb r1,@08C00h   ; assumes address is already positioned with
	endm              ; setVDPwaddr (pass address in r0 )

SetBorderCol: ;
	push r11
	li r0,0707h
	ori r0,8000h
	swpb r0
	movb r0,@8C02h
	swpb r0
	movb r0,@8c02h
	pop r11
	b *r11

SetColors: ;   pass colors in msb of r1 background,text,0,0
	push r11

        li r0,0380h
putcol:
        bl @setVDPwaddr  ; set write pointer to this address
        vsbw             ; writes msb of r1
        andi r0,0FFFh
        inc r0
        ci r0,0039Fh
        jle putcol

	pop r11
	b *r11

	;  define a cursor as a block
defcursor: 
	;push r11        ; if set up to stack
	mov r11,r9      ; general use

        li r0,08F0h      ; address in VDP mem where cursor is stored
        bl @setVDPwaddr  ; set write pointer to this address
        li r3,8          ; loop 8 times
	;li r1,07E00h     ; set bits to 01111110 will do 8 of these
	li r1,0FF00h
curtop: vsbw             ; write char  - msb of r2 
        dec r3           ; decrease loop counter
        jne curtop       ; loop back up if not done
	;pop r11          ; if stacking
	mov r9,r11      ; general use
	b *r11


copychardef:   ; copies char definitions from Grom (Basic) to 
	       ; VDP for use with Assembly programs
	mov r11,r9

        ;li R0,0A08h     ; Location of A in VDP ram
	li r0,0900h      ; location of space in VDP ram
	bl @setVDPwaddr

        ;li r2,079Bh      ; addres of A in Grom
        li r2,06B4h       ; address of space in GROM
	movb r2,@9c02h    ; Grom set read address port
        swpb r2
        movb r2,@9c02h
        swpb r2
        li r5,95          ; 66
copytop:
        li r6,7
        clr r1
        ;movb r2,@8C00h       ; write to VDP memory
	vsbw
copygrom:
        movb @09800h,r1      ; Grom read and auto increment
        ;movb r2,@8C00h       ; write to VDP memory
      	vsbw
	dec r6
        jne copygrom
        dec r5
        jne copytop

	mov r9,r11
	b *r11


setVDPwaddr: ; pass address in r0 to set wheree to wrtie in VDP memory
        ori r0,04000h           ; tell VDP processor this is a *write*
        swpb r0                 ; get low byte of address
        movb r0,@8c02h          ; write it to vdp address register
        swpb r0                 ; get high byte of address
        movb r0,@8c02h          ; write address to VDP register
        b *r11                  ; return to caller




		
