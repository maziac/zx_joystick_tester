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
PORT_IF2_JOY_1: equ 0xEFFE ; Keys: 6, 7, 8, 9, 0, Bits: xxxLRDUF
PORT_IF2_JOY_2: equ 0xF7FE ; Keys: 5, 4, 3, 2, 1, Bits: xxxFUDRL

; Kempston joystick ports.
PORT_KEMPSTON_JOY1: equ 0x1f 
PORT_KEMPSTON_JOY2: equ 0x37

; Fuller joystick port.
PORT_FULLER:    equ 0x7f 

; Keyboard port
KEYB_ASDFG:     equ 0xFDFE


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
COLOR_ATTR_IF2_JOY1:    equ SCREEN_COLOR_ATTR+7*COLOR_SCREEN_WIDTH+15
COLOR_ATTR_IF2_JOY2:    equ COLOR_ATTR_IF2_JOY1+9

COLOR_ATTR_KEMPSTON_JOY1:   equ COLOR_ATTR_IF2_JOY1+COLOR_SCREEN_WIDTH
COLOR_ATTR_KEMPSTON_JOY2:   equ COLOR_ATTR_KEMPSTON_JOY1+9

COLOR_ATTR_FULLER:  equ COLOR_ATTR_KEMPSTON_JOY1+COLOR_SCREEN_WIDTH

COLOR_ATTR_ZXNEXT_JOY1: equ COLOR_ATTR_FULLER+COLOR_SCREEN_WIDTH
COLOR_ATTR_ZXNEXT_JOY2: equ COLOR_ATTR_ZXNEXT_JOY1+9


; For accessing the ZXNext joystick mode register
TBBLUE_REG_SELECT:  equ 243Bh
TBBLUE_REG_ACCESS:  equ 253Bh

; Expansion Bus Enable Register
REG_EXPANSION_PORT_ENABLE:  equ 80h
REG_INTERNAL_PORT_DECODING_B07: equ 82h
REG_EXPANSION_BUS_DECODING_B07: equ 86h
REG_EXPANSION_BUS_IO_PROPAGATE:   equ 8Ah

;===========================================================================
; Macros.
;===========================================================================

; For "out-of-bounds" checks.
MEMGUARD:	macro
    defs 1 ; WPMEM
    endm


; Sets a Next Feature Control Register with A.
; Parameters:
;	register = The Next Feature Control Register to set.
NEXTRA:	macro	register
	defb 0xED, 0x92
	defb register
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


; Reads a Next Feature Control Register .
; Parameters:
;	register = The Next Feature Control Register to read.
; Returns:
;	A = The value for the register.
READNREG:   macro   register
    push bc
    ld bc,TBBLUE_REG_SELECT
    ld a,register
    out (c),a
    ld bc,TBBLUE_REG_ACCESS
    in a,(c)
    pop bc 
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

    ; Clear screen
    ;call 0D6Bh

    ; Print text.
    ld hl,MAIN_TEXT
    call print


    ; Check for ZX Next
    call check_for_z80n
    jr nz,main_loop

    ; Print additional text
    ld hl,ZXNEXT_TEXT
    call print

    ; Disable expansion port
    READNREG REG_EXPANSION_PORT_ENABLE
    or 80h  ; Enable expansion port
    NEXTRA REG_EXPANSION_PORT_ENABLE 

    ; Enable internal and expansion bus decoding
    READNREG REG_EXPANSION_BUS_DECODING_B07
    or 11000000b
    NEXTRA REG_EXPANSION_BUS_DECODING_B07 
    READNREG REG_INTERNAL_PORT_DECODING_B07
    or 11000000b
    NEXTRA REG_INTERNAL_PORT_DECODING_B07 
    READNREG REG_EXPANSION_BUS_IO_PROPAGATE
    or 00000001b
    NEXTRA REG_EXPANSION_BUS_IO_PROPAGATE 



