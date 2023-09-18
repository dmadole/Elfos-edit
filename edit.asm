; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************
.op "PUSH","R","9$1 73 8$1 73"
.op "POP","R","60 72 A$1 F0 B$1"
.op "MOV","NR","9$2 B$1 8$2 A$1"
.op "MOV","NW","F8 H2 B$1 F8 L2 A$1"
.op "CALL","W","D4 H1 L1"
.op "RTN","","D5"

#include   include/bios.inc
#include   include/kernel.inc

           org     2000h-6
           dw      2000h
           dw      end-2000h
           dw      2000h

; RA - text buffer pointer
; R8 - Reg1 (line number)
; R9 - Reg2 (count)

           org     2000h
           br      start

           db      1+80h
           db      19
           db      2023
           dw      100
           db      'By Michael H. Riley, github.com/dmadole/Elfos-edit',0

docrlf:    ldi     high crlf           ; display a crlf
           phi     rf
           ldi     low crlf
           plo     rf
           sep     scall
           dw      o_msg
           sep     sret

; *** Check if character is numeric
; *** D - char to check
; *** Returns DF=1 if numeric
; ***         DF=0 if not
isnum:     sex     r2                  ; be sure x points to stack
           stxd                        ; save number
           smi     '0'                 ; check for bottom of numbers
           bnf     isnotnum            ; jump if not a number
           smi     10                  ; check high end
           bdf     isnotnum            ; jump if not a number
           ldi     1                   ; numer is numeric
           lskp
isnotnum:  ldi     0                   ; signal not a number
           shr                         ; shift result into DF
           irx                         ; recover original value
           ldx
           sep     sret                ; and return to caller

; *** Check if character is uppercase alpha
; *** D - char to check
; *** Returns DF=1 if numeric
; ***         DF=0 if not
isuc:      sex     r2                  ; be sure x points to stack
           stxd                        ; save number
           smi     'A'                 ; check for bottom of numbers
           bnf     isnotuc             ; jump if not a number
           smi     27                  ; check high end
           bdf     isnotuc             ; jump if not a number
           ldi     1                   ; numer is numeric
           lskp
isnotuc:   ldi     0                   ; signal not a number
           shr                         ; shift result into DF
           irx                         ; recover original value
           ldx
           sep     sret                ; and return to caller

; *** Check if character is lowercase alpha
; *** D - char to check
; *** Returns DF=1 if numeric
; ***         DF=0 if not
islc:      sex     r2                  ; be sure x points to stack
           stxd                        ; save number
           smi     'a'                 ; check for bottom of numbers
           bnf     isnotlc             ; jump if not a number
           smi     27                  ; check high end
           bdf     isnotlc             ; jump if not a number
           ldi     1                   ; numer is numeric
           lskp
isnotlc:   ldi     0                   ; signal not a number
           shr                         ; shift result into DF
           irx                         ; recover original value
           ldx
           sep     sret                ; and return to caller


; *** rf - pointer to ascii string
; *** returns: rf - first non-numeric character
; ***          RD - number
; ***          DF = 1 if first character non-numeric
atoi:      ldi     0                   ; clear answer
           phi     rd
           plo     rd
           ldn     rf                  ; get first value
           sep     scall               ; check if numeric
           dw      isnum
           bdf     atoicnt             ; jump if so
           xri     '-'                 ; check for minus
           bz      atoicnt             ; jump if so
           ldi     1                   ; signal number error
           shr
           sep     sret                ; return to caller
atoicnt:   sex     r2                  ; make sure x points to stack
           glo     rc                  ; save consumed registers
           stxd
           ghi     rc
           stxd
           glo     re
           stxd
           plo     re                  ; signify positive number
           ldn     rf                  ; get first bytr
           xri     '-'                 ; check for negative
           bnz     atoilp              ; jump if not negative
           ldi     1                   ; signify negative number
           plo     re
           inc     rf                  ; move past - sign
