; Utils.asm

SetBorderCol: ; pass in R0 07XX where xx is border color
	push r11
	;li r0,0008h
	ori r0,8700h
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
	mov r11,r9       ; general use

    li r0,08F0h      ; address in VDP mem where cursor is stored
    bl @setVDPwaddr  ; set write pointer to this address
    li r3,8          ; loop 8 times
	li r1,07E00h     ; set bits to 01111110 will do 8 of these
	;li r1,0FF00h
curtop: 
	vsbw             ; write char  - msb of r2 
    dec r3           ; decrease loop counter
    jne curtop       ; loop back up if not done
	mov r9,r11       ; general use
	b *r11


copychardef:   ; copies char definitions from Grom (Basic) to 
	           ; VDP for use with Assembly programs
	mov r11,r9
	clr r3           ; 0 for reg 1 for inv 
                     ;li R0,0A08h     ; Location of A in VDP ram
	li r0,0900h      ; location of space in VDP ram
	bl @setVDPwaddr

                     ;li r2,079Bh      ; addres of A in Grom
cgtop:
    li r2,06B4h       ; address of space in GROM
	movb r2,@9c02h    ; Grom set read address port
    swpb r2
    movb r2,@9c02h
    swpb r2
    li r5,96          ; 96 characters to copy

copytop:
    li r6,7          ; 7 bytes in a char
    clr r1           ; this is the 8th byte in def
	ci r3,0          ; is this first 127 chars
	jeq copytop2     ; if yes then write is
	inv r1           ; if no then inv first

copytop2:	 
	vsbw                 ; write it
copygrom:
    movb @09800h,r1      ; Grom read and auto increment
	ci r3,0              ; check if first pass
	jeq copygrom2        ; if first pass reg chars
	inv r1               ; if second pass inv chars
copygrom2:
    vsbw                 ; single byte write
	dec r6               ; dec ctr for this char
    jne copygrom         ; if not 0 loop
    dec r5               ; dec char counter
    jne copytop          ; if not all chars loop back up
    
	inc r3               ; pass counter 
	ci r3,2              ; if second pass done
	jlt cgtop            ; if not done second pass loop up

cgend:
	mov r9,r11
	b *r11

	
Text40:         ; set to text mode - 40 columns
                ; pass Fg BG color in r1
	push r11
	
	
    li r2,0F000h            ; bit 3 on for Text mode in VDP Register 1 (129)
	movb r2,@8C02h
    movb r2,@83D4h
    li r2,129               ; VDP Register one
    swpb r2
    movb r2,@8C02h
	
    movb r1,@8C02h
    li r1,128+7
    swpb r1
    movb r1,@8C02h
	li r1,40
	mov r1,@ScreenWidth
	pop r11
	bl *r11


Graph32:  ; pass in FG/GB in msb of R1 and Border color in R0
	push r11

    li r2,0E000h            ; bit 3 off for Graphics mode in VDP Register 1 (129)
	movb r2,@8C02h
    movb r2,@83D4h
    li r2,129               ; VDP Register one
    swpb r2
    movb r2,@8C02h
	bl @SetBorderCol
	bl @SetColors
	
	pop r11
	bl *r11

		
