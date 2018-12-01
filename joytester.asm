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

; Interface II Joystrick ports.
PORT_IF2_JOY_0: equ 0xEFFE ; Keys: 6, 7, 8, 9, 0
PORT_IF2_JOY_1: equ 0xF7FE ; Keys: 5, 4, 3, 2, 1


; Color attribute screen.
SCREEN_COLOR_ATTR:  equ 0x5800

; Color screen width.
COLOR_SCREEN_WDITH: equ 32

; Start addresses for visualization.
COLOR_ATTR_IF2_JOY0:    equ SCREEN_COLOR_ATTR
COLOR_ATTR_IF2_JOY1:    equ SCREEN_COLOR_ATTR+2*COLOR_SCREEN_WDITH


;===========================================================================
; Macros.
;===========================================================================

; For "out-of-bounds" checks.
MEMGUARD:	macro
    defs 1 ; WPMEM
    endm



;===========================================================================
; Start of main program.
;===========================================================================

    ; 0x0000 to 0x3FFF is ROM
	org	4000h

    ; Start at 0x6000
    defs    0x6000 - $, 0


LBL_MAIN:
    di

    ; Setup stack
    ld sp,stack_top

	; Enable interrupt
    ei

    ; Allow printing to bottom lines.
    ld a,0
    ;ld (VAR_BOTTOM_LINES),a

    ; Set pointer to user defined graphics
;    ld hl,user_defined_graphics
;    ld (VAR_UDG),hl  


; The main loop:
; - Check joystick input
; - Visualize it
main_loop:


    ; Visualize.
    ;ld hl,AT_JOY0
    ;call print

    ; Get joystick value. Interface II, joystick 0
    ld bc,PORT_IF2_JOY_0
    in a,(c)

    ; Visualize 
    ld hl,COLOR_ATTR_IF2_JOY0
    call visualize_joystick

    ; Get joystick value. Interface II, joystick 0
    ld bc,PORT_IF2_JOY_1
    in a,(c)

    ; Visualize 
    ld hl,COLOR_ATTR_IF2_JOY1
    call visualize_joystick

    jr main_loop


; Visualizes the Joystick Input.
; IN: A = The joystick input.
;   Bit:    0 = Right
;           1 = Left
;           2 = Down
;           3 = Up
;           4 = B
;           5 = C
;           6 = A
;           7 = Start
;     HL = Pointer to start address in color attributes screen.
visualize_joystick:
    ld b,8  ; 8 bits
visualize_joystick_loop:
    rrca    ; Rotate right most bit into carry
    ld c,COLOR_BIT_NOT_SET
    jr nc,visualize_joystick_l1
    ld c,COLOR_BIT_SET
visualize_joystick_l1:
    ; Set color on screen
    ld (hl),c
    inc hl
    djnz visualize_joystick_loop
    ret


;===========================================================================
; STACK
; Fill up to 0xF000
defs 0xF000 - $

; Stack: this area is reserved for the stack
STACK_SIZE: equ 100d    ; in words

; Reserve stack space
stack_check:
    MEMGUARD
stack_bottom:
    defs    STACK_SIZE*2, 0
stack_top:
;===========================================================================


;===========================================================================
; Here is the start from the SNA header.
   defs    0xFDFA - $, 0
LBL_SNA_START_ADDR: ; should be 0xFDFA
   defw    LBL_MAIN ; The .sna format expects the starting address on the stack.
;===========================================================================


; Fill up to 65535
defs 0x10000 - $