atoilp:    ldn     rf                  ; get byte from input
           smi     '0'                 ; convert to binary
           bnf     atoidn              ; jump if below numbers
           smi     10                  ; check for above numbers
           bdf     atoidn              ; jump if above numbers
           glo     rd                  ; multiply by 2
           plo     rc                  ; keep a copy
           shl
           plo     rd
           ghi     rd
           phi     rc
           shlc
           phi     rd
           glo     rd                  ; multiply by 4
           shl
           plo     rd
           ghi     rd
           shlc
           phi     rd
           glo     rc                  ; multiply by 5
           str     r2
           glo     rd
           add
           plo     rd
           ghi     rc
           str     r2
           ghi     rd
           add
           phi     rd
           glo     rd                  ; multiply by 10
           shl
           plo     rd
           ghi     rd
           shlc
           phi     rd
           lda     rf                  ; get byte from buffer
           smi     '0'                 ; convert to binary
           str     r2                  ; prepare for addition
           glo     rd                  ; add in new digit
           add
           plo     rd
           ghi     rd
           adci    0
           phi     rd
           br      atoilp              ; loop back for next character
atoidn:    nop
           irx                         ; recover consumed registers
           ldxa
           plo     re
           ldxa
           phi     rc
           ldx
           plo     rc
           ldi     0                   ; signal valid number
           shr
           sep     sret                ; return to caller

start:
           lda     ra                  ; move past any spaces
           smi     ' '
           lbz     start
           dec     ra                  ; move back to non-space character
           ldi     high textbuf        ; point to text buffer
           phi     rf
           ldi     low textbuf
           plo     rf
           ldi     0                   ; need terminator
           str     rf
           ldi     high fname          ; point to filename storage
           phi     rf
           ldi     low fname
           plo     rf
fnamelp:   lda     ra                  ; get byte from filename
           str     rf                  ; store int buffer
           inc     rf
           smi     33                  ; look for space or less
           lbdf    fnamelp             ; loop back until done
           dec     rf                  ; point back to termination byte
           ldi     0                   ; and write terminator
           str     rf
           ldi     high fname          ; point to filename storage
           phi     rf
           ldi     low fname
           plo     rf
           ldn     rf                  ; get byte from argument
           lbnz    good                ; jump if filename given
           sep     scall               ; otherwise display usage message
           dw      o_inmsg
           db      'Usage: edit filename',10,13,0
           sep     sret                ; and return to os
good:      ldi     high fildesdta      ; point to file descriptor dta
           phi     rd
           ldi     low fildesdta
           plo     rd
           ldi     high dta            ; get dta address
           str     rd
           inc     rd
           ldi     low dta
           str     rd
           ldi     high fildes         ; point to file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           ldi     0                   ; flags
           plo     r7
           sep     scall               ; attempt to open the file
           dw      o_open
           lbdf    newfile             ; jump if file does not exist
           ldi     high textbuf        ; point to text buffer
           phi     rf
           ldi     low textbuf
           plo     rf
loadlp:    glo     rf                  ; save buffer address
           stxd
           ghi     rf
           stxd
           inc     rf                  ; point to position after length
           sep     scall               ; read next line
           dw      readln
           lbdf    loadeof             ; jump if eof was found
           glo     rc                  ; get count
           lbnz    loadnz              ; jump if bytes were read
           irx                         ; recover buffer
           ldxa
           phi     rf
           ldx
           plo     rf
           lbr     loadlp              ; loop back and read another line
loadnz:    ldi     13                  ; write cr/lf to buffer
           str     rf
           inc     rf
           ldi     10
           str     rf
           inc     rc                  ; add 2 characters
           inc     rc
           irx                         ; recover buffer address
           ldxa
           phi     rf
           ldx
           plo     rf
           glo     rc                  ; get count
           str     rf                  ; and write to buffer
           inc     rf                  ; move buffer to next line position
           str     r2
           glo     rf
           add
           plo     rf
           ghi     rf
           adci    0
           phi     rf
           lbr     loadlp              ; jump to load next line
loadeof:   irx                         ; recover buffer address
           ldxa
           phi     rf
           ldx
           plo     rf
           glo     rc                  ; see if bytes were read
           lbz     loaddn              ; jump if not
           ldi     13                  ; write cr/lf to buffer
           str     rf
           inc     rf
           ldi     10
           str     rf
           inc     rc                  ; add 2 characters
           inc     rc
           glo     rc                  ; get count
           str     r2
           glo     rf
           add
           plo     rf
           ghi     rf
           adci    0
           phi     rf
loaddn:    ldi     0                   ; write termination
           str     rf
           sep     scall               ; close the file
           dw      o_close

