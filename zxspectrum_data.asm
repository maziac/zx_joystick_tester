; The screen and system variables data area of a ZX Spectrum.


; Screen size without color attributes.
SCREEN_SIZE:	equ 0x1800

; Pixel Screen (0x4000 to 0x57FF)
DS_SCREEN:
    defs SCREEN_SIZE
SCREEN_END:


; Color Screen (0x5800 to 0x5AFF)
DS_SCREEN_COLOR:
    defs 0x0300
DS_SCREEN_COLOR_END:

; Start of printer buffer 0x5B00 - 0x5BFF
LBL_PRINTER_BUFFER:
    defs 0x0100

; Start of system variables 0x5C00 - 0x5CBF
LBL_SYSTEM_VARIABLES: ;WPMEMx ,0c0
	defb 0ffh		;5c00	ff 	.
	defb 000h		;5c01	00 	.
	defb 01ah		;5c02	1a 	.
	defb 030h		;5c03	30 	0
	defb 0ffh		;5c04	ff 	.
	defb 000h		;5c05	00 	.
	defb 023h		;5c06	23 	#
	defb 031h		;5c07	31 	1
	defb 000h		;5c08	00 	.
	defb 023h		;5c09	23 	#
	defb 005h		;5c0a	05 	.
	defb 000h		;5c0b	00 	.
	defb 000h		;5c0c	00 	.po
	defb 000h		;5c0d	00 	.
	defb 016h		;5c0e	16 	.
	defb 013h		;5c0f	13 	.
	defb 001h		;5c10	01 	.
	defb 000h		;5c11	00 	.
	defb 006h		;5c12	06 	.
	defb 000h		;5c13	00 	.
	defb 00bh		;5c14	0b 	.
	defb 000h		;5c15	00 	.
	defb 001h		;5c16	01 	.
	defb 000h		;5c17	00 	.
	defb 001h		;5c18	01 	.
	defb 000h		;5c19	00 	.
	defb 006h		;5c1a	06 	.
	defb 000h		;5c1b	00 	.
	defb 010h		;5c1c	10 	.
	defb 000h		;5c1d	00 	.
	defb 000h		;5c1e	00 	.
	defb 000h		;5c1f	00 	.
	defb 000h		;5c20	00 	.
	defb 000h		;5c21	00 	.
	defb 000h		;5c22	00 	.
	defb 000h		;5c23	00 	.
	defb 000h		;5c24	00 	.
	defb 000h		;5c25	00 	.
	defb 000h		;5c26	00 	.
	defb 000h		;5c27	00 	.
	defb 000h		;5c28	00 	.
	defb 000h		;5c29	00 	.
	defb 000h		;5c2a	00 	.
	defb 000h		;5c2b	00 	.
	defb 000h		;5c2c	00 	.
	defb 000h		;5c2d	00 	.
	defb 000h		;5c2e	00 	.
	defb 000h		;5c2f	00 	.
	defb 000h		;5c30	00 	.
	defb 000h		;5c31	00 	.
	defb 000h		;5c32	00 	.
	defb 000h		;5c33	00 	.
	defb 000h		;5c34	00 	.
	defb 000h		;5c35	00 	.
	defb 000h		;5c36	00 	.
	defb 03ch		;5c37	3c 	<
	defb 040h		;5c38	40 	@
	defb 000h		;5c39	00 	.
	defb 0ffh		;5c3a	ff 	.
	defb 0edh		;5c3b	ed 	.
	defb 000h		;5c3c	00 	.
	defb 0bdh		;5c3d	bd 	.
	defb 05dh		;5c3e	5d 	]
	defb 000h		;5c3f	00 	.
	defb 000h		;5c40	00 	.
	defb 000h		;5c41	00 	.

; Line to be jumped to.
NEWPPC:
	defw 0
	;defb 00ah		;5c42	0a 	.
	;defb 000h		;5c43	00 	.

; Statement number in line to be jumped to. Poking first NEWPPC
; and then NSPPC forces a jump to a specified statement in a line.
NSPPC:
	defb 255
	;defb 0ffh		;5c44	ff 	.

;Line number of statement currently being executed.
PPC:
	defw 10
	;defb 00ah		;5c45	0a 	.
	;defb 000h		;5c46	00 	.

; Number within line of statement currently being executed.
SUBPPC:
	defb 1		;5c47	02 	.

; Border colour multiplied by 8; also contains the attributes normally
; used for the lower half of the screen.
BORDCR:
	defb 007h		;5c48	07 	.

; Number of current line (with program cursor).
E_PPC:
	defw 10
	;defb 000h		;5c49	00 	.
	;defb 000h		;5c4a	00 	.

; Address of variables.
VARS:
	defw 05cedh	; = 23789. Ends with 80h just before E_LINE
	;defb 0edh		;5c4b	ed 	.
	;defb 05ch		;5c4c	5c 	\

	defb 000h		;5c4d	00 	.
	defb 000h		;5c4e	00 	.
	defb 0b6h		;5c4f	b6 	.
	defb 05ch		;5c50	5c 	\
	defb 0bbh		;5c51	bb 	.
	defb 05ch		;5c52	5c 	\

; Address of BASIC program.
PROG:
	defw 05ccbh		; = 23755
	;defb 0cbh		;5c53	cb 	.
	;defb 05ch		;5c54	5c 	\

; Address of next line in program.
NXTLIN:
	defw 05cf7h
	;defb 0edh		;5c55	ed 	.
	;defb 05ch		;5c56	5c 	\

	defb 0cah		;5c57	ca 	.
	defb 05ch		;5c58	5c 	\

