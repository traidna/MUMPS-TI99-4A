;; 16 bit Pad Ram
WKSPACE    equ 08300h   ; MUMPS workspace r9 - code ptr, r10 stack ptr
CursorPos  equ 08320h   ; current screen location
HaltFlag   equ 08322h   ; halt flag set when halt or error
ErrNum     equ 08324h   ; Error number set when an error
CodeTop    equ 08326h   ; next available address for code (bytes)
MSP        equ 08328h   ; mumps math stack pointer (strings 32 bytes ea)
LastKeyin  equ 0832Ah   ; used for getkey - dup keys

;VIptr      equ 0832Ch   ; pointer to next available local var index node
;VDptr      equ 0832Eh   ; pointer to next available local var data node

VIptr      equ 2FFAh   ; pointer to next available local var index node
VDptr      equ 2FFCh   ; pointer to next available local var data node


STRSP      equ 08330h   ; pointer to top of string stack
QuitFlag   equ 08332h   ; True when Quit and return stack empty
Head       equ 08334h   ; head of the symbol table b-tree
DolT       equ 08336h   ; MUMPS system variable $T used for if, else, read
Dolio      equ 08338h   ; word house $io in lsb, msb =00, console is 0000h
tmpio      equ 0833Ah   ; temp io for open, use, close
openio     equ 0833Ch   ; open file dev number
fioerr     equ 0833Eh   ; value from paberr in vdp ram set in fileio
ScreenWidth equ 8340h   ; width of screen 
;LastSet    equ 08342h   ; address of data node from last set (used in for loops)
LastSet    equ 2FFEh     ; address of a data node from last set
Forflg     equ 08344h   ; Byte forloop flag 0 not in for number depth of fors
PrtMode    equ 08346h   ; Inverse (9600h) or Regular (0) print
MemMapper  equ 08348h   ; for mem mapper indicator 0-off 1-on
DoFlg      equ 0834Ah   ; Byte do flag used when in for loop
Bank2Map   equ 0834Ch   ; Byte 2000h Bank 2  -> Page mapped   SAMS CARD
Bank3Map   equ 0834Dh   ; Byte 3000h Bank 3  -> Page mapped   SAMS CARD
Bank10Map  equ 0834Eh   ; Byte A000h Bank 10 -> Page mapped   SAMS CARD
Bank11Map  equ 0834Fh   ; Byte B000h Bank 11 -> Page mapped   SAMS CARD
Bank12Map  equ 08350h   ; Byte C000h Bank 12 -> Page mapped   SAMS CARD
Bank13Map  equ 08351h   ; Byte D000h Bank 13 -> Page mapped   SAMS CARD
Bank14Map  equ 08352h   ; Byte E000h Bank 14 -> Page mapped   SAMS CARD
Bank15Map  equ 08353h   ; Byte F000h Bank 15 -> Page mapped   SAMS CARD

SWBANK     equ 08390h   ; 8 bytes for bank switching code 8390 - 8397

SpchReadit equ 083A0h   ; bytes for Speach read code 
SPDATA     equ 083AEh   ; 

INV        equ 06000h   ; 96 decimal offset from regular char to inverse
NOTINV     equ 0h

keyin      equ 08375h   ; ROM - kscan address for ascii code

ALTSPACE   equ 083C0h   ; Available alternate workspace
wspMonitor equ 083E0h   ; Address for our monitor Vars

	   ; cartridge Banks addresses
BANK0      equ 06000h   ; address to write to for bank 0
BANK1      equ 06002h   ; address to write to for bank 1
BANK2      equ 06004h   ; address to write to for bank 2

           ; Lower Ram in expansion
VARINDEX   equ 02000h   ; 6k space for varible index records
TIB        equ 03800h   ; text input buffer - 128 bytes
CmdLine    equ 03880h   ; code typed in     - 128 bytes
MSTACK     equ 03900h   ; return stack      - 256 bytes
VARNAME    equ 03A00h   ; varibale for varnames - 16 bytes tree, etc
LABEL      equ 03A10h   ; label names (do, zl etc)16 bytes

         ; for dsrlnk calls
sav8a      equ 03A20h       ;
savcru     equ 03A22h       ; cru address of the peripheral
savent     equ 03A24h       ; entry address of dsr or subprogram
savlen     equ 03A26h       ; device or subprogram name length
savpab     equ 03A28h       ; pointer to device or subprogram in the pab
savver     equ 03A2Ah       ; version # of dsr
flgptr     equ 03A2Ch       ; pointer to flag in pab (byte 1 in pab)
dsrlws     equ 03A2Eh       ; data 0,0,0,0,0    ; dsrlnk workspace
dstype     equ 03A38h       ; data 0,0,0,0,0,0,0,0,0,0,0
haa        equ 03A4Eh       ; used to store AA pattern for DSR ROM detection
namsto     equ 03A50h       ; 0,0,0,0 ( 8 bytes)

            ; Scratch PAB in ram template  for diskio
pabopc      equ 03A60h         ; PAB RAM - start of ram PAB for diskio
pabflg      equ 03A61h         ; filetype / error code
pabbuf      equ 03A62h         ; word, address of pab buffer (1000)
pablrl      equ 03A64h         ; logical rec length (write, read)
pabcc       equ 03A65h         ; output char count
pabrec      equ 03A66h         ; record number
pabsco      equ 03A68h         ; usual 0, screen offset
pabnln      equ 03A69h         ; length of file name DSK1.FILE1 = 10 0AH
pabfil      equ 03A6Ah         ; text of filename ( leave 32 bytes ?)

		;; VDP memory addresses
