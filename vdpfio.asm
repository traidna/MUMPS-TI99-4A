;vsbw:   macro p1          ; single byte write to VDP
;        movb p1, @08C00h  ; assumes address is already positioned with
;        endm              ; setVDPwaddr (pass address in r0 )


	; clear 80 byers to 0's starting at BUFADR
	; leaves VDP write address at end of buffer
clrVDPbuf:
	push r11

	li r0,BUFADR
	bl @setVDPwaddr
	clr r1
	li r2,80
clrvdp:
	vsbw          ; write msb of r1 to vdpmem
	dec r2        ; reduce counter
	ci r2,0       ; counter =?
	jne clrvdp    ; if not zero return
	pop r11
	b *r11        ; retrun to caller
		
	
;[ vdp single byte read
; inputs: r0=address in vdp to read, r1(msb), the byte read from vdp
; side effects: none

vsbr    
        swpb r0                 ; get low byte of address
        movb r0,@8C02h           ; write it to vdp address register
        swpb r0                 ; get high byte
	andi r0,03FFFh
        movb r0,@8C02h          ; write
        movb @8800h,r1           ; read payload
                ;rt                      ; see ya
        b *r11


 

vmbw:  
	; r0 number of chars
	; r1 address of string	
vmbwloop:
	movb *r1+,@08C00h
	dec r0
	jne vmbwloop
	b *r11	
	

VDPtoRAM:  ;pass in r0 as VDP start addr
           ; pass in r2 the RAM address

	push r11
        clr r1
copytoram:
        bl @vsbr          ; pass vdp addess and read byte 
	                  ; (should not need to send addr)
	                  ; returns bye in msb of r1
        inc r0            ; inc vdp address
        movb r1,*r2+      ; store in ram
        ci r1,0h          ; is it end of line
        jne copytoram     ; if not end of file keep going
	
	pop r11
	b *r11






