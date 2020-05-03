# bashie
A crazy, experimental new project in writing a high-performance scripting language entirely in bash. :P

### Getting started:

Run these commands in an unix like OS:

```bash

cd ./bashie 
cd ./compiler 
mkdir ../output

compile.bat <PathToYourFile.asm>
# may not work now since im still constructing the vm

```

### Options:

#### Debug:

Debug a .asm file with:

```bash

compile -d <PathToYourFile.asm>

```

---
#### Samples:

In serial.asm:

```asm
An implementation of SLIP (Serial Link IP), RFC 1055 in assembly language

; slip.asm
;
; This is an 8086+ implementation of SLIP (RFC 1055)
;
; It may be assembled using Microsoft's MASM using the command line:
;   ml -Fl -c slip.asm
;
; or using Borland's TASM using the command line:
;   tasm -la -m2 -jLOCALS slip.asm
;
        .model small
        .stack 100h
        .data
SLIP_END        equ 0C0h
SLIP_ESC        equ 0DBh
SLIP_ESC_END    equ 0DCh
SLIP_ESC_ESC    equ 0DDh

; note that these are both sample macros and are very simple
; In both cases, DX is assumed to already be pointing to the
; appropriate I/O port and a character is always assumed to
; be ready.
SEND_CHAR macro char
        IFDIFI <char>, <al>
                mov al,char
        ENDIF
        out dx,al
endm

RECV_CHAR macro
        in al,dx
endm
        .code
;****************************************************************************
; send_packet
;
; sends the passed packet (which is in a memory buffer) to the output
; device by using the macro SEND_CHAR() which must be defined by the
; user.  A sample SEND_CHAR() is defined above.
;
; Entry:
;       DS:SI ==> raw packet to be sent
;       CX = length of raw packet to be sent
;       direction flag is assumed to be cleared (incrementing)
;
; Exit:
;
;
; Trashed:
;       none
;
;****************************************************************************
send_packet proc
        push cx
        push si
        SEND_CHAR SLIP_END      ; send an end char to flush any garbage
        jcxz @@bailout          ; if zero length packet, bail out now
@@nextchar:
        lodsb                   ; load next char
        cmp al,SLIP_END         ; Q: is it the special END char?
        jne @@check_esc         ;  N: check for ESC
        SEND_CHAR SLIP_ESC      ;  Y: send ESC + ESC_END instead
        mov al,SLIP_ESC_END     ;
        jmp @@ordinary          ;

@@check_esc:
        cmp al,SLIP_ESC         ; Q: is it the special ESC char?
        jne @@ordinary          ;  N: send ordinary char
        SEND_CHAR SLIP_ESC      ;  Y: send ESC + ESC_END instead
        mov al,SLIP_ESC_ESC     ;
        ; fall through to ordinary character

@@ordinary:
        SEND_CHAR al            ;

        loop @@nextchar         ; keep going until we've sent all chars
@@bailout:
        SEND_CHAR SLIP_END      ; send an end char to signal end of packet
        pop si
        pop cx
        ret
send_packet endp

;****************************************************************************
; recv_packet
;
; receives a packet using the macro RECV_CHAR() which must be defined by
; the user and places the received packet into the memory buffer pointed
; to by ES:DI.  The final length is returned in BX.
;
; Note that in the case of a buffer overrun, the portion of the packet
; that fit into the buffer is returned and BX and CX are equal.  There
; is no way to tell the difference between a packet that just exactly
; fit and one which was truncated due to buffer overrun, so it is
; important to assure that the buffer is big enough to ALWAYS contain
; at least one spare byte.
;
; A sample RECV_CHAR() is defined above.
;
; Entry:
;       ES:DI ==> packet buffer
;       CX = length of buffer
;       direction flag is assumed to be cleared (incrementing)
;
; Exit:
;       BX = length of packet received
;
; Trashed:
;       none
;
;****************************************************************************
recv_packet proc
        push cx
        push di
        xor bx,bx               ; zero received byte count
        jcxz @@bailout          ; if zero length packet, bail out now
@@nextchar:
        RECV_CHAR               ; fetch a character into al
        cmp al,SLIP_END         ; Q: is it the special END char?
        jne @@check_esc         ;  N: check for ESC
        or  bx,bx               ;  YQ: is it the beginning of packet?
        jz @@nextchar           ;   Y: keep looking
        jmp @@bailout           ;   N: end of packet, so return it

@@check_esc:
        cmp al,SLIP_ESC         ; Q: is it the special ESC char?
        jne @@ordinary          ;  N: it's an ordinary char
        RECV_CHAR               ;  Y: get another character
        cmp al,SLIP_ESC_END     ;  Q: is it ESC_END?
		jne @@check_esc_esc		;   N: check for ESC_ESC
        mov al,SLIP_END         ;   Y: convert to ordinary END char
        jmp @@ordinary          ;
@@check_esc_esc:
        cmp al,SLIP_ESC_ESC     ;  Q: is it ESC_ESC?
        mov al,SLIP_ESC         ;   Y: convert to ordinary ESC char
        ; protocol violation! fall through to ordinary character

@@ordinary:
        stosb                   ; store character in buffer
        inc bx                  ; got another char
        loop @@nextchar         ; keep going until we've sent all chars
@@bailout:
        pop di
        pop cx
        ret
recv_packet endp
        END

```

Author: Timo Sarkar


Domo Arigato! And happy coding.




