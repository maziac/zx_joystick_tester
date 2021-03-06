# Makefile for the ZX Joystick Tester.
#


PROJ = joytester
ASM = "/Volumes/SDDPCIE2TB/Projects/Z80/z80asm/z80asm"	# Path to the Z80 Assembler, http://savannah.nongnu.org/projects/z80asm/
#CC = ".../bin/sdcc"	# Path to compiler, http://sdcc.sourceforge.net
CODE2TAP="/Volumes/SDDPCIE2TB/Projects/Z80/zx-tools/zx-code2tap/bin/zxcode2tap"	# Path to the tap-converter, https://github.com/maziac/zx-code2tap
#SED = gsed
SNA_FILE = $(PROJ).sna
SNA_HDR = $(PROJ).snahdr
SNA_SYMS = $(PROJ).symbols
SNA_BLOCK = $(PROJ).blocks
SNA_OBJ = $(PROJ).re.obj
SNA_ASM = $(PROJ).re.asm
TMP_FILE = $(PROJ).tmp
TAP_PRG_NAME = joytester
TAP_FILE = $(PROJ).tap
MAIN_ASM = joytester.asm
MAIN_OBJ = joytester.obj
#MAIN48K_OBJ = main48k.obj
ASM_FILES = $(MAIN_ASM) zxspectrum_data.asm unit_tests.inc
LABELS_OUT = $(PROJ).labels
# The assembler output listing file:
LIST_OUT = $(PROJ).list


#default:	sna tap
#default:	sna
default:	tap sna

clean:
	-rm -f $(EXT_OBJ) $(EXT_SNA) $(SNA_HDR)


$(MAIN_OBJ):	$(ASM_FILES) Makefile
	$(ASM) --input=$(MAIN_ASM) --output=$(MAIN_OBJ) --label=$(LABELS_OUT) --list=$(LIST_OUT).tmp
	# Format (align) assembler listing
	cat $(LIST_OUT).tmp | unexpand -t 4 | expand -t 5 > $(LIST_OUT)  # Expands tabs to spaces. Original tab size is 4 (unexpand). Expanding to 5 and 8 does work.


sna:	$(MAIN_OBJ) $(SNA_HDR)
	# 0x7000-0x4000
	cat /dev/zero | head -c 12288 > $(TMP_FILE)
	cat	$(SNA_HDR) $(TMP_FILE) $(MAIN_OBJ) /dev/zero | head -c 49179 > $(SNA_FILE)
	rm $(TMP_FILE)


tap:	$(MAIN_OBJ)
	# 24999 (0x61A7) is the top of the ZX Basic program.
	# The code is loaded and executed at 0x7000.
	$(CODE2TAP) $(TAP_PRG_NAME) -code $(MAIN_OBJ) -start 0x7000 -exec 0x7000

