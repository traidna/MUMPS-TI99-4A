	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 	; file io - copy PAB in RAM to DVP memory
	; then calls dsrlnk to request io operation
	;
	; note : io error codes from bits 0-2 - the three msb bits
	; 000 - no error or bad device name if bit 2 of 837Ch set
	; 001 - device write protected
	; 010 - Bad open attributes or no records in realtive file
	; 011 - illegal operation
	; 100 - out of buffer space on the device
	; 101 - attempt to read past EOF or nonexistent relative record
	; 110 - device error
	; 111 - file error       
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


fileio:

	push r11           ;  save return address of caller

        li r0,PABADR       ; vdp memory address of PAB
        bl @SetVDPwaddr    ; set up to write here

        li r1,pabopc       ; PAB info in RAM
        li r0,30           ; size of PB record
        bl @vmbw           ; write to vdp memory (vdp multi byte write)

        li r6,PABADR+9     ; load length of filename to 8356h 
        mov r6,@08356h     ; needed by dsrlnk

        blwp @dsrlnk       ; call dsrlnk 
        word 8             ; needed by dsrlnk

	li r0,PABERR       ; set read address for DSRLNK error byte 
        bl @vsbr           ; read the error byte
	movb r1,@fioerr    ; put in ram ( access with $U in MUMPS )
	
	mov @CursorPos,r0  ; get last screen position
	bl @SetVDPwaddr    ; set VDP write register to screen pos
	
	pop r11            ; get call return address
	b *r11             ; return to caller


clrampab:    ; clear out the ram PAB
	li r6,pabopc      ; set to start of ram pab 
	li r1,30          ; clear 30 bytes
	clr r7            ; set r7 to 0
clrrploop:
	movb r7,*r6+      ; clear byte at r6 and increment
	dec r1            ; decrease counter
	jne clrrploop     ; counter 0 then done
	b *r11            ; return to caller
