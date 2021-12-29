
;[ pab opcodes
;open    equ 0                       ; open opcode
;close   equ 1h                      ; close opcode
;read    equ 2h                      ; read opcode
;write   equ 3h                      ; write opcode
;fwdrew  equ 4h                      ; restore/rewind opcode (fwd/rew)
;status  equ 9h                      ; status op-code
;]


;[ dsr link routine - Written by Paolo Bagnaresi
dsrlnk  word dsrlws                 ; dsrlnk workspace
        word dlentr                 ; entry point

dlentr  li r0,0AA00h
        movb r0,@haa                ; load haa
        mov *r14+,r5                ; get pgm type for link
        mov r5,@sav8a               ; save data following blwp @dsrlnk (8 or >a)
        szcb @h20,r15               ; reset equal bit
        mov @8356h,r0               ; get ptr to pab
        mov r0,r9                   ; save ptr
        mov r0,@flgptr              ; save again pointer to pab+1 for dsrlnk 
                                    ; data 8
        ai r9,0FFF8h                 ; adjust to flag
        bl @vsbr                    ; read device name length
        movb r1,r3                  ; copy it
        srl r3,8                    ; make it lo byter
        seto r4                     ; init counter
        li r2,namsto                ; point to buffer
lnkslp  inc r0                      ; point to next char of name
        inc r4                      ; incr char counter
        ci r4,0007h                 ; see if length more than 7 chars
        jgt lnkerr                  ; yes, error
        c r4,r3                     ; end of name?
        jeq lnksln                  ; yes
        bl @vsbr                    ; read curr char
        movb r1,*r2+                ; move into buffer
        cb r1,@decmal               ; is it a period?
        jne lnkslp                  ; no
lnksln  mov r4,r4                   ; see if 0 length
        jeq lnkerr                  ; yes, error
        clr @83D0h
        mov r4,@8354h               ; save name length for search
        mov r4,@savlen              ; save it here too
        inc r4                      ; adjust for period
        a r4,@8356h                 ; point to position after name
        mov @8356h,@savpab          ; save pointer to position after name
srom    lwpi 83E0h                  ; use gplws
        clr r1                      ; version found of dsr
        li r12,0F00h                ; init cru addr
norom   mov r12,r12                 ; anything to turn off?
        jeq nooff                   ; no
        sbz 0                       ; yes, turn off
nooff   ai r12,0100h                ; next rom to turn on
        clr @83D0h                  ; clear in case we are done
        ci r12,2000h                ; see if done
        jeq nodsr                   ; yes, no dsr match
        mov r12,@83D0h              ; save addr of next cru
        sbo 0                       ; turn on rom
        li r2,4000h                 ; start at beginning of rom
        cb *r2,@haa                 ; check for a valid rom
        jne norom                   ; no rom here
        a @dstype,r2                ; go to first pointer
        jmp sgo2
sgo     mov @83D2h,r2               ; continue where we left off
        sbo 0                       ; turn rom back on
sgo2    mov *r2,r2                  ; is addr a zero (end of link)
        jeq norom                   ; yes, no programs to check
        mov r2,@83D2h               ; remember where to go next
        inct r2                     ; go to entry point
        mov *r2+,r9                 ; get entry addr just in case
        movb @8355h,r5              ; get length as counter
        jeq namtwo                  ; if zero, do not check
        cb r5,*r2+                  ; see if length matches
        jne sgo                     ; no, try next
        srl r5,8                    ; yes, move to lo byte as counter
        li r6,namsto                ; point to buffer
namone  cb *r6+,*r2+                ; compare buffer with rom
        jne sgo                     ; try next if no match
        dec r5                      ; loop til full length checked
        jne namone
namtwo  inc r1                      ; next version found
        mov r1,@savver              ; save version
        mov r9,@savent              ; save entry addr
        mov r12,@savcru             ; save cru
        bl *r9                      ; go run routine
        jmp sgo                     ; error return
        sbz 0                       ; turn off rom if good return
        lwpi dsrlws                 ; restore workspace
        mov r9,r0                   ; point to flag in pab
frmdsr  mov @sav8a,r1               ; get back data following blwp @dsrlnk
                                    ; (8 or >a)
        ci r1,8                     ; was it 8?
        jeq dsrdt8                  ; yes, jump: normal dsrlnk
        movb @8350h,r1              ; no, we have a data >a. get error byte from
                                    ; >8350
        jmp dsrdta                  ; go and return error byte to the caller
dsrdt8  bl @vsbr                    ; read flag
dsrdta  srl r1,13                   ; just keep error bits
        jne ioerr                   ; handle error
        rtwp
nodsr   lwpi dsrlws                 ; no dsr, restore workspace
lnkerr  clr r1                      ; clear flag for error 0 = bad device name
ioerr   swpb r1                     ; put error in hi byte
        movb r1,*r13                ; store error flags in callers r0
        socb @h20,r15               ; set equal bit to indicate error
        rtwp

data8   word 8h                     ; just to compare. 8 is the data that
                                    ; usually follows a blwp @dsrlnk
decmal  byte '.'                    ; for finding end of device name
        align 2
h20     word 2000h


;[ restore code to scratch-pad ram
; accessing the disk via the disk DSR destroys some code in scratch pad
; restore the code in scratch pad before returning    
;rstsp   li r0,toram                 ; address of 1st source block
;        li r1,docol                 ; destination        
;rstsp1  mov *r0+,*r1+               ; copy a cell
;        ci r0,__dup
;        jne rstsp3 
;        li r1,_dup
;rstsp3  ci r0,padend                ; hit end of first block of code?
;        jne rstsp1                  ; loop if not
;        rt