mainlp:    sep     scall               ; get current line number
           dw      getcurln
           inc     r8
           sep     scall               ; show current line
           dw      printnum
           ldi     high prompt         ; display the prompt
           phi     rf
           ldi     low prompt
           plo     rf
           sep     scall
           dw      o_msg
           ldi     high buffer         ; get input from user
           phi     rf
           ldi     low buffer
           plo     rf
           sep     scall
           dw      o_input
           sep     scall               ; do a cr/lf
           dw      docrlf
           ldi     0                   ; clear registers
           phi     r8
           plo     r8 
           phi     r9
           plo     r9
           inc     r9                  ; set count to 1
           sep     scall               ; set R8 to current line number
           dw      getcurln
           ldi     high buffer         ; point back to buffer
           phi     rf
           ldi     low buffer
           plo     rf
           sep     scall               ; try to get a number
           dw      atoi
           lbdf    arg1non             ; jump if not numeric
           ghi     rd                  ; transfer to reg1
           phi     r8
           glo     rd
           plo     r8
           dec     r8                  ; origin to zero
arg1non:   ldn     rf                  ; get character in buffer
           xri     ','                 ; look for a comma
           lbnz    noarg2              ; jump if no second arg
           inc     rf                  ; point to next character
           sep     scall               ; and convert argument
           dw      atoi
           lbdf    noarg2              ; jump if no number supplied
           ghi     rd                  ; transfer argument to reg 2
           phi     r9
           glo     rd
           plo     r9
noarg2:    ldn     rf                  ; get command
           sep     scall               ; check if lc
           dw      islc
           lbnf    noarg2_1            ; jump if not
           ldn     rf                  ; convert to uppercase
           smi     32
           str     rf
noarg2_1:  ldn     rf                  ; get command
           smi     'D'                 ; check for down command
           lbz     down
           ldn     rf                  ; get command
           smi     'U'                 ; check for up command
           lbz     up
           ldn     rf                  ; get command
           smi     'P'                 ; check for print command
           lbz     print
           ldn     rf                  ; get command
           smi     'I'                 ; check for insert command
           lbz     insert
           ldn     rf                  ; get command
           smi     'T'                 ; check for top command
           lbz     top
           ldn     rf                  ; get command
           smi     'B'                 ; check for bottom command
           lbz     bottom
           ldn     rf                  ; get command
           smi     'Q'                 ; check for quit command
           lbz     quit
           ldn     rf                  ; get command
           smi     'K'                 ; check for kill command
           lbz     kill
           ldn     rf                  ; get command
           smi     'S'                 ; check for save command
           lbz     save
           ldn     rf                  ; get command
           smi     'G'                 ; check for go command
           lbz     go
           ldn	   rf
	   smi     'E'
	   lbz     ledit

           ldi     high errmsg         ; display error
           phi     rf
           ldi     low errmsg
           plo     rf
           sep     scall               ; display message
           dw      o_msg
           lbr     mainlp
  
; ****************************
; *** Go to specified line ***
; *** R8 - line to go to   ***
; ****************************
go:        sep     scall               ; set line number
           dw      setcurln
           sep     scall               ; find line 
           dw      findline
           lbnf    gocont              ; jump if a valid line
           sep     scall               ; find end of buffer
           dw      findend
           sep     scall               ; set as current line
           dw      setcurln
gocont:    sep     scall               ; print the line
           dw      printit
           lbr     mainlp              ; return to main loop

; ***************************
; *** Save buffer to disk ***
; ***************************
save:      ldi     high fname          ; point to filename
           phi     rf
           ldi     low fname
           plo     rf
           ldi     high fildes         ; point to file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           ldi     3                   ; flags for open, create, truncate
           plo     r7
           sep     scall               ; open the file
           dw      o_open
           ldi     high textbuf        ; point to text buffer
           phi     rf
           ldi     low textbuf
           plo     rf
savelp:    ldn     rf                  ; get length byte
           lbz     savedn              ; jump if done
           glo     rf                  ; save buffer position
           stxd
           ghi     rf
           stxd
           lda     rf                  ; get length byte
           plo     rc
           ldi     0                   ; clear high byte of count
           phi     rc
           sep     scall               ; write the line
           dw      o_write
           irx                         ; recover buffer
           ldxa
           phi     rf
           ldx
           plo     rf
           lda     rf                  ; get length byte
           str     r2                  ; and add to position
           glo     rf
           add
           plo     rf
           ghi     rf
           adci    0
           phi     rf
           lbr     savelp              ; loop back for next line
