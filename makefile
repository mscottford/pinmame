TARGET = pinmame
MAMEOS = ruby

# extension for executables
EXE = .exe

# CPU core include paths
VPATH=src $(wildcard src/cpu/*)

# compiler, linker and utilities
AR = @ar
CC = @gcc
LD = @gcc
ASM = @nasm
ASMFLAGS = -f coff
MD = -mkdir
RM = @rm -f

PREFIX =

# build the targets in different object dirs, since mess changes
# some structures and thus they can't be linked against each other.
OBJ = obj/gcc/$(NAME)

EMULATOR = $(NAME)$(EXE)

DEFS = -DX86_ASM -DLSB_FIRST -DINLINE="static __inline__" -Dasm=__asm__

CFLAGS = -std=gnu99 -Isrc -Isrc/includes -Isrc/$(MAMEOS) -I$(OBJ)/cpu/m68000 -Isrc/cpu/m68000

CFLAGS += -DNDEBUG \
	$(ARCH) -O3 -fomit-frame-pointer -fstrict-aliasing \
	-Wall -Wno-sign-compare -Wunused \
	-Wpointer-arith -Wbad-function-cast -Wcast-align -Waggregate-return \
	-Wshadow -Wstrict-prototypes -Wundef \
	-Wformat-security -Wwrite-strings \
	-Wdisabled-optimization \

CFLAGSPEDANTIC = $(CFLAGS) -pedantic

LDFLAGS = -s

MAPFLAGS =

# platform .mak files will want to add to this
LIBS = -lz

OBJDIRS = obj obj/gcc $(OBJ) $(OBJ)/cpu $(OBJ)/sound $(OBJ)/$(MAMEOS) \
	$(OBJ)/machine $(OBJ)/vidhrdw
OBJDIRS += $(OBJ)/drivers $(OBJ)/sndhrdw


all:	maketree $(EMULATOR) extra

# include the various .mak files
include src/core.mak
include src/$(TARGET).mak
include src/rules.mak
include src/$(MAMEOS)/$(MAMEOS).mak

DBGDEFS =
DBGOBJS =


extra:	$(TOOLS) $(TEXTS)

# combine the various definitions to one
CDEFS = $(DEFS) $(COREDEFS) $(CPUDEFS) $(SOUNDDEFS) $(ASMDEFS) $(DBGDEFS)

# primary target
$(EMULATOR): $(OBJS) $(COREOBJS) $(OSOBJS) $(DRVLIBS)
# always recompile the version string
	$(CC) $(CDEFS) $(CFLAGS) -c src/version.c -o $(OBJ)/version.o
	@echo Linking $@...
	$(LD) $(LDFLAGS) $(OBJS) $(COREOBJS) $(OSOBJS) $(LIBS) $(DRVLIBS) -o $@ $(MAPFLAGS)

romcmp$(EXE): $(OBJ)/romcmp.o $(OBJ)/unzip.o
	@echo Linking $@...
	$(LD) $(LDFLAGS) $^ -lz -o $@

hdcomp$(EXE): $(OBJ)/hdcomp.o $(OBJ)/harddisk.o $(OBJ)/md5.o
	@echo Linking $@...
	$(LD) $(LDFLAGS) $^ -lz -o $@

xml2info$(EXE): src/xml2info/xml2info.c
	@echo Compiling $@...
	$(CC) -O1 -o xml2info$(EXE) $<

# for Windows at least, we can't compile OS-specific code with -pedantic
$(OBJ)/$(MAMEOS)/%.o: src/$(MAMEOS)/%.c
	@echo Compiling $<...
	$(CC) $(CDEFS) $(CFLAGS) -c $< -o $@

$(OBJ)/%.o: src/%.c
	@echo Compiling $<...
	$(CC) $(CDEFS) $(CFLAGSPEDANTIC) -c $< -o $@

# compile generated C files for the 68000 emulator
$(M68000_GENERATED_OBJS): $(OBJ)/cpu/m68000/m68kmake$(EXE)
	@echo Compiling $(subst .o,.c,$@)...
	$(CC) $(CDEFS) $(CFLAGSPEDANTIC) -c $*.c -o $@

# additional rule, because m68kcpu.c includes the generated m68kops.h :-/
$(OBJ)/cpu/m68000/m68kcpu.o: $(OBJ)/cpu/m68000/m68kmake$(EXE)

# generate C source files for the 68000 emulator
$(OBJ)/cpu/m68000/m68kmake$(EXE): src/cpu/m68000/m68kmake.c
	@echo M68K make $<...
	$(CC) $(CDEFS) $(CFLAGSPEDANTIC) -DDOS -o $(OBJ)/cpu/m68000/m68kmake$(EXE) $<
	@echo Generating M68K source files...
	$(OBJ)/cpu/m68000/m68kmake$(EXE) $(OBJ)/cpu/m68000 src/cpu/m68000/m68k_in.c

# generate asm source files for the 68000/68020 emulators
$(OBJ)/cpu/m68000/68000.asm:  src/cpu/m68000/make68k.c
	@echo Compiling $<...
	$(CC) $(CDEFS) $(CFLAGSPEDANTIC) -O0 -DDOS -o $(OBJ)/cpu/m68000/make68k$(EXE) $<
	@echo Generating $@...
	@$(OBJ)/cpu/m68000/make68k$(EXE) $@ $(OBJ)/cpu/m68000/68000tab.asm 00

$(OBJ)/cpu/m68000/68020.asm:  src/cpu/m68000/make68k.c
	@echo Compiling $<...
	$(CC) $(CDEFS) $(CFLAGSPEDANTIC) -O0 -DDOS -o $(OBJ)/cpu/m68000/make68k$(EXE) $<
	@echo Generating $@...
	@$(OBJ)/cpu/m68000/make68k$(EXE) $@ $(OBJ)/cpu/m68000/68020tab.asm 20

# generated asm files for the 68000 emulator
$(OBJ)/cpu/m68000/68000.o:  $(OBJ)/cpu/m68000/68000.asm
	@echo Assembling $<...
	$(ASM) -o $@ $(ASMFLAGS) $(subst -D,-d,$(ASMDEFS)) $<

$(OBJ)/cpu/m68000/68020.o:  $(OBJ)/cpu/m68000/68020.asm
	@echo Assembling $<...
	$(ASM) -o $@ $(ASMFLAGS) $(subst -D,-d,$(ASMDEFS)) $<

$(OBJ)/%.a:
	@echo Archiving $@...
	$(RM) $@
	$(AR) cr $@ $^

makedir:
	@echo make makedir is no longer necessary, just type make

$(sort $(OBJDIRS)):
	$(MD) $@

maketree: $(sort $(OBJDIRS))

clean:
	@echo Deleting object tree $(OBJ)...
	$(RM) -r $(OBJ)
	@echo Deleting $(EMULATOR)...
	$(RM) $(EMULATOR)

clean68k:
	@echo Deleting 68k files...
	$(RM) -r $(OBJ)/cpuintrf.o
	$(RM) -r $(OBJ)/drivers/cps2.o
	$(RM) -r $(OBJ)/cpu/m68000

check: $(EMULATOR) xml2info$(EXE)
	./$(EMULATOR) -listxml > $(NAME).xml
	./xml2info < $(NAME).xml > $(NAME).lst
	./xmllint --valid --noout $(NAME).xml


