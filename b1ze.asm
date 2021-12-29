ze:     ;  r9 - pointer to mem where code resides
	;  r8 - pointer to screen buffer in RAM
	;  r2 - Screen position in VDP RAM

	push r11    ; push return address of caller
 
      	push r9     ; save code pointer
	push r10    ; save stack pointer
	push r13    ; save stack pointer

	bl @clrscrbuf
	li r9,CODESTART  ; start at beginning of code 
	li r8,ScrBuf     ; 1k for working copy of VDP RAM
	invon
	li r2,840
	bl @gotoxy
	li r1,Blanks
	bl @PrintString
	li r1,Blanks
	bl @PrintString
	li r1,Blanks
	bl @PrintString
	invoff
	push r8
	push r9
	bl @copycodetobuf
	bl @copybuftoscr
	pop r9
	pop r8
ze2:	clr r2           ; start of top line
	bl @gotoxy       ; set vdp write pointer    
	movb @ScrBuf,r1  ; load cursor 
	li r3,0FF00h
	cb r1,r3
	jne zechcur
	li r1,Cursor
	jmp zecur	
zechcur:
	ai r1,6000h      ; 
zecur:	vsbw             ; print cursor char in r1

zegk:	bl @gotoxy      ; point back at where cursor is
	bl @getkey      ; get a keystroke
	clr r1          
	movb @keyin,r1  ; get the read key
	swpb r1         ; put key in lsb
	ci r1,CtrlX     ; ctrlx quit
	jeq zequit      ; if ctrl x quit
	ci r1,159       ; see if ctrl 9 - delete
	jeq ze_backsp   ; call move left  
	ci r1,8         ; see if left arrow key
	jeq ze_left     ; call move up
	ci r1,9         ; see if left arrow key
	jeq ze_right    ; call right
	ci r1,10        ; see if down arrow
	jeq ze_down     ;
	ci r1,11        ; see if left arrow key
	jeq ze_up       ; call move up
	ci r1,3         ; see if left arrow key
	jne gtkye       ; call move up delete char
	b @ze_del
gtkye	ci r1,13        ; enter move to next line
	jeq ze_enter    ; call enter
			; otherwise add key to text
	swpb r1         ; put key code back in MSB
	vsbw            ; write to screen in VDP RAM
	movb r1,*r8+    ; copy char to scrbuf
	li r1,Cursor    ; load cursor char (??)
	vsbw            ; write it
	inc r2          ; inc screen pos - this is where cursor is
	jmp zegk        ; go again

zequit:
	li r6,CODESTART
	bl @copybuf
	;li r1,0FF00h
	;movb r1,*r6

	pop r13
	pop r10
	pop r9

	pop r11
	b *r11

ze_up:
	bl @gotoxy
	movb *r8,r1
	vsbw
	ai r2,-40
	ai r8,-40
	jmp zelfcur
ze_down:
	bl @gotoxy
	movb *r8,r1
	vsbw
	ai r2,40
	ai r8,40
	jmp zelfcur



ze_left:
	mov r2,r4            ; copy screen pos to r4
	clr r3               ; clear r3
	mov @ScreenWidth,r5  ; screen width      
	div r5,r3            ; divide r3,r4 by r5 ( sceenpos by 40)
	ci r4,0              ; check if remainder is 0
	jeq zegk             ; if yes can't move left

	bl @gotoxy     ; move to screen pos in r2
	movb *r8,r1
	vsbw           ; write msb in r1 to screen
	dec r2         ; move screen pos one to left
	dec r8         ; move pos in ScrBuf

zelfcur:
	bl @gotoxy     ; mov to screen pos in r2
	               ; load r1 in Cursor (inv of char)
	movb *r8,r1
	ai r1,6000h
	vsbw           ; write Cursor to the screen
	jmp zegk       ; goto get key

ze_right:

	bl @gotoxy     ; move to screen pos in r2
	movb *r8,r1    ; get character at current screen pos
	cb r1,0        ; if a 0 (end of line)
	jeq zegk       ; exit
	vsbw           ; write msb in r1 to screen
	inc r2         ; move screen pos one to left
	inc r8         ; move pos in ScrBuf
	bl @gotoxy     ; mov to screen pos in r2
	               ; load r1 in Cursor (inv of char)
	movb *r8,r1
	cb r1,0
	jeq rtcur1
	ai r1,6000h
	jmp rtcur
rtcur1:
	li r1,1e00h   	