BUFADR      equ 01000h         ; address in VDP mem for read/write buffer
PABADR      equ 00F80h         ; address of where pab will go
PABERR      equ 00f81h         ; address of where errors are noted in pab

		;; lower memory scratch and Stack memory 
SCRATCH    equ 03B00h   ; FREE MEMORY 3B00-3BFF FOR NOW
SAMSTRAMP  equ 03BAFh   ; Samps trampoline code 80 bytes to swap pages
STACK      equ 03C00h   ; Stack t0 3FFF - total of 1024 bytes 512 words

           ; Upper Ram in expansion
CODESTART  equ 0A000h   ; location of MUMPS code to interpret
VARDATA    equ 0C800h   ; start of Variable data area c800-F7FF
STRSTACK   equ 0F800h   ; MUMPS String stack for math, operators etc 2k

	   ; for editor note could overrite end of MUMPS symbol table
ScrBuf	   equ 0FC00h   ; 1024 from end of RAM used to mirror 0-1024 VDP

           ; equates for word length Charaters values
Quote        equ '"'
Space        equ 02000h   ; word value of space
QuoteW       equ 02200h   ; word value of "
Hashtag      equ 02300h   ; word value of #
Exclampt     equ 02100h   ; word value of !
Dol          equ 02400h   ; word value of $
Amp          equ 02600h   ; word value of &
OpenParen    equ 02800h   ; word value of (
CloseParen   equ 02900h   ; word valude of )
Asteric      equ 02A00h   ; word value of *
Plus         equ 02B00h   ; word value of +
Comma        equ 02C00h   ; word value of ,
Minus        equ 02D00h   ; word value of -
Zero         equ 03000h   ; word value of '0'
Period       equ 02E00h   ; word value of .
Slash        equ 02F00h   ; word value of /
Colon        equ 03A00h   ; word value of :
Semicol      equ 03B00h   ; word value of ;
LessThan     equ 03C00h   ; word value of <
Equals       equ 03D00h   ; word value of =
Greater      equ 03E00h   ; word value of >
RightBracket equ 05D00h   ; word value of ]
Carat        equ 05E00h   ; word value of ^
Underscore   equ 05F00h   ; word value of _
Cursor       equ 01E00h   ; word value of - defined below
MTRUE        equ 03100h   ; word value of true '1'
MFALSE       equ 03000h   ; word value of false '0'
ConsIO       equ 03000h   ; word value of '0' for console io
AKey         equ 04100h   ; word value of 'A'
MKey         equ 04D00h   ; word value of "M"
NKey         equ 04E00h   ; word value of 'N'
PKey         equ 05000h   ; Word value fo 'P'
QKey         equ 05100h   ; word value of 'Q'
ReadMode     equ 05200h   ; word value of 'R' - file read mode in open
WriteMode    equ 05700h   ; word value of 'W' - file write mode in open
Quoteword    equ 02200h   ; word value of "
NULL         equ 00000h   ; NULL end of string marker
TILDA        equ 07E00h   ; word value of ~
EOF          equ 0FF00h   ; 255 byte or FFFFh work end of file marker
CtrlX        equ 152      ; 

Spchwt		 equ 09400h   ; speech write port
Spchrd       equ 09000h   ; speech read port


	; bank0 entry points
b0treeprint_a	equ 0601Eh    ; treeprint in tree.asm
b0getmstr_a     equ 06026h    ; getmstr   in mstr.asm
b0clrVDPbuf_a   equ 0602Eh    ; clrVDPbuf in vdpfio.asm
b0WriteFile_a   equ 06036h    ; WriteFile in w.asm
b0getlabel_a    equ 06040h    ; getlabel  in mstr.asm
b0findlabel_a   equ 06058h    ; findlabel in d.asm
b0hstrtonum_a   equ 06088h    ; hstrtonum in math.asm

	; bank1 entry points  
b1getstr_a   	equ 0602Eh   ; getstr     in b1kscan.asm
b1getkey_a   	equ 06046h   ; getkey     in b1kscan.asm
b1ramdump_a  	equ 0604Eh   ; b1ramdump  in b1ramutils.asm
b1ShowHex4_a 	equ 06056h   ; b1ShowHex4 in b1mon.asm
b1fileio_a		equ 0605Eh   ; b1fileio   in iolib.asm
b1clrampab_a    equ 06066h   ; b1clrampab in iolib.asm
b1zwrite_a      equ 0606Eh   ; b1zwrite   in b1z.asm
b1zremove_a     equ 06076h   ; b1zremove  in b1z.asm
b1zload1_a      equ 0607Eh   ; b1zload1   in b1z.asm 
b1zsave_a       equ 06086h   ; b1zsave    in b1z.asm
b1eofmark_a     equ 0603Eh   ; EOFMark    in am0.asm
b1zlist_a       equ 0608Eh   ; zlist      in b1z.asm
b1zinsert_a     equ 06096h   ; zinsert    in b1z.asm
b1zm2_a         equ 0609Eh   ; zm2 (mon)  in b1z.asm
b1ze_a          equ 060A6h   ; ze         in b1ze.asm
b1minit_a       equ 060AEh   ; mumpinit   in am1.asm
b1Sound_a	    equ 060B6h   ; Sound      in soundlib.asm
b1Speech_a      equ 060BEh   ; Speech     in soundlib.asm
b1Speech2_a     equ 060C6h   ; speech from bank2 in soundlib.asm
b1ShowHex42_a 	equ 060CEh   ; b1ShowHex4 in b1mon.asm
b1Text40_a      equ 060D6h   ; Text40      in utils.asm
b1Graph32_a     equ 060DEh   ; Graph32     in utils.asm

	; bank2 entry points
b2prterrmsg_a    equ 06028h   ; PrtErrMsg  in am2.asm