savedn:    sep     scall               ; close the file
           dw      o_close
           lbr     mainlp              ; then back to main loop

; ***************************************
; *** Delete current line from buffer ***
; ***************************************
subkill:      sep     scall               ; check if exists
           dw      findline
           lbdf    killquit
           ghi     ra                  ; save dest pointer
           phi     rd
           glo     ra
           plo     rd
           sep     scall               ; move to specified line
           dw      setcurln
           glo     r9                  ; calc source pointer
           str     r2
           glo     r8
           add
           plo     r8
           ghi     r9
           str     r2
           ghi     r8
           adci    0
           phi     r8
           sep     scall               ; get address for line
           dw      findline
killline:  ldn     ra                  ; get length to next line
           lbz     killdone
           adi     1
           plo     rc
killloop:  lda     ra                  ; get source byte
           str     rd                  ; place into destintion
           inc     rd
           dec     rc                  ; decrement count
           glo     rc                  ; get count
           lbnz    killloop            ; loop until line is done
           lbr     killline            ; and loop for next line
killdone:  str     rd
killquit:  lbr    getcurln	; hidden return
	   

	
kill:	   call    subkill
           call      printit	
           lbr     mainlp              ; and back to main

; ********************
; *** Return to OS ***
; ********************
quit:      lbr     o_wrmboot           ; return to os

; ********************************
; *** Move to bottom of buffer ***
; ********************************
bottom:    sep     scall               ; get last line number
           dw      findend
           lbr     topset              ; and set it

; *****************************
; *** Move to top of buffer ***
; *****************************
top:       ldi     0                   ; set line couunter to first line
           phi     r8
           plo     r8
topset:    sep     scall
           dw      setcurln
           sep     scall               ; display top line
           dw      printit
           lbr     mainlp              ; then back to main loop

; *******************************
; *** Insert text into buffer ***
; *******************************
insert:    inc     rf                  ; point to text to insert
           sep     scall               ; set current line
           dw      setcurln
           ldn     rf                  ; see if multi-line insert
           lbnz    insert1             ; only 1 line to insert
insertm:   sep     scall               ; get current line number
           dw      getcurln
           inc     r8
           sep     scall               ; show current line
           dw      printnum
           ldi     ':'                 ; print a colon
           sep     scall 
           dw      o_type
           ldi     high buffer         ; get input from user
           phi     rf
           ldi     low buffer
           plo     rf
           sep     scall
           dw      o_input
           shlc                        ; save return flag
           stxd
           sep     scall               ; do a cr/lf
           dw      docrlf
           irx                         ; recover return flag
           ldx
           shr
           lbdf    mainlp              ; back to main of <CTRL><C> pressed
           ldi     high buffer         ; point to input
           phi     rf
           ldi     low buffer
           plo     rf
           sep     scall               ; insert the line
           dw      insertln
           lbr     insertm

insert1:   sep     scall               ; insert the line
           dw      insertln
           lbr     mainlp              ; back to main loop


insertln:  ldi     0                   ; setup count
           plo     rc
           phi     rc
           glo     rf                  ; save buffer position
           stxd
           ghi     rf
           stxd
insertlp1: inc     rc                  ; increment count
           lda     rf                  ; get next byte
           lbnz    insertlp1
           glo     rc                  ; get count
           stxd                        ; and save it
           inc     rc
           inc     rc
           sep     scall               ; find end of buffer
           dw      findend
           glo     rc                  ; add in count to get destination
           str     r2
           glo     ra
           plo     r9
           add
           plo     rd
           ghi     rc
           str     r2
           ghi     ra
           phi     r9
           adc
           phi     rd
           ghi     rd
           adi     1
           phi     rd
           ghi     r9
           adi     1
           phi     r9
           sep     scall               ; get current line number
           dw      getcurln
           sep     scall               ; find address of line
           dw      findline
insertlp2: ldn     r9                  ; read source byte
           str     rd                  ; place into destination
           glo     ra                  ; check for completion
           str     r2
           glo     r9
           sm
           lbnz    inslp2c
           ghi     ra                  ; check for completion
           str     r2
           ghi     r9
           sm
           lbnz    inslp2c
           lbr     inslp2d
inslp2c:   dec     r9                  ; decrement positions
           dec     rd
           lbr     insertlp2
inslp2d:   sep     scall               ; get current line number
           dw      getcurln
           sep     scall               ; find address of line
           dw      findline
           irx                         ; recover count
           ldxa
           adi     1
           str     ra                  ; store into buffer
           smi     1
           inc     ra
           plo     rc                  ; put into count
           dec     rc                  ; subract out length byte
           ldxa                        ; recover input buffer
           phi     rf
           ldx
           plo     rf
insertlp3: glo     rc                  ; get count
           lbz     insertdn            ; jump if done
           lda     rf                  ; get byte from input
           str     ra                  ; store into text buffer
           inc     ra
           dec     rc                  ; decrement count
           lbr     insertlp3           ; loop back until done
insertdn:  ldi     13                  ; place in a cr/lf
           str     ra
           inc     ra
           ldi     10
           str     ra
           sep     scall               ; get current line number
           dw      getcurln
           inc     r8                  ; increment it
           sep     scall               ; and write it back
           dw      setcurln
           sep     sret                ; return to caller

; *******************************
; *** Print lines from buffer ***
; *******************************
print:     glo     r9                  ; check count
           lbnz    printgo             ; jump if more lines
           ghi     r9                  ; check high byte as well
           lbnz    printgo
           lbr     mainlp              ; done, so return to main loop
printgo:   sep     scall               ; print current line
           dw      printit
           inc     r8                  ; increment line number
           dec     r9                  ; decrement count
           lbr     print               ; loop back for more
          
; *****************************
; *** Move up in the buffer ***
; *****************************
up:        glo     r9                  ; check count
           lbnz    upgo1
           ghi     r9
           lbnz    upgo1
           sep     scall               ; print new line
           dw      printit
           lbr     mainlp
upgo1:     sep     scall               ; get current line number
           dw      getcurln
           glo     r8                  ; make sure it is not already 0
           lbnz    upgo                ; jump if good
           ghi     r8
           lbnz    upgo
           ldi     high topmsg         ; display top of buffer message
           phi     rf
           ldi     low topmsg
           plo     rf
           sep     scall               ; display message
           dw      o_msg
           lbr     mainlp
upgo:      dec     r8                  ; decrement line count
           sep     scall               ; write new line number
           dw      setcurln
           dec     r9                  ; decrement count
           lbr     up                  ; and loop back for more

; *******************************
; *** Move down in the buffer ***
; *******************************
down:      glo     r9                  ; check count
           lbnz    downgo
           ghi     r9
           lbnz    downgo
           sep     scall               ; print new line
           dw      printit
           lbr     mainlp
downgo:    sep     scall               ; get current line number
           dw      getcurln
           inc     r8                  ; add 1 to count
           sep     scall               ; see if it is valid
           dw      findline
           lbdf    eoberror            ; jump if it moves past end
           sep     scall               ; write new line number
           dw      setcurln
           dec     r9                  ; decrement count
           lbr     down                ; loop back for more

; *********************************
; *** Print specified line      ***
; *** R8 - Line number to print ***
; *********************************
printit:   sep     scall               ; set buffer position
           dw      findline
           lbnf    printitgo           ; jump if line exists
           sep     sret                ; otherwise just return
printitgo: inc     r8                  ; output origin is 1
           sep     scall               ; print the line number
           dw      printnum
           dec     r8                  ; reorigin to zero
           ldi     high colon          ; now the colon after the number
           phi     rf
           ldi     low colon
           plo     rf
           sep     scall
           dw      o_msg
printnonum:	
           lda     ra                  ; get byte count
           plo     rc                  ; place into count register
           lbz     printend            ; jump if have last line of buffer
printlp:   glo     rc                  ; see if done
           lbz     printdn             ; jump if so
           lda     ra                  ; otherwise get byte
           sep     scall               ; and display it
           dw      o_type
           dec     rc                  ; decrement count
           lbr     printlp
printdn:   sep     sret                ; return to caller
printend:  sep     scall               ; print a final CR/LF
           dw      docrlf
           sep     sret                ; and return to caller