; The main loop:
; - Check joystick input
; - Visualize it
main_loop:
    ; Make the loop slower.
    halt
    
    ; Get joystick value. Interface II, joystick 1
    ld bc,PORT_IF2_JOY_1
    ld hl,COLOR_ATTR_IF2_JOY1
    call visualize_joystick_inport

    ; Get joystick value. Interface II, joystick 2
    ld bc,PORT_IF2_JOY_2
    ld hl,COLOR_ATTR_IF2_JOY2
    call visualize_joystick_inport

    ; Get joystick value. Kempston, joystick 0.
    ld bc,PORT_KEMPSTON_JOY1
    ld hl,COLOR_ATTR_KEMPSTON_JOY1
    call visualize_joystick_inport

    ; Get joystick value. Kempston, joystick 1.
    ld bc,PORT_KEMPSTON_JOY2
    ld hl,COLOR_ATTR_KEMPSTON_JOY2
    call visualize_joystick_inport

    ; Get joystick value. Fuller.
    ld bc,PORT_FULLER
    ld hl,COLOR_ATTR_FULLER
    call visualize_joystick_inport



    ; Check for ZX Next
    call check_for_z80n
    jr nz,main_loop

    ; Check for keypress to change the joystick mode
    ld bc,KEYB_ASDFG
    in a,(c)
    ; Check if value changed
    ld hl,prev_keyb
    cp (hl)
    jr z,no_key_pressed

    ; Changed, store
    ld (hl),a
    ld e,a

    ; Key was pressed

    ; Read configuration of ZX Next joystick
    READNREG REG_PERIPHERAL_1
    
    ; Evaluate key
    bit 0,e ; "A"
    jr nz,key1_not_pressed

    ; "A" was pressed
    add 01000000b
    jr nc,j1_no_overflw
    ; Handle overflow
    xor 00001000b
j1_no_overflw:
    ; Set new value
    NEXTRA REG_PERIPHERAL_1

key1_not_pressed:
    ; Evaluate key
    bit 1,e ; "S"
    jr nz,key_exp_not_pressed

    ; "S" was pressed
    ld l,a
    and 10111111b
    add 00010000b
    ld h,a
    ; Restore
    res 6,a
    bit 6,l
    jr z,restore_0
    set 6,a
restore_0:
    bit 6,h
    jr z,j2_no_overflw
    ; Handle overflow
    xor 00000010b
j2_no_overflw:
    ; Set new value
    NEXTRA REG_PERIPHERAL_1



key_exp_not_pressed:
    ; Evaluate key
    bit 4,e ; "G"
    jr nz,no_key_pressed

    ; Key to toggle expansion port was pressed
    call toggle_expansion_port


no_key_pressed:
    ; Read configuration of ZX Next joystick
    ld bc,TBBLUE_REG_SELECT
    ld a,REG_PERIPHERAL_1
    out (c),a
    ld bc,TBBLUE_REG_ACCESS
    in a,(c)
    
    ; Check if value changed
    ld hl,prev_zxn_joy_config
    cp (hl)
    jp z,print_expansion_port

    ; Changed, store
    ld (hl),a


    push af
    push af

    ; Print defaults for the kempston joysticks
    ld hl,KEMPSTON_JOY1_POS
    call print 
    ld hl,KEMPSTON_NORMAL_JOY_TEXT
    call print
    ld hl,KEMPSTON_JOY2_POS
    call print 
    ld hl,KEMPSTON_NORMAL_JOY_TEXT
    call print

    ; Print joystick 1
    ld hl,JOY1_MODE_TEXT
    call print

    ; Evaluate joystick 1
    pop af 
    and 11001000b ; Mask out all other registers
    ld l,a
    sra l
    rlca
    rlca
    or l
    and 0111b
    call print_zxn_joy_config

    ; Print joystick 2
    ld hl,JOY2_MODE_TEXT
    call print

    ; Evaluate joystick 2
    pop af 
    and 00110010b ; Mask out all other registers
    ld l,a
    sla l
    rlca
    rlca
    rlca
    rlca
    or l
    and 0111b
    call print_zxn_joy_config

