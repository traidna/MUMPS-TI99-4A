	; s.asm - Set command
Set: 	; 
	push r11

        clr r3           ; zero out r3
        movb *r9+,r3     ; read char after S and advance past
        ci r3,2000h      ; is it space should be
        jeq Set2         ; if good jump down
        li r1,12         ; missing space syntax error
        mov r1,@ErrNum   ; set error num
        jmp setend       ; exit out bottom

Set2:
        movb *r9,r3      ; read char after space
        bl @isalpha      ; must be an alpha to start
        jeq Set3         ; if an aplph keep goin 
        li r1,4          ; bad label
        mov r1,@ErrNum   ; set error num
	jmp setend

Set3:      
	;;;li r1,VARNAME
	;;;push r1	
	pushss r1        ; get an address on string stack
	push r1          ; save it on stack for get label to use
	bl @getlabel     ; go get the variable name
	movb *r9+,r3     ; read char after variable name
	ci r3,Equals     ; is it an =
	jeq Set4         ; if yes then simple variable
	ci r3,OpenParen  ; then array 
	jeq SetArray     ; goto setarray
	popss r1         ; take the varname off string stack
        li r1,7          ; error expecting =
        mov r1,@ErrNum   ; set error num
	jmp setend
	
Set4:
	
	bl @getmstr      ; get mumps string - value of variable
        mov @ErrNum,r1   ; get error var
        ci r1,0          ; see if any errors
        jne serror       ; yes found error - do not print anything

SetSave:
	popss r2          ; address of data
	;; since more access to string stack from here it'll 
        ;; be ok to acess from here
        ;; until any more pushss occure
	popss r1         ; pop varname from string stack
	push r1          ; push address of varname to stack for addvar	
	push r2          ; push data to be assigned to varname
	bl @addvar       ; call routine to store varible in btrees 
	jmp setend
serror: 
	popss r1        ; take varname off string stack

setend:	pop r11
	b *r11


SetArray:  ; 

	bl @getmstr       ; get value of index
	movb *r9+,r3      ; get char after index
	ci r3,CloseParen  ; check if close paren 
	jne setarrerr1	  ; missing )
	movb *r9+,r3      ; get next char and advance
	ci r3,Equals      ; check for =
	jne setarrerr2    ; if not = then error
	bl @getmstr       ; get value
	
	                  ; pop addresses off string stack
	                  ; data is good until another push
	popss r5          ; value
	popss r3          ; index / subscript
	popss r7          ; varname

	mov @HEAD,r6     ; get head of symbol table tree
	push r5          ; save ptr to value
	bl @TreeFindVar  ; pass varname in r7, r6 head of tree, rtn in R6
	ci r6,0          ; if var not definded create and give value ""
	jne setarr2      ; var exists
	li r2,NULLstr    ; make value null
	push r7          ; push address of varname to stack for addvar	
	push r2          ; push data to be assigned to varname
	bl @addvar       ; call routine to store varible in btrees 

setarr2:   ; r6 needs to hold parent simple var ( from find or add) 
	mov r3,r4        ; subscript is var name
	pop r5           ; value to be stored
	push r6          ; address to parent
	
setarrnew:

	bl @newnode      ; data already in r5 address of new node in r6
	pop r1           ; parent address
	bl @insertsubnode


	; then add subindex
	jmp setend

setarrerr1: ; missing )
	li r1,17        ; error missing )
	mov r1,@ErrNum
	jmp setarrpops



setarrerr2:  ; missing =
	li r1,18
	mov r1,@ErrNum
	jmp setarrpops


setarrpops:
	popss r1        ; pop array index
	popss r1        ; pop array name
	jmp setend
