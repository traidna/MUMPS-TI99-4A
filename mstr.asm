	;  mstr.asm
	; routines for parsing out string values from 
	; mumps code, variables etc
	; 

getmstr ;
	;mov r11,*r10+
	push r11

	;getleftval:   ; get left side of expression

	bl @getvalue   ; left side
        
gmops	clr r3
	movb *r9,r3

getop	ci r3,SPACE ; if space done
	jeq exitgm
	ci r3,NULL  ; if null done
	jeq exitgm

			
gmplus	
	ci r3,PLUS   ; is +
	jeq gmright
	ci r3,Minus
	jeq gmright
	ci r3,Asteric
	jeq gmright
	ci r3,Slash
	jeq gmright
	ci r3,Hashtag
	jeq gmright
	ci r3,Equals
	jeq gmright
	ci r3,Greater
	jeq gmright
	ci r3,LessThan
	jeq gmright
	ci r3,RightBracket
	jeq gmright
	ci r3,Underscore
	jeq gmright

	
	; error ...
	jmp exitgm

gmright:   ; get right side of expression

	pushss r2      ; push operator on ss stack 
	movb r3,*r2+   ; 
	clr r3
	movb r3,*r2 

	inc r9
	movb *r9,r3

gmrt2	push r3
	bl @getvalue   ; get right hand value and put on ss stack
	pop r3

	;ci r3,Equals
	;jeq gmstrmath
	;ci r3,RightBracket
	;jeq gmstrmath
	
domath	bl @math         ; numeric operators

	jmp gmops
 
	;gmstrmath:
	;bl @StringMath   ; string operators
	;jmp gmops	



	;;; get the value of this m string
getvalue:
	push r11
	clr r3        
	movb *r9+,r3 ; get char after space and advance
	ci r3,OpenParen
	jne getvcp
	bl @getmstr
	; return here
getvcp: ci r3,CloseParen
	jne getv2
	inc r9
	pop r11
	b *r11

getv2	ci r3,2200h  ; check "
	jeq litstr   ; go read literal string
	ci r3,Dol    ; check for $
	jeq dolstr   ; it's a $ function or variable 
	bl @isdigit  ; checks r3 for digit, returns EQ if digit, NE otherwise
	jeq digstr   ; go get digits
	ci r3,Minus  ; unary -
	jeq getuni   ; jmp to uni
	ci r3,Plus   ; if not - is it a +
	jeq getuni   ; if yes jump to uni
	jmp getval2  ; other wise cary on 

getuni:
	b @unaryop    ; negative number

getval2
	bl @isalpha  ; is it an alpah 
	jeq varstr   ; go get value of a variable	 
	li r1,2      ; invalid mstring
	mov r1,@ErrNum

exitgetmstr:
exitgm:
	pop r11
	b *r11
	

digstr:  ;  read digits a number string 
  	 ; need to add allowing '.' 
	pushss r2       ; get address of spot on string stack

	clr r5          ; clear until a decimal point	
digstr1:
	movb r3,*r2+    ; store digit ( or minus)
	movb *r9,r3     ; get next char
	ci r3,Period    ; is it a decimal point ( only one though...)
	jne digit1      ; nope not . skip over
	inc r5          ; inc number of decimal points
	ci r5,1         ; is it first one
	jeq digit2      ; yes jump down and continue
	li r5,3         ; error 
	mov r5,@ErrNum  ; 
	jmp exitgetmstr ; error so exit out
digit1	bl @isdigit     ; is it a digit
	jne termstr     ; if not then done
digit2	inc r9
	jmp digstr1     ; yes then loop back up to store it


litstr  ; parse literal string
	pushss r2
	clr r3
ls1	movb *r9+,r3
	ci r3,2200h   ; check for "
	jeq termstr
	movb r3,*r2+
	jmp ls1 

termstr
	clr r3
	movb r3,*r2   ; terminate the string
	jmp exitgetmstr	


varstr:	; get value of variable
	; 
	
	dec r9           ; prep for get label
	li r1,VARNAME    ; point to scrath mem to store varname
	push r1          ; address to store varname
	bl @getlabel     ; go read varname from code
	li r7,VARNAME    ; set r7 to address of varname for find
	mov @HEAD,r6     ; set to head of tree to search 
	bl @TreeFindVar  ; r6 holds address if found, 0h otherwise
	ci r6,0          ; if 0 not found 
	jeq varstrerr    ; log error
	movb *r9,r3      ; is it a simple var or array
	ci r3,Openparen  ;
	jne varsimple