; *****************************************
; *** Get current line number           ***
; *** Returns: R8 - current line number ***
; *****************************************
getcurln:  ldi     high curline        ; point to current line
           phi     rf
           ldi     low curline
           plo     rf
           lda     rf                  ; get current line number
           phi     r8
           lda     rf
           plo     r8
           sep     sret                ; and return

; *******************************************
; *** Set current line to specified value ***
; *** R8 - Line number to set as current  ***
; *******************************************
setcurln:  glo     rf                  ; save consumed register
           stxd
           ghi     rf
           stxd
           ldi     high curline        ; point to current line
           phi     rf
           ldi     low curline
           plo     rf
           ghi     r8                  ; write new current line
           str     rf
           inc     rf
           glo     r8
           str     rf
           irx                         ; recover consumed register
           ldxa
           phi     rf
           ldx
           plo     rf
           sep     sret                ; and return
 
; ***********************************
; *** Display end of buffer error ***
; ***********************************
eoberror:  ldi     high endmsg         ; point to end of buffer message
           phi     rf
           ldi     low endmsg
           plo     rf
           sep     scall               ; display it
           dw      o_msg
           lbr     mainlp              ; then back to main loop

; ********************************
; *** Display new file message ***
; ********************************
newfile:   ldi     high newmsg         ; display message indicating new file
           phi     rf
           ldi     low newmsg
           plo     rf
           sep     scall               ; display the message
           dw      o_msg
           lbr     mainlp              ; branch to main loop

; *************************************
; *** Find line in text buffer      ***
; *** R8 - line number              ***
; *** Returns: RA - pointer to line ***
; *************************************
findline:  ldi     high textbuf        ; point to text buffer
           phi     ra
           ldi     low textbuf
           plo     ra
           ghi     r8                  ; get line number
           phi     rc
           glo     r8
           plo     rc
findlp:    ghi     rc
           lbnz    notfound
           glo     rc                  ; see if count is zero
           lbz     found               ; jump if there
notfound:  lda     ra
           lbz     fnderr              ; jump if end of buffer was reached
           str     r2                  ; prepare for add
           glo     ra                  ; add to address
           add
           plo     ra
           ghi     ra
           adci    0
           phi     ra
           dec     rc                  ; decrement count
           lbr     findlp              ; and check line
found:     ldi     0                   ; signal line found
           shr
           sep     sret                ; and return to caller
fnderr:    dec     ra
           ldi     1                   ; signal end of buffer reached
           shr
           sep     sret                ; return to caller

; *************************************
; *** Find end of buffer            ***
; *** Returns: R8 - Line number     ***
; ***          RA - pointer to line ***
; *************************************
findend:   ldi     high textbuf        ; get text buffer
           phi     ra
           ldi     low textbuf
           plo     ra
           ldi     0                   ; setup count
           phi     r8
           plo     r8
findendlp: lda     ra                  ; get count
           lbz     findenddn           ; jump if end was found
           str     r2
           glo     ra
           add
           plo     ra
           ghi     ra
           adci    0
           phi     ra
           inc     r8                  ; increment count
           lbr     findendlp
findenddn: dec     ra                  ; move back to count byte
           sep     sret                ; and return

readln:    ldi     0                   ; set byte count
           phi     rc
           plo     rc
readln1:   sep     scall               ; read a byte
           dw      readbyte
           lbdf    readlneof           ; jump on eof
           plo     re                  ; keep a copy
	   smi	   9		       ; allow tabs!
	   bz      readln2
	   glo     re
           smi     32                  ; look for anything below a space
           lbnf    readln1
readln2:   glo     re                  ; recover byte
           str     rf                  ; store into buffer
           inc     rf                  ; point to next position
           inc     rc                  ; increment character count
           sep     scall               ; read next byte
           dw      readbyte
           lbdf    readlneof           ; jump if end of file
           plo     re                  ; keep a copy of read byte
	   smi	   9		       ; allow tabs!
	   bz      readout
	   glo     re
           smi     32                  ; make sure it is positive
           lbdf    readln2             ; loop back on valid characters
readout:	
           ldi     0                   ; signal valid read
readlncnt: shr                         ; shift into DF
           sep     sret                ; and return to caller
readlneof: ldi     1                   ; signal eof
           lbr     readlncnt