; Address of command being typed in. PROG < VARS < E_LINE
E_LINE:
	defw 05ceeh
	;defb 0eeh		;5c59	ee 	.
	;defb 05ch		;5c5a	5c 	\

	defb 0f1h		;5c5b	f1 	.
	defb 05ch		;5c5c	5c 	\
	defb 0ech		;5c5d	ec 	.
	defb 05ch		;5c5e	5c 	\
	defb 026h		;5c5f	26 	&
	defb 05dh		;5c60	5d 	]
	defb 0f3h		;5c61	f3 	.
	defb 05ch		;5c62	5c 	\
	defb 0f3h		;5c63	f3 	.
	defb 05ch		;5c64	5c 	\
	defb 0f3h		;5c65	f3 	.
	defb 05ch		;5c66	5c 	\
	defb 02dh		;5c67	2d 	-
	defb 092h		;5c68	92 	.
	defb 05ch		;5c69	5c 	\
	defb 008h		;5c6a	08 	.
	defb 002h		;5c6b	02 	.
	defb 000h		;5c6c	00 	.
	defb 000h		;5c6d	00 	.
	defb 000h		;5c6e	00 	.
	defb 000h		;5c6f	00 	.
	defb 000h		;5c70	00 	.
	defb 000h		;5c71	00 	.
	defb 000h		;5c72	00 	.
	defb 000h		;5c73	00 	.
	defb 09dh		;5c74	9d 	.
	defb 01ah		;5c75	1a 	.

VAR_RAND_LAST:
	defb 050h		;5c76	50 	P
	defb 0e6h		;5c77	e6 	.
	defb 0e7h		;5c78	e7 	.
	defb 00eh		;5c79	0e 	.
	defb 000h		;5c7a	00 	.
	defb 058h		;5c7b	58 	X
	defb 0ffh		;5c7c	ff 	.
	defb 000h		;5c7d	00 	.
	defb 000h		;5c7e	00 	.
	defb 021h		;5c7f	21 	!
	defb 000h		;5c80	00 	.
	defb 05bh		;5c81	5b 	[
	defb 021h		;5c82	21 	!
	defb 017h		;5c83	17 	.
	defb 073h		;5c84	73 	s
	defb 050h		;5c85	50 	P
	defb 0e0h		;5c86	e0 	.
	defb 050h		;5c87	50 	P
	defb 00eh		;5c88	0e 	.
	defb 005h		;5c89	05 	.
	defb 021h		;5c8a	21 	!
	defb 017h		;5c8b	17 	.
	defb 003h		;5c8c	03 	.
	defb 047h		;5c8d	47 	G
	defb 000h		;5c8e	00 	.
	defb 047h		;5c8f	47 	G
	defb 000h		;5c90	00 	.
	defb 000h		;5c91	00 	.
	defb 000h		;5c92	00 	.
	defb 000h		;5c93	00 	.
	defb 000h		;5c94	00 	.
	defb 000h		;5c95	00 	.
	defb 000h		;5c96	00 	.
	defb 000h		;5c97	00 	.
	defb 000h		;5c98	00 	.
	defb 000h		;5c99	00 	.
	defb 000h		;5c9a	00 	.
	defb 000h		;5c9b	00 	.
	defb 000h		;5c9c	00 	.
	defb 000h		;5c9d	00 	.
	defb 000h		;5c9e	00 	.
	defb 000h		;5c9f	00 	.
	defb 000h		;5ca0	00 	.
	defb 000h		;5ca1	00 	.
	defb 000h		;5ca2	00 	.
	defb 000h		;5ca3	00 	.
	defb 000h		;5ca4	00 	.
	defb 000h		;5ca5	00 	.
	defb 000h		;5ca6	00 	.
	defb 000h		;5ca7	00 	.
	defb 000h		;5ca8	00 	.
	defb 000h		;5ca9	00 	.
	defb 000h		;5caa	00 	.
	defb 000h		;5cab	00 	.
	defb 000h		;5cac	00 	.
	defb 000h		;5cad	00 	.
	defb 000h		;5cae	00 	.
	defb 000h		;5caf	00 	.
	defb 000h		;5cb0	00 	.
	defb 000h		;5cb1	00 	.
	defb 0c0h		;5cb2	c0 	.
	defb 05dh		;5cb3	5d 	]
	defb 0ffh		;5cb4	ff 	.
	defb 0ffh		;5cb5	ff 	.
	defb 0f4h		;5cb6	f4 	.
	defb 009h		;5cb7	09 	.
	defb 0a8h		;5cb8	a8 	.
	defb 010h		;5cb9	10 	.
	defb 04bh		;5cba	4b 	K
	defb 0f4h		;5cbb	f4 	.
	defb 009h		;5cbc	09 	.
	defb 0c4h		;5cbd	c4 	.
	defb 015h		;5cbe	15 	.
	defb 053h		;5cbf	53 	S
; End of system variables


; Reserved 0x5CC0 - 0x5CCA
	defb 081h		;5cc0	81 	.
	defb 00fh		;5cc1	0f 	.
	defb 0c4h		;5cc2	c4 	.
	defb 015h		;5cc3	15 	.
	defb 052h		;5cc4	52 	R
	defb 0f4h		;5cc5	f4 	.
	defb 009h		;5cc6	09 	.
	defb 0c4h		;5cc7	c4 	.
	defb 015h		;5cc8	15 	.
	defb 050h		;5cc9	50 	P
	defb 080h		;5cca	80 	.
; end of Reserved area
END_RESERVED_AREA:
