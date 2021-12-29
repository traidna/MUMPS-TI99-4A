	;;;; Bank1 main program

b0_ProgramStart    equ 0601Ch

	include stack.mac
	include equ.asm
	include am1.h


kickback:
	lwpi WKSPACE
	limi 0
	li r1,b0_ProgramStart
	push r1
	b @RetBank0

;;;;;;;;;; bank switch incomming - do not add any code above 
;;;;;;;;;; or move the b1XXX below unless you change the equates
;;;;;;;;;; in equ.asm this allows code in bank0 to call
 
b1getstr:  ; kscan -> GetStr
        pop r1        ; return address
        pop r2        ; screen pos
        push r1       ; return address
        push r2       ; screen pos - popped off in GetStr
        bl @GetStr    ; do getstring
        b @RetBank0   ; Bank 0
 
b1getkey:     ; b1kscan -> getkey
        bl @getkey
        b @RetBank0

b1ramdump:   ; b1ramutils -> ramdump
	bl @ramdump ; r4:address r5:number of words (bytes?)
	b @RetBank0

b1ShowHex4:
	bl @ShowHex4
	b @RetBank0

b1fileio: ; iolib.asm
	bl @fileio
	b @RetBank0

b1clrampab:   ; iolib.asm
	bl @clrampab
	b @RetBank0

b1zwrite:     ; b1zwrite.asm
	bl @zwrite
	b @RetBank0

b1zremove:    ; b1zwrite
	bl @zremove
	b @RetBank0

b1zload1:     ; b1z.asm
	bl @zload1
	b @RetBank0

b1zsave:       ; b1z.asm
	bl @zsave
	b @RetBank0
b1zlist:      ; b1z.asm
	bl @zlist
	b @RetBank0
b1zinsert:
	bl @zinsert
	b @RetBank0
b1zm2:
	bl @zm2
	b @RetBank0
b1ze:  
	bl @ze
	b @RetBank0
b1minit: 
	bl @mumpsinit
	b @RetBank0
b1Sound:
	bl @Sound
	b @RetBank0
b1Speech:
	bl @Speech
	b @RetBank0
b1Speech2:
	bl @Speech
	b @RetBank2
b1ShowHex4_2:
	bl @ShowHex4
	b @RetBank2	
b1Text40:
	bl @Text40
	b @RetBank0
b1Graph32:
	bl @Graph32
	b @RetBank0
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;   includes should all be added below ;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include samslib.asm
	include b1kscan.asm
	include prtlib.asm	
	include bank1lib.asm
	include b1mon.asm
	include b1ramutils.asm
	include vdplib.asm
	include iolib.asm
	include dsrlnk.asm	
	include b1z.asm
	include b1ze.asm
	include strlib.asm
	include soundlib.asm
	include utils.asm
	include charlib.asm
mumpsinit:
	push r11
    	
	bl @defcursor     ; create cursor definition
	bl @copychardef   ; copy TI Basic character defs to VDP mem	
		
	li r0,351Ah         ; hello address for speech
	bl @Speech          ; say the word at address in R0
		
	clr @HaltFlag       ; set haltflag to 0 - keep parsing
    clr @ErrNum         ; set ErrNum to 0   - no errors
    clr @Head           ; set Head of btree to empty
    clr @Forflg         ; set for flag to off
    clr @Doflg          ; set do flag to 0
	clr @PrtMode        ; inverse or regular
    clr @fioerr         ; file io error code
    clr @Memmapper      ; mem mapper toggle
	li r0,Bank2Map
	li r1,4
initbanks:
	clr @r0            ; clr first two bytes
	inct r0            ; increment by two
	dec r4             ; decrease counter
	jne initbanks      ; loop up if counter not 0
	
    li r2,MFALSE
    mov r2,@DolT        ; init $T to '0' character
    li r2,MFALSE
    mov r2,@Dolio       ; $IO default to 3000h for console '0'
    li r2,CODESTART
    mov r2,@CodeTop     ; Iintial CodeTop ( next addres for M code)
    li r1,EOF           ; Initial code space
    mov r1,*r2          ; put end of file at first space in code mem

    ; li r14,0601Eh ; load code bank2
    ; bl @GoBank2
	

    li r2,VARINDEX
    mov r2,@VIptr         ; initialize ptr to var index
    li r2,VARDATA
    mov r2,@VDptr         ; initialize ptr to var data


	mov @ScreenWidth,r0
	ci r0,40
	jne initscr32
	
	bl @Text40
  	jmp init2
	
initscr32:
	li r0,1
	bl @SetBorderCol
	li r1,07100h
	bl @SetColors
	
init2:	

    li r0,0384h
	li r1,045h
	bl @vsbr
	

	; initialize base maps - map to actual physical page to start
        
    li R1,2
    li R2,4004h
initmap:
	swpb r1
    bl @mappage
	swpb r1
    inc r1
    inct R2
    ci R1,16
    jne initmap
	
	splash: 
	clr r2
	bl @gotoxy
	bl @CLS

	mov @ScreenWidth,r0
	ci r0,40
	jne splash32

	invon
	li r1,StarStr
    bl @PrintString
    li r1,SplashStr    ;ascii string address
    bl @PrintString    ;0 terminated string
    li r1,StarStr
    bl @PrintString
	bl @CR
	invoff
	jmp initend
	
splash32:	
	invon
	li r1,StarStr32
    bl @PrintString
	li r1,SplashStr32
	bl @Printstring
	li r1,StarStr32
    bl @PrintString
	invoff
	
initend:	

	pop r11
	b *r11

SplashStr32:
	byte "*  Andiar System Mumps v 0.8   *",0
	align 2
StarStr32:
    byte "********************************",0
    align 2	

	
SplashStr:
    byte "*      ANDIAR SYSTEMS MUMPS V 0.8      *",0
    align 2
StarStr:
    byte "****************************************",0
    align 2	
	
b1msg:  
	byte "BANK 1 MSG"
	byte 0
	align 2
Threeblanks:
	byte "   ",0
BankMsg1:
	byte "[B]ank 2: 2   10: 10   12: 12   14: 14  ",0
	align 2
BankMsg2:
	byte "Bk:Pg  3: 3   11: 11   13: 13   15: 15 ",0
	align 2
zmbanktbl:     ; Screen locations for monitor : SAMS banks
	word 850,890,858,898,866,906,875,915
zlmsg:   
	byte "LOADING FROM : ",0
    align 2
zsmsg:   
	byte "SAVING TO : ",0
    align 2
PressMsg: 
	byte "PRESS ENTER TO CONTINUE",0
    align 2
ZIMsg:   
	byte "ENTER LINE OF CODE TO INSERT:",0
    align 2
PQmsg:   
	byte "[P]rev  [N]ext  [Q]uit",0
    align 2
Amsg:    
	byte "[A]ddr  ",0
	align 2
ADmsg:   
	byte "Addr : ",0
	align 2
Mmsg:
    byte "[M]ap  ",0
	align 2
Onmsg:   
	byte "On",0
	align 2
Offmsg:  
	byte "Off",0
	align 2
Blanks:
	byte "                                        ",0
	align 2
H10  byte 10h
HHAA byte 0AAh	
	align 2

  	;;; nothing else below this line ;;;;;;;;;;;;;;;
	org 07FFFh  ; set org to last byte in the bank
	byte 0      ; place a value in the byte makes it 8K