readbyte:  glo     rf
           stxd
           ghi     rf
           stxd
           glo     rc
           stxd
           ghi     rc
           stxd
           ldi     high char
           phi     rf
           ldi     low char
           plo     rf
           ldi     0
           phi     rc
           ldi     1
           plo     rc
           sep     scall
           dw      o_read
           glo     rc
           lbz     readbno
           ldi     0
readbcnt:  shr
           ldi     high char
           phi     rf
           ldi     low char
           plo     rf
           ldn     rf
           plo     re
           irx
           ldxa
           phi     rc
           ldxa
           plo     rc
           ldxa
           phi     rf
           ldx
           plo     rf
           glo     re
           sep     sret
readbno:   ldi     1
           lbr     readbcnt

; ****************************
; *** Print number         ***
; *** R8 - Number to print ***
; ****************************
printnum:  ghi     r8                  ; transfer number to RD
           phi     rd
           glo     r8
           plo     rd
           ldi     high numbuf         ; setup buffer
           phi     rf
           ldi     low numbuf
           plo     rf
           sep     scall               ; convert number
           dw      f_uintout
           ldi     0                   ; terminate the string
           str     rf
           ldi     high numbuf         ; point back to number
           phi     rf
           ldi     low numbuf
           plo     rf
           sep     scall               ; display the number
           dw      o_msg
           sep     sret                ; and return to caller

ledit:
	sep     scall		; first we need to print the line with 2 spaces in front (no line number)
	dw 	findline
	lbdf    mainlp
	glo	ra
	push    ra
        sep     scall               ; move to specified line
        dw      setcurln
	ldi ' '
	sep scall
	dw o_type
	ldi ' '
	sep scall
	dw o_type
	lda ra
	plo rc
leditlp:
	glo rc
	bz leditlpdn
	dec rc
	ldn ra
	smi 9  			; convert tab to underscore
	bnz leditlp1
	ldi '_'
	br leditlp2
leditlp1:
	ldn ra			 
leditlp2:	
	inc ra			; don't use lda because we might be sub'd
	call o_type
	br leditlp
leditlpdn:			; now we type the edit line: a colon and then input
	ldi ':'
	sep scall
	dw o_type
	ldi high buffer
	phi rf
	ldi low buffer
	plo rf
	sep scall
	dw o_input
	shlc
	stxd
	sep scall
	dw docrlf
	irx
	ldx
	shr
	lbdf mainlp
	;;  do magic here R8=Line#, RB=pointer to ebuf, RF=pointer to input buffer, RA=pointer to line RE.0 = mode
	;; point to ebuffer Note that line has a counter (we will put in rc)
	pop ra			; restore line pointer
	lda ra
	plo rc			; get line counter (deduct 2 for CRLF)
	dec rc
	dec rc
	ldi high ebuffer	; point to edit buffer
	phi rb
	ldi low ebuffer
	plo rb
	;;  set to norm mode
	ldi 0
	plo re
	ldi high buffer
	phi rf
	ldi low buffer
	plo rf
	;; check *buffer (note first character doesn't directly change the string, just the mode (^,') or kill ($) or space for no change
	ldn rf
	lbz leditm1fin2   	; no input, just copy line
	smi 27h 		; quote
	bnz leditchk
	inc re			; overwrite mode in position 1 (do we need this anymore?)
	inc rf			; skip to first edit position
	br leditm1		; mode 1
leditchk:
	ldn rf
	smi '^'			; insert mode at position 0
	bnz leditcheckpl
	inc re
	inc re
	inc rf
	lbr leditmode2		; mode 2

leditcheckpl:	
	ldn rf
	smi '+'			; this is only valid in posiiton 0
	bnz leditcheckdol
	;;  copy entire line to append
leditapp:
	glo rc
	bz leditapp1		; done when count is zero
	lda ra
	str rb
	inc rb
	dec rc
	br leditapp
	;;  copy rest of input buffer
leditapp1:	
	inc rf  		; skip the +
	lbr leditm1fin1		
leditcheckdol:
	ldn rf			
	smi '$'  		; make an emptry string
	lbz ledz
	;;  fall through

leditchecked:	; ok we processed the first character which must be space, quote, caret, plus or $ 
	inc rf	; move to next character
leditnxt:	
	ldn rf
	phi rc			; save input character for later (might be zero)
ledit1st:	
	;; if ' we go to overwrite mode
	smi 27h
	bnz leditcont0
	inc re  		; mode 1
leditcont0:
	ghi rc