varsarr:
	push r6 
	inc r9
	bl @getmstr      ; get value of what is in parens
	popss r7
	pop r6
	mov @8(r6),r6
	bl @TreeFindVar	
	ci r6,0
	jeq varstrerr   
	inc r9           ; past close paren	
	
	;jmp varstrexit
varsimple:
	mov @14(r6),r6   ; get poiter to data   
	pushss r7        ; get address to store data on str stack
	bl @strcopy	 ; copy to address in string stack
	jmp varstrexit   ; all done

varstrerr:
	li r1,25
	mov r1,@ErrNum
varstrexit:	
	jmp exitgetmstr
	

dolstr:  ; $ function or variable 
	clr r3
	movb *r9+,r3      ; get letter after $
	swpb r3
	bl @toupper
	swpb r3
	bl @isalpha      ; check if alpha
	jne dolerr       ;  
	swpb r3
 	ai r3,-65        ; find offset from A
        a r3,r3          ; double it as addresses are two bytes
        li r4,doltbl     ; load address of jump table
        a r3,r4          ; add to offset
        mov *r4,r3       ; get jump address from address in jump table
        ci r3,0          ; is the address from the table 0
        jne dolstr2       ; if not keep jump down to dolstr2
	jmp dolerr       ; bad $function
dolstr2:   
	bl *r3           ; jump to mumps command routine
	
	jmp varstrexit	


dolerr: 
	clr r11
	li r11,13     ; bad $function
	mov r11,@Errnum
	b @exitgetmstr	

getlabel:  ; get label name from code ( maybe combine with getvarname)
           ; address to put label pushed to stack
	   ; assumes *r9 is an alpha so caller should check

	pop r1   ; get address to put label 
	push r11 ; push return address
	movb NULL,*r1  ; initial to NULL incase no label here
	
getlab2:
	clr r3            ; clear char
	movb *r9,r3       ; get char and advance code pointer
	ci r3,0h          ; if null done
	jeq getlabterm    ; terminate the string
	ci r3,SPACE       ; if space done
	jeq getlabterm    ; terminiate the string
	ci r3,OpenParen   ; if ( done
	jeq getlabterm    ; terminiate the string
	ci r3,CloseParen  ; if ) done
	jeq getlabterm    ; terminiate the string

	ci r3,Equals    ; if = done
	jeq getlabterm  ; terminiate the string

	ci r3,Greater   ; if > done
	jeq getlabterm  ; terminiate the string
	ci r3,LessThan  ; if < done
	jeq getlabterm  ; terminiate the string


	ci r3,RightBracket    ; if ] done follows operator
	jeq getlabterm        ; terminate the string
	ci r3,Underscore      ; concat
	jeq getlabterm        ; terminate the string

	ci r3,Comma     ; if , then done
	jeq getlabterm  ; terminate the string
	;ci r3,CloseParen ; if , then done
	;jeq getlabterm  ; terminate the string
	ci r3,Plus     
	jeq getlabterm  ; terminate the string
	ci r3,Minus     
	jeq getlabterm  ; terminate the string
	ci r3,Asteric     
	jeq getlabterm  ; terminate the string
	ci r3,Slash     
	jeq getlabterm  ; terminate the string
	ci r3,Hashtag     
	jeq getlabterm  ; terminate the string
	ci r3,Colon
	jeq getlabterm  ; terminate the string

	bl @isalpha     ; must be an alpha or num
	jne getlabdigit ; not alpha might be digit
	movb *r9+,*r1+  ; write to LABEL string
	jmp getlab2

getlabdigit:
	bl @isdigit     ; 
	jne getlaberr   ; not alpha or digit ( need is alphnum?
	movb *r9+,*r1+  ; write to LABEL string
	jmp getlab2


getlabterm:
	clr r3
	movb r3,*r1

getlabdone:
	pop r11    ; pop return address
	b *r11     ; return to caller


getlaberr:
	li r11,4   ; bad label
	mov r11,@ErrNum
	jmp getlabterm
