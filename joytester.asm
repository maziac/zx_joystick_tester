;===========================================================================
; joytester.asm
;
; This is a program to test the joystick connected to a ZX Spectrum or
; ZX Spectrum Next.
;
; Features:
; - Kempston IF support
; - Sinclair IF support
; - ZX Next 3 Button Joystick support
; - Supports both joysticks.
;
;===========================================================================

;===========================================================================
; Constants.
;===========================================================================


; Color codes
BLACK:          equ 0
BLUE:           equ 1
RED:            equ 2
MAGENTA:        equ 3
GREEN:          equ 4
CYAN:           equ 5
YELLOW:         equ 6
WHITE:          equ 7
BRIGHT:     equ 01000000b ; (Bit 6)

; Color for joystick bit (button or direction) that is not set.
COLOR_BIT_NOT_SET:  equ (WHITE<<3)+BRIGHT

; Color for joystick bit (button or direction) that is set.
COLOR_BIT_SET:      equ (RED<<3)+BRIGHT

; Interface II joystick ports.
PORT_IF2_JOY_0: equ 0xEFFE ; Keys: 6, 7, 8, 9, 0
PORT_IF2_JOY_1: equ 0xF7FE ; Keys: 5, 4, 3, 2, 1

; Kempston joystick ports.
PORT_KEMPSTON_JOY0: equ 0x1f 
PORT_KEMPSTON_JOY1: equ 0x37

; Fuller joystick port.
PORT_FULLER:    equ 0x7f 

; ZXNext peripheral.
REG_PERIPHERAL_1:	equ	5


; String formatting.
EOS:    equ 0xff    ; End of string:
AT:     equ 0x16    ; ZX Spectrum ASCII Control code: AT, y, x

; Color attribute screen.
SCREEN_COLOR_ATTR:  equ 0x5800

; Color screen width.
COLOR_SCREEN_WIDTH: equ 32

; Start addresses for visualization.
COLOR_ATTR_IF2_JOY0:    equ SCREEN_COLOR_ATTR+7*COLOR_SCREEN_WIDTH+15
COLOR_ATTR_IF2_JOY1:    equ COLOR_ATTR_IF2_JOY0+9

COLOR_ATTR_KEMPSTON_JOY0:   equ COLOR_ATTR_IF2_JOY0+COLOR_SCREEN_WIDTH
COLOR_ATTR_KEMPSTON_JOY1:   equ COLOR_ATTR_KEMPSTON_JOY0+9

COLOR_ATTR_FULLER:  equ COLOR_ATTR_KEMPSTON_JOY0+COLOR_SCREEN_WIDTH

COLOR_ATTR_ZXNEXT_JOY0: equ COLOR_ATTR_FULLER+COLOR_SCREEN_WIDTH
COLOR_ATTR_ZXNEXT_JOY1: equ COLOR_ATTR_ZXNEXT_JOY0+9


;===========================================================================
; Macros.
;===========================================================================

; For "out-of-bounds" checks.
MEMGUARD:	macro
    defs 1 ; WPMEM
    endm


; Directly sets a Next Feature Control Register with the given value.
; Parameters:
;	register = The Next Feature Control Register to set.
;	value = The value for the register.
NEXTREG:	macro	register value
	defb 0xED, 0x91
	defb register
	defb value
	endm


; Multiplies D by E and stores the result in DE.
; Does not alter any flags.
; Input:	DE
; Output:	DE = D*E
MUL_D_E:	macro
	defb 0xED, 0x30
	endm

;===========================================================================
; Start of main program.
;===========================================================================

    org 0x7000

LBL_MAIN:
    di


    ; Setup stack
    ld sp,stack_top

    ; Load system variable to iy

	; Enable interrupt
    ei

    ; Allow printing to bottom lines.
    ;ld a,0
    ;ld (VAR_BOTTOM_LINES),a

    ; Set pointer to user defined graphics
;    ld hl,user_defined_graphics
;    ld (VAR_UDG),hl  

    ; Print text.
    ld hl,LBL_COMPLETE_TEXT
    call print

