# Makefile for the ZX Joystick Tester.
#


PROJ = joytester
ASM = "/Volumes/Macintosh HD 2/Projects/zesarux/z80asm/z80asm"	# Path to the Z80 Assembler, http://savannah.nongnu.org/projects/z80asm/
#CC = "/Volumes/Macintosh HD 2/Projects/zesarux/sdcc/bin/sdcc"	# Path to compiler, http://sdcc.sourceforge.net
#SED = gsed
SNA_FILE = $(PROJ).sna
SNA_HDR = $(PROJ).snahdr
SNA_SYMS = $(PROJ).symbols
SNA_BLOCK = $(PROJ).blocks
SNA_OBJ = $(PROJ).re.obj
SNA_ASM = $(PROJ).re.asm
TAP_FILE = $(PROJ).tap
TMP_FILE = $(PROJ).tmp
MAIN_ASM = joytester.asm
MAIN_OBJ = joytester.obj
#MAIN48K_OBJ = main48k.obj
ASM_FILES = $(MAIN_ASM) zxspectrum_data.asm
LABELS_OUT = $(PROJ).labels
# The assembler output listing file:
LIST_OUT = $(PROJ).list


#default:	sna tap
default:	sna


clean:
	-rm -f $(EXT_OBJ) $(EXT_SNA) $(SNA_HDR)


$(MAIN_OBJ):	$(ASM_FILES) Makefile
	$(ASM) --input=$(MAIN_ASM) --output=$(MAIN_OBJ) --label=$(LABELS_OUT) --list=$(LIST_OUT).tmp
	# Format (align) assembler listing
	cat $(LIST_OUT).tmp | unexpand -t 4 | expand -t 5 > $(LIST_OUT)  # Expands tabs to spaces. Original tab size is 4 (unexpand). Expanding to 5 and 8 does work.


sna:	$(MAIN_OBJ) $(SNA_HDR)
	cat $(SNA_HDR) $(MAIN_OBJ) > $(SNA_FILE)

tap:	$(MAIN_OBJ)
	# 24999 is the top of the ZX Basic program.
	# The code is loaded at 25000.
	# 25000-16384 (start of main.obj) = 8616.
	# 65015 (0xFDF7) is the start of the assembler program.
	dd skip=8616 if=$< of=$(TMP_FILE) bs=1
	code2tap swarrior -code $(TMP_FILE) -start 25000 -exec 65015

