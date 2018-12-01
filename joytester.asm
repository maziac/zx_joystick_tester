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

main_loop:


    jr main_loop



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