; The main loop:
; - Check joystick input
; - Visualize it
main_loop:
    ; Make the loop slower.
    halt
    
    ; Visualize.
    ;ld hl,AT_JOY0
    ;call print

    ; Get joystick value. Interface II, joystick 0
    ld bc,PORT_IF2_JOY_0
    ld hl,COLOR_ATTR_IF2_JOY0
    call visualize_joystick

    ; Get joystick value. Interface II, joystick 1
    ld bc,PORT_IF2_JOY_1
    ld hl,COLOR_ATTR_IF2_JOY1
    call visualize_joystick

    ; Get joystick value. Kempston, joystick 0.
    ld bc,PORT_KEMPSTON_JOY0
    ld hl,COLOR_ATTR_KEMPSTON_JOY0
    call visualize_joystick

    ; Get joystick value. Kempston, joystick 1.
    ld bc,PORT_KEMPSTON_JOY1
    ld hl,COLOR_ATTR_KEMPSTON_JOY1
    call visualize_joystick

    ; Get joystick value. Fuller.
    ld bc,PORT_FULLER
    ld hl,COLOR_ATTR_FULLER
    call visualize_joystick



    ; Check for ZX Next, i.e. check if extended opcodes are available.
    ld e,2
    ld d,e
    MUL_D_E
    ld a,e
    cp 4
    jr nz,main_loop


    ; ZXNext joystick.
    ; Uses the same ports as IF2 or Kempston, but allows for more buttons.
    NEXTREG REG_PERIPHERAL_1 01101010b  ; Use 3 button mode

    ; Get joystick value. Interface II, joystick 0
    ld bc,PORT_IF2_JOY_0
    ld hl,COLOR_ATTR_ZXNEXT_JOY0
    call visualize_joystick

    ; Get joystick value. Interface II, joystick 1
    ld bc,PORT_IF2_JOY_1
    ld hl,COLOR_ATTR_ZXNEXT_JOY1
    call visualize_joystick

    NEXTREG REG_PERIPHERAL_1 11000000b  ; Switch back to normal mode

    jr main_loop


; Visualizes the Joystick Input.
; IN: BC = Port to read (Joystick input)
;     HL = Pointer to start address in color attributes screen.
visualize_joystick:
    in a,(c)
    ld b,8  ; 8 bits
visualize_joystick_loop:
    rlca    ; Rotate left most bit into carry
    ld c,COLOR_BIT_NOT_SET
    jr c,visualize_joystick_l1
    ld c,COLOR_BIT_SET  ; Show as pressed if bit is zero
visualize_joystick_l1:
    ; Set color on screen
    ld (hl),c
    inc hl
    djnz visualize_joystick_loop
    ret


; Prints a text until an EOS (end of string) is found.
; IN: HL = Points to the start of the text. The text may contains positional
;       commands like AT.
print:
    ; Load character.
    ld a,(hl)
    cp EOS
    ret z   ; Return if end found

    ; Print
    rst 10h

 ;ret	

    ; Next
    inc hl
    jr print



;===========================================================================
; Constant data.
;===========================================================================

; Texts.

LBL_COMPLETE_TEXT:
    defb AT, 0, 0
    defb 'Joystick Tester for ZX Spectrum and ZX Next. Version 1.0.'
    defb AT, 3, 0
    defb 'White=1, Red=0, Black=Not Avail.'
    
    defb AT, 5, 15
    defb 'Joy0:    Joy1:'
    defb AT, 6, 15
    defb '76543210 76543210'

    defb AT, 7, 0
    defb 'Interface II:  ???<>v^F ???F^v><'

    defb AT, 8, 0
    defb 'Kempston:      ???F^v<> ???F^v<>'

    defb AT, 9, 0
    defb 'Fuller:        F???><v^'

    defb AT, 10, 0
    defb 'ZXNext:        SACB^v<> SACB^v<>'

    defb EOS
    


;===========================================================================
; STACK
; Stack: this area is reserved for the stack
STACK_SIZE: equ 100d    ; in words

; Reserve stack space
stack_check:
    MEMGUARD
stack_bottom:
    defs    STACK_SIZE*2, 0
stack_top:
;===========================================================================