print_expansion_port:
    ; Print expansion board configuration
    ld hl,EXPANSION_TEXT
    call print
    ; Show the current state
    READNREG REG_EXPANSION_PORT_ENABLE
    bit 7,a  ; Check for expansion port
    ld hl,DISABLED_TEXT
    jr z,exp_disabled
    ld hl,ENABLED_TEXT
exp_disabled:
    call print

    jp main_loop


; Check for Z80N (ZX Next) CPU, i.e. check if extended opcodes are available.
; Returns: Z is set if it is a Z80N
check_for_z80n:
    ld e,2
    ld d,e
    MUL_D_E
    ld a,e
    cp 4
    ret


; Visualizes the Joystick Input.
; IN: BC = Port to read (Joystick input)
;     HL = Pointer to start address in color attributes screen.
visualize_joystick_inport:
    in a,(c)
visualize_joystick_a:   ; For unit tests
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


; Prints the ZX Next joystick configuration of one joystick.
; A has to contain the config. I.e. only the least 3 bits should be set.
print_zxn_joy_config:
    cp 0
    jr nz,no_if2_joy2
    ; It is IF2 joystick 2
    ld hl,IF2_TEXT
    ld de,JOY2_TEXT
    jr zxn_joy_print

no_if2_joy2:
    cp 1
    jr nz,no_kempston_joy1
    ; It is Kempston joystick 1
    ld hl,KEMPSTON_TEXT
    ld de,JOY1_TEXT
    jr zxn_joy_print

no_kempston_joy1:
    cp 2
    jr nz,no_cursor
    ; It is Cursor joystick
    ld hl,CURSOR_TEXT
    ld de,JOYSTICK_TEXT
    jr zxn_joy_print

no_cursor:
    cp 3
    jr nz,no_if2_joy1
     ; It is IF2 joystick 1
    ld hl,IF2_TEXT
    ld de,JOY1_TEXT
    jr zxn_joy_print

no_if2_joy1:
    cp 4
    jr nz,no_kempston_joy2
    ; It is Kempston joystick 2
    ld hl,KEMPSTON_TEXT
    ld de,JOY2_TEXT
    jr zxn_joy_print

no_kempston_joy2:
    cp 5
    jr nz,no_md1
    ; It is MD (MegaDrive) joystick 1
    ld bc,KEMPSTON_JOY1_POS
    ld ix,KEMPSTON_MD_JOY_TEXT
    ld hl,MD_TEXT
    ld de,JOY1_TEXT
    jr zxn_joy_print_kempston_md

no_md1:
    cp 6
    jr nz,no_md2
    ; It is MD (MegaDrive) joystick 2
    ld bc,KEMPSTON_JOY2_POS
    ld ix,KEMPSTON_MD_JOY_TEXT
    ld hl,MD_TEXT
    ld de,JOY2_TEXT
    jr zxn_joy_print_kempston_md

no_md2:
    ld hl,UNDEFINED_TEXT
    call print
    ret  ; Print nothing

zxn_joy_print_kempston_md:
    push ix 
    push bc 
    call zxn_joy_print
    pop hl  ; bc
    call print 
    pop hl  ; ix
    call print 
    ret 

zxn_joy_print:
    push de
    call print 
    pop hl
    call print 
    ret 
    


;  Toggle enabling of the expansion port.
toggle_expansion_port:
    ; Get current value
    READNREG REG_EXPANSION_PORT_ENABLE
    xor 80h  ; Toggle
    ; Write
    NEXTRA REG_EXPANSION_PORT_ENABLE
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

    ; Next
    inc hl
    jr print



;===========================================================================
; Data.
;===========================================================================
prev_zxn_joy_config:    defb 0xFF  ;    Is an invalid value
prev_keyb:    defb 0x80



