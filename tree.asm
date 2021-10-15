	; tree.asm  - binary tree routines for MUMPS local variables


addvar:  ;  pass varname pointer, data pointer on stack
	 ;  pass data pionter in r5

	; Pull parameters off stack

	pop r5     ; pointer to string of data
	pop r4     ; pointer to variable name
	push r11   ; push return address to the stack

	mov @Head,r6       ; head of tree
	mov r4,r7          ; copy ptr to varname string
	push r5
	bl @TreeFindVar    ; is it in symbol table
	pop r5
	ci r6,0h           ; if not add new
	jeq addvarnew      ; add new
	mov @14(r6),r7          ; mov address of data node to r7 
	mov r5,r6          ; move string data to r6
	bl @strcopy        ; copy new string data to data node
	jmp advarend

addvarnew:
	bl @newnode
	bl @insertnode
	; push return value?? 
	
advarend:
	pop r11
	b *r11        ; return 



newnode:   ; pass address of string of var name in r4
	   ; pass address of data string in r5
	   ; return address of new index node in r6
    
	push r11

	mov @VIptr,r7 ;  get address of next open address for index node 
	mov r7,r2     ;  copy as strcopy uses r7
	mov r4,r6     ;  get varname address in f6 for strcopy
	bl @strcopy   ;  copy varname to index record
	
	mov @VDptr,r8 ; set op to copy data to memory		
	mov r2,r1     ; hold address
	ai r2,8       ; advance to address links
	clr r0        ; set r0 to 0000h
	mov r0,*r2+   ; nulls in link to subscript
	mov r0,*r2+   ; nulls in left link
	mov r0,*r2+   ; nulss in right link
	mov r8,*r2    ; save address of where data will be stored

	mov r8,r7     ; target destination in data area
	mov r5,r6     ; data pointer
	bl @strcopy

	mov @VIptr,r7 ; get address of next open address for index node 
	mov r7,r6     ; store for use in insertion, returned
	ai r7,16      ; move to next index entry
	mov r7,@VIptr ; store in pointer

	ai r8,32      ; move pointer to next position
	mov r8,@VDptr ; update code pointer 

	pop r11
	b *r11         ; return to caller


insertnode:  ; insert a new node or update existing nodes data
             ; pass in r6 the address of new or updated node
	push r11

	mov @Head,r8
	ci r8,0
	jeq firstnode
	mov @Head,r7
	bl @treeinsert
	jmp insexit

firstnode:
	mov r6,@Head
insexit:
	pop r11
	b *r11


treeinsert:    ; address of new index node is in r6, current node r7
	push r11
	; r6 points to newly added varname
	ci r7,NULL 
	push r6
	push r7
	bl @strcmp        ; result in r5
	pop r7
	pop r6
	ci r5,1
	jeq goright

goleft:
	mov @10(r7),r2
	ci r2,0000h
	jeq insertlf     ; insert as left child
	mov r2,r7        ; 
	bl @treeinsert   ; call again
	jmp treeinsexit  ; done return
goright:
	mov @12(r7),r2   ; check right child pointer
	ci r2,0000h      ; if null then insert 
	jeq insertrt	 ; else call back with this is new r7
	mov r2,r7        ; move right child ptr to r7
	bl @treeinsert   ; call insert
	jmp treeinsexit

insertrt:
	mov r6,@12(r7)
	jmp treeinsexit

insertlf
	mov r6,@10(r7)

treeinsexit:
	pop r11
	b *r11



treeprint:  ;  pass in root in r6 
	push r11
	ci r6,0h           ; if null then return
	jeq treeprintexit  ; return
	mov @10(r6),r5     ; not null get left ptr
	push r6            ; push this node to stack
	mov r5,r6          ; move left child to current node
	bl @treeprint      ; call treeprint again
	pop r6             ; returned from going left get parent node
	mov r6,r1          ; move r1 for printing
	bl @PrintString    ; print variable name
	bl @CR             ; print new line
	mov @12(r6),r5     ; get right child ptr 
	mov r5,r6          ; copy to r6
	bl @treeprint      ; recursive call with right child  
treeprintexit:
	pop r11            ; get address of caller
	b *r11             ; and return



TreeFindVar:    ; r6 - head (current node) return value
	        ; r7 - ptr to varname
		; r6 - return value with addr of index node 
		; uses r5,r6,r7

   	push r11
tfv:    
	clr r5
	ci r6,0h           ; if null then return
        jeq treefvexit     ; return
	push r6            ; save r6
	push r7            ; save r7
	bl @strcmp         ; see if strings at r6,r7 are equal
	pop r7             ; restore r6
	pop r6             ; restore r7
	ci r5,0            ; r5=0 if equal
	jeq treefvfound     ; equl so exit r6 has address of index pointer
	ci r5,-1            ; r6 < r7
	jeq fvright

fvleft  mov @10(r6),r5     ; get left ptr
        mov r5,r6          ; move left child to current node
	jmp tfv 

fvright mov @12(r6),r5     ; get right child ptr
        mov r5,r6          ; copy to r6
	jmp tfv

treefvfound:
treefvexit:
        pop r11            ; get address of caller
        b *r11             ; and return


