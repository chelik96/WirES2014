CROSS_GCC_VER=4.3.2
TOOLCHAIN_PREFIX=/cygdrive/d/arm-elf-nothumb-4.3.2
TOOLCHAIN_PATH=$(TOOLCHAIN_PREFIX)/bin:/bin
CROSS_LIBGCC_PATH=$(TOOLCHAIN_PREFIX)/lib/gcc/arm-elf/$(CROSS_GCC_VER)
CROSS_LIBC_PATH=$(TOOLCHAIN_PREFIX)/arm-elf/lib

APP_NAME = ex
TOOL_PREFIX=arm-elf-
COPT= -march=armv4 -fomit-frame-pointer -ffast-math -O2 -fno-zero-initialized-in-bss
#-finline-functions -fregmove -ffast-math -fno-math-errno -fno-trapping-math -frename-registers 

# linker option --fix-v4bx-interworking may be used to get plain arm4 output by substituting thumb bx instructions
$(APP_NAME): $(APP_NAME).o startup.o armfpga.ld
	PATH=$(TOOLCHAIN_PATH) $(TOOL_PREFIX)ld -T armfpga.ld -o $(APP_NAME) startup.o $(APP_NAME).o -L$(CROSS_LIBGCC_PATH) -L$(CROSS_LIBC_PATH) -lgcc -lc 
	PATH=$(TOOLCHAIN_PATH) $(TOOL_PREFIX)objdump -d $(APP_NAME) > $(APP_NAME).dmp

startup.o: startup.s
	PATH=$(TOOLCHAIN_PATH) $(TOOL_PREFIX)as -o startup.o startup.s

$(APP_NAME).o: $(APP_NAME).s
	PATH=$(TOOLCHAIN_PATH) $(TOOL_PREFIX)as -o $(APP_NAME).o $(APP_NAME).s

$(APP_NAME).s: $(APP_NAME).c Makefile ex.h
	PATH=$(TOOLCHAIN_PATH) $(TOOL_PREFIX)gcc $(COPT) -S -o $(APP_NAME).s $(APP_NAME).c 

clean:
	/bin/rm -f $(APP_NAME).s $(APP_NAME).o $(APP_NAME) startup.o