;===========================================================================
; Constant data.
;===========================================================================

; Texts.

MAIN_TEXT:
    defb AT, 0, 0
    defb 'Joystick Tester for ZX Spectrum and ZX Next. Version 1.2.'
    defb AT, 3, 0
    defb 'White=1, Red=0, Black=Not Avail.'
    defb AT, 5, 15
    defb 'Joy1:    Joy2:'
    defb AT, 6, 15
    defb '76543210 76543210'
    defb AT, 7, 0
    defb 'Interface II:  ???LRDUF ???FUDRL'    
    defb AT, 8, 0
    defb 'Kempston:'
    defb AT, 9, 0
    defb 'Fuller:        F???RLDU'
    defb EOS

KEMPSTON_JOY1_POS:
    defb AT, 8, 15, EOS 
KEMPSTON_JOY2_POS:
    defb AT, 8, 24, EOS 
KEMPSTON_NORMAL_JOY_TEXT:
    defb '???FUDLR'
    defb EOS
KEMPSTON_MD_JOY_TEXT:
    defb 'SACBUDLR'
    defb EOS


ZXNEXT_TEXT:
    defb AT, 12, 0
    defb 'ZXNEXT Joystick Modes:'
    defb AT, 17, 0
    defb 'Press a key to change mode:'
    defb AT, 18, 0
    defb 'A=Change Joystick 1 mode'
    defb AT, 19, 0
    defb 'S=Change Joystick 2 mode'
    defb AT, 20, 0
    defb 'G=Toggle expansion port mode'
    defb EOS

JOY1_MODE_TEXT:
    defb AT, 13, 0
    defb 'Joy1:                           '
    defb AT, 13, 6
    defb EOS

JOY2_MODE_TEXT:
    defb AT, 14, 0
    defb 'Joy2:                           '
    defb AT, 14, 6
    defb EOS
    
IF2_TEXT:
    defb 'Interface II ', EOS

KEMPSTON_TEXT:
    defb 'Kempston ', EOS

CURSOR_TEXT:
    defb 'Cursor ', EOS

MD_TEXT:
    defb 'MD mapped to Kempston ', EOS

JOY1_TEXT:  defb 'JOY1', EOS
JOY2_TEXT:  defb 'JOY2', EOS
JOYSTICK_TEXT:  defb 'Joystick', EOS

UNDEFINED_TEXT: defb 'Undefined', EOS


EXPANSION_TEXT: defb AT, 15, 0
    defb 'Expansion port: ', EOS

ENABLED_TEXT:   defb 'Enabled ', EOS
DISABLED_TEXT:  defb 'Disabled', EOS


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


 ;===========================================================================
; UNIT TESTS
;===========================================================================


include "unit_tests.inc"


if 01

UT_visualize_joystick_1:
    ld hl,COLOR_ATTR_ZXNEXT_JOY1
    ld a,10101010b
    call visualize_joystick_a
    
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1 COLOR_BIT_NOT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+1 COLOR_BIT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+2 COLOR_BIT_NOT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+3 COLOR_BIT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+4 COLOR_BIT_NOT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+5 COLOR_BIT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+6 COLOR_BIT_NOT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+7 COLOR_BIT_SET
 UT_END

UT_visualize_joystick_2:
    ld hl,COLOR_ATTR_ZXNEXT_JOY1
    ld a,01010101b
    call visualize_joystick_a
    
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1 COLOR_BIT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+1 COLOR_BIT_NOT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+2 COLOR_BIT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+3 COLOR_BIT_NOT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+4 COLOR_BIT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+5 COLOR_BIT_NOT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+6 COLOR_BIT_SET
    TEST_MEMORY_BYTE COLOR_ATTR_ZXNEXT_JOY1+7 COLOR_BIT_NOT_SET
 UT_END


UNITTEST_INITIALIZE
    ; Start of unit test initialization.
    ret

endif 
    