;; if ^ we go to insert mode
	smi '^'
	bnz leditcont1
	ldi 2			; mode 2
	plo re
leditcont1:
	ghi rc
	smi '$'
	bnz leditxtest
	lda ra			; kill line after this character
	str rb			; store this character
	inc rb
	lbr ledz		; done
leditxtest:			; check for delete (x or X)
	ghi rc
	ani 0dfh  ; make upper case
	;;  need to add + mode here later and > or $ mode (kill to eols)
	smi 'X'
	bz  leditdel
	;; if *buffer is sp,',or ^ then copy line to ebuffer
leditatend:	
	lda ra    		; get *line
	str rb			; store in *ebuf
	inc rb			; next
	glo re
	bnz leditmc	    	; don't test below if we are starting a mode
	dec rb			; point back
	glo rc			; end of line?
	lbz  ledz               ; just in case line was empty (should not happen other than in position 0)
	inc rb			; point forward again
	dec rc			; see if more on real line
	glo rc
	lbz ledz
	inc rc  		; prep for next dec
leditmc:
	dec rc		; decrement in either case
	ldn rf			; if input pointer is at zero do not increment
	bz  leditnoincf
	inc rf			; next input char
leditnoincf:	
	glo re
	bz leditnxt   		; normal
	;;  we are just starting mode 1 (over) or mode 2 (insert)
	smi 2
	lbz leditmode2
	;; ok we do overwrite until end of our string and/or the line, whichever is longer (if we are longer need to add CRLF)
leditm1:
	lda rf
	phi rc			; save for later
	lbz leditm1fin2         ; end of our input, go copy the rest of the line
	str rb			; otehrwise put in ebuffer
	inc rb			; advance ebuffer
	inc ra			; advance line pointer
	dec rc
	glo rc
	lbz  leditm1fin1	; at end of line so go to rest of input string (this is overwrite)
	br leditm1              ; midstream keep going

	;; X command, delete
leditdel:
	inc rf			; get to next input character
	inc ra			; skip next character in line
	dec rc
	glo rc
	bnz leditnxt		; no more line
	lbr ledz
leditm1fin1:			; copy rest of input string
	lda rf
	lbz  leditcrlf
	str rb
	inc rb
	br leditm1fin1
	
leditm1fin2:			; copy rest of line
	glo rc
	lbz ledz
	lda ra
	str rb
	inc rb
	dec rc
	br leditm1fin2
	
leditmode2:                  	; insert all of input string and then the rest of the line

	lda rf
	bz  leditm1fin2
	str rb
	inc rb
	br  leditmode2

	
ledz:
leditcrlf:	
#if 0	
	ldi 0dh
	str rb
	inc rb
	ldi 0ah
	str rb
	inc rb
	;; debug
	ldi 0
	str rb  		; make sure we are terminated
	glo rb
	str r2
	ldi high ebuffer
	phi ra
	ldi low ebuffer
	plo ra
	sd
	dec ra                  ; point to count
	str ra    		; write count
	sep scall
	dw printitgo
	lbr mainlp
#else
	ldi 0
	str rb
	glo rb
	str r2
	ldi high ebuffer
	phi rf
	ldi low ebuffer
	plo rf
	push r8
	call insertln  		
	ldi 0
	phi r9
	plo r9
	inc r9  		; R9=1
	call subkill
	pop r8
	call setcurln
	call printit
	lbr mainlp
#endif

	
leditins:	
	;; if insert mode move *buffer, *ebuffer until end of buffer. Then move rest of line to ebuffer
	;; when done, kill line, insert ebuffer
	lbr mainlp

char:      db      0
newmsg:    db      'New file'
crlf:      db      13,10,0
endmsg:    db      'End of buffer',10,13,0
topmsg:    db      'Top of buffer',10,13,0
errmsg:    db      'Error',10,13,0
prompt:    db      '>',0
colon:     db      ':',0
curline:   dw      0
reg1:      dw      0
reg2:      dw      0
fname:     ds      80
fildes:    db      0,0,0,0
fildesdta: dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0

end:       equ     $

dta:       ds      512


buffer:    ds      128
ecount:	   ds      1    	; must be before ebuffer
ebuffer:   ds      127	 
numbuf:    ds      16

; text buffer format
; byte size of line (0 if end of buffer)
textbuf:   db      0

