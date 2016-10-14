*-----------------------------------------------------------
* Title      :  68000 dec to hex
* Written by :  karimo
* Date       :
* Description:  does some instructions and prints hexadecimal values
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    
* Put program code here
* prompt for the first value, and store into d2

    lea     input1prompt, a1
    move    #13,d0
    trap    #15
    jsr     loop
    jsr     nl ;jump to newline subroutine to print a newline
    
* prompt for the second value, store in d4
    lea     input2prompt, a1
    move    #13,d0
    trap    #15
    jsr     loop2
    jsr     nl
    
    *increment that we're done with the first value (d7 keeps track of this)
    addi.b  #1,d7
    
    *print the values entered as hexadecimal  
    bra     divide_val_one
    
start2:
*begin work on the second value entered
    jsr     nl
    cmp.b   #2,d7 ;if we're done, then go to simhalt
    beq     done
    *move whatever is in d4 into d2, and just work with d2 again
    move    d4,d2
    *clear d3 and d6 (used for checking if we're done with comparisons)
    clr.l   d3
    clr.l   d6
    clr.l   d5 ;clear d5 as well
    addi.b  #1,d7
    bra     divide_val_one
    
done:
    SIMHALT
loop:    
    move    #5,d0 ;read in, trap task 5 does this
    trap    #15   ;you need to trap always after this
    cmp.b   #$0D, D1 ;do we have a carriage return (enter pressed)?
    beq     break ;if so, break
    
    and.b   #$0F, d1 ;store the current value & add to it successive chars
    mulu    #10, d2 ;multiply the current value in d2 by 10
    add.w   d1, d2 ;move whatever is in d1 to d2
    bra     loop
    
loop2:
    move    #5,d0
    trap    #15
    cmp.b   #$0D, d1
    beq     break
    
    and.b   #$0F, d1 ;store in d4
    mulu    #10, d4
    add.w   d1,d4
    bra     loop2

divide_val_one:
    *val 1 resides in d2
    *check to see if d2 is blank, that means we're done
    cmp.b   #00,d2
    beq     start2
    
    divs.w  #16,d2
    *increment our counter used for checking if we're done later...(d6)
    addi.b  #1,d6
    *push the remainder to the stack
    swap    d2
    move.b  d2,d5 *store the remainder in d5
    movem.l d5,-(a7)
    move.b  #00,d2
    swap    d2
    cmp.b   #00,d2
    beq.s   print_hex
    bra     divide_val_one
    

print_hex:
    *pop from a7, the value goes to d5
    movem.l (a7)+,d5
    *increment a counter to count how many times we've popped from stack (d3)
    addi.b  #1,d3
    *first check if we're done
    cmp.b   d6,d3
    bgt     divide_val_one *we got some large value after popping from the stack, we're done
    *compare, is the value less than 10, if so, just print, else, lookup and print the corresponding letter
    cmp.b   #$A,d5
    blt.s   print_d5
    bgt.s   print_letter
    beq.s   print_letter
    cmp.b   #00,d5
    beq     break
    bra     print_hex    

    
print_d5:
    clr.l   d0
    move    #3,d0
    clr.l   d1
    move    d5,d1
    trap    #15
    jmp     print_hex
    

print_letter:
    cmp.b   #$A,d5
    beq     print_a
    cmp.b   #$B,d5
    beq     print_b
    cmp.b   #$C,d5
    beq     print_c
    cmp.b   #$D,d5
    beq.s   print_d
    cmp.b   #$E,d5
    beq     print_e
    cmp.b   #$F,d5
    beq     print_f
    bra     print_hex
    
print_a:
    move    #14,d0 *print a null terminated string w/o cr lf
    lea     letter_a,a1
    trap    #15
    bra     print_hex
    
print_b:
    move    #14,d0 *print a null terminated string w/o cr lf
    lea     letter_b,a1
    trap    #15
    bra     print_hex
    
print_c:
    move    #14,d0 *print a null terminated string w/o cr lf
    lea     letter_c,a1
    trap    #15
    bra     print_hex
    
print_d:
    clr.l   d0
    move.l  d0,a1
    move    #14,d0 *print a null terminated string w/o cr lf
    lea     letter_d,a1
    trap    #15
    jmp     print_hex
    
print_e:
    move    #14,d0 *print a null terminated string w/o cr lf
    lea     letter_e,a1
    trap    #15
    jmp     print_hex
    
print_f:
    move    #14,d0 *print a null terminated string w/o cr lf
    lea     letter_f,a1
    trap    #15
    jmp     print_hex
    
break:
    rts
    
nl:
    move    #14,d0 ;task number 14 into d0 (display null terminated string without cr, lf)
    lea     crlf,a1
    trap    #15
    rts


       
* Put variables and constants here
input1prompt    dc.b    'enter the first value: ',0
input2prompt    dc.b    'enter the second value: ',0

input1result    dc.b    'input 1 hex: ',0
input2result    dc.b    'input 2 hex: ',0

crlf:       dc.b    $d,$a,0

letter_a    dc.b    'A',0
letter_b    dc.b    'B',0
letter_c    dc.b    'C',0
letter_d    dc.b    'D',0
letter_e    dc.b    'E',0
letter_f    dc.b    'F',0

    END    START        ; last line of source