rtcur:
	vsbw           ; write Cursor to the screen
	b @zegk       ; goto get key



ze_backsp:

	mov r2,r4            ; copy screen pos to r4
	clr r3               ; clear r3
	mov @ScreenWidth,r5  ; screen width      
	div r5,r3            ; divide r3,r4 by r5 ( sceenpos by 40)
	ci r4,0              ; check if remainder is 0
	;jeq zegk             ; if yes can't move left
	jne zebacksp1
	b @zegk

zebacksp1:
	bl @gotoxy     ; move to screen pos in r2
	li r1,Space    ; load space into r1
	vsbw           ; write msb in r1 to screen
	dec r2         ; move screen pos one to left
	dec r8         ; move pos in ScrBuf
	clr r1         ; set r1 to 0
	movb r1,*r8    ; put 0 in ScrBug
	bl @gotoxy     ; mov to screen pos in r2
	li r1,Cursor   ; load r1 in Cursor
	vsbw           ; write Cursor to the screen
	;jmp zegk       ; goto get key
	b @zegk

ze_enter:
	bl @gotoxy     ; move to where cursor char is
	clr r1         ; set r1 to 0
	vsbw           ; write eol to screen
        inc r8
	mov r1,*r8     ; end of line in scrbuf
	li r7,40       ; calculate start of next line
	clr r3         ;
	mov r2,r3      ; 
	clr r2         ;
	div r7,r2      ;
	inc r2         ;
	mpy r7,r2      ;
	mov r3,r2      ;
	bl @gotoxy     ;
	li r8,ScrBuf   ;
	a r2,r8        ;
	li r1,Cursor
	vsbw
	b @zegk

ze_del:    ; delete char at cursor and shift all chars left until next 0

	push r8
	push r2
	mov r8,r7
zedel2:
	bl @gotoxy    ; r2 is screen pos already set
	inc r8
	inc r2
	movb *r8,r1
	vsbw	
	movb r1,*r7
	inc r7
	cb r1,0
	jeq delend
	jmp zedel2
delend:
	pop r2	
	pop r8
	bl @gotoxy

	b @zegk



clrscrbuf:  ; clear the screen buffer at FC00h
	li r8,ScrBuf    ; point to start of ScrBuf
	li r1,1024      ; set to 1024 chars
clrb1	clr *r8+        ; clr 
	dec r1          ; decrease count
	jne clrb1       ; if not end of buffer
	b *r11          ; return to caller


copycodetobuf:  ; copy code starting at R6 to screen Buffer FC00h
	        ; twenty lines of code filling in 0's for screen
		; r6 holds start of 800 char block in code area
	push r11
	push r2    ;
	push r1    ;
	bl @clrscrbuf
	li r7,ScrBuf
	li r5,ScrBuf
	li r2,20   ; twenty lines
	clr r3
	li r6,CODESTART  ; really will call with this
cctb1:
	movb *r6,r3
	movb *r6+,*r7+
	ci r3,0
	;jeq cctbend
	jeq cctb0		
	jmp cctb1

cctb0:
	ai r5,40
	mov r5,r7
	dec r2
	jeq cctbend
	jmp cctb1
cctbend:
	pop r1
	pop r2
	pop r11
	b *r11


copybuftoscr:
	push r11
 
	clr r2
	bl @gotoxy
	li r3,800
	li r6,ScrBuf
cbts:	
	movb *r6+,r1
	vsbw
	dec r3
	jne cbts
	
	pop r11
	b *r11


copybuf:  ; copy text in screen buffer FC00h to ram pointer removing extra 0
	  ; pass in ram location in in r6
	li r7,ScrBuf      ; start of screen buffer 
	li r1,800         ; all 800 chars
	clr r3            ; clr temp char register
copybuf2:
	movb *r7,r3       ; get current char
	movb *r7+,*r6+    ; copy a byte
	dec r1            ; dec counter
	jeq copybufend    ; if counter 0 done
	ci r3,0           ; if byte a 0
	jeq copybuf3      ; if yes then skip blanks
	jmp copybuf2

copybuf3:  ; skip blnaks
        movb *r7,r3       ; read char 
	ci r3,0           ; is it a 0
	jne copybuf2      ; if not continue copying 
	inc r7            ; move to next char
	dec r1            ; reduce counter
	jne copybuf3      ; is it the last counter
copybufend:
	b *r11            ; return to caller
	
