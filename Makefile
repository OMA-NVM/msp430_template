CROSS_COMPILER=./msp430-gcc/bin/msp430-elf
IR_TOOLCHAIN=./../llvm-project/build/bin
MSP_FLASHER_PATH=./MSPFlasher_1.3.20
MSP_INCLUDES=msp430-gcc/include
MSP_DEVICE=msp430fr5994

ASMFLAGS=-Wall -Werror -Og -gdwarf-4 -gstrict-dwarf -Wall -mcode-region=none -mdata-region=none -mlarge -Wl,--gc-sections -Wl,--start-group -lgcc -lc -Wl,--end-group -I$(MSP_INCLUDES) -I.

CCFLAGS=-D__MSP430F5529__ -Og -S -gdwarf-4 -gstrict-dwarf -fno-dwarf2-cfi-asm -emit-llvm --target=msp430 -Wall -I$(MSP_INCLUDES) -I.

BCFLAGS=-march=msp430x

LLCFLAGS=--dwarf-version=4 --strict-dwarf -mtriple=msp430 -mcpu=msp430x

LDFLAGS=-T $(MSP_INCLUDES)/$(MSP_DEVICE).ld -L $(MSP_INCLUDES) -Og -g -gdwarf-4 -gstrict-dwarf -Wall -mcode-region=none -mdata-region=none -mlarge -Wl,--gc-sections -Wl,--start-group -lgcc -lc -Wl,--end-group

MODULES=src
BUILD_DIR=build
ANALYSIS_DIR=analysis

C_SOURCES=$(shell find $(MODULES) -name "*.c")
CC_SOURCES=$(shell find $(MODULES) -name "*.cpp")
BC_SOURCES=$(shell find $(MODULES) -name "*.bc")
IR_SOURCES=$(shell find $(MODULES) -name "*.ll")
ASM_SOURCES=$(shell find $(MODULES) -name "*.S")

C_INTERMEDIATES=$(C_SOURCES:.c=.ll)
CC_INTERMEDIATES=$(CC_SOURCES:.cpp=.ll)
BC_INTERMEDIATES=$(BC_SOURCES:.bc=.ll)
IR_INTERMEDIATES=$(IR_SOURCES:.ll=.ll)

INTERMEDIATES=$(addprefix $(BUILD_DIR)/, $(C_INTERMEDIATES) $(CC_INTERMEDIATES) $(IR_INTERMEDIATES))

C_OBJECTS=$(C_SOURCES:.c=.o)
CC_OBJECTS=$(CC_SOURCES:.cpp=.o)
BC_OBJECTS=$(BC_SOURCES:.bc=.o)
IR_OBJECTS=$(IR_SOURCES:.ll=.o)
ASM_OBJECTS=$(ASM_SOURCES:.S=.o)

OBJECTS=$(addprefix $(BUILD_DIR)/, $(C_OBJECTS) $(CC_OBJECTS) $(IR_OBJECTS) $(ASM_OBJECTS))

ALL_DEPS=

BUILD_FOLDERS=$(dir $(OBJECTS))

TARGET_APP=$(BUILD_DIR)/msp

.SECONDARY: $(%.ll)

# Default target to build everything
default: create_build_dirs $(TARGET_APP).hex $(TARGET_APP).ll

# Step 1: Convert .c to .ll using clang (C -> LLVM IR)
$(BUILD_DIR)/%.ll : %.c
	@echo "C		$< -> $@"
	@$(IR_TOOLCHAIN)/clang $(CCFLAGS) $< -o $@
	@$(IR_TOOLCHAIN)/clang $(CCFLAGS) -g -fno-limit-debug-info $< -o $@.dbg

# Step 1: use clang++ to generate .ll from headers (C++ -> LLVM IR)
$(BUILD_DIR)/%.ll : %.cpp %.h $(ALL_DEPS)
	@echo "CXX		$< -> $@"w
	@$(IR_TOOLCHAIN)/clang++ $(CCFLAGS) -c $< -o $@
	@$(IR_TOOLCHAIN)/clang++ $(CCFLAGS) -g -fno-limit-debug-info $< -o $@.dbg

# Step 1: use clang++ to generate .ll from .c++ (C++ -> LLVM IR)
$(BUILD_DIR)/%.ll : %.cpp $(ALL_DEPS)
	@echo "CXX		$< -> $@"
	@$(IR_TOOLCHAIN)/clang++ $(CCFLAGS) -c $< -o $@
	@$(IR_TOOLCHAIN)/clang++ $(CCFLAGS) -g -fno-limit-debug-info $< -o $@.dbg

# Step 2: Convert .ll to .S using ir2mir (LLVM IR -> Assembly)
$(BUILD_DIR)/%.S : $(BUILD_DIR)/%.ll
	@echo "LLC		$< -> $@"
	@$(IR_TOOLCHAIN)/llc $(LLCFLAGS) $< -o $@
	@echo "SED		$@ -> $@"
	@mv $@ $@.sed1
	@sed -E 's/^[[:space:]]*\.file[[:space:]]+([0-9]+)[[:space:]]+"[^"]+"[[:space:]]+"([^"]+)"/.file \1 "\2"/' $@.sed1 > $@.sed2
	@sed '/^[[:space:]]*\.cfi/d' $@.sed2 > $@

# Step 3: Convert .S to .o using msp430-gcc (Assembly -> Object)
$(BUILD_DIR)/%.o : $(BUILD_DIR)/%.S
	@echo "ASM		$< -> $@"
	@$(CROSS_COMPILER)-gcc $(ASMFLAGS) -c $< -o $@ $(ASM_OBJECTS)

$(TARGET_APP).ll : $(INTERMEDIATES)
	@echo "LLVM-LINK	$(INTERMEDIATES) -> $@"
	@$(IR_TOOLCHAIN)/llvm-link -S -o $@ $(INTERMEDIATES)
	@$(IR_TOOLCHAIN)/llvm-link -S -o $@.dbg $(INTERMEDIATES).dbg

# Step 4: Link .elf file from all .o files (Object -> ELF)
$(TARGET_APP).elf : $(OBJECTS)
	@echo "LD		$(OBJECTS) -> $@"
	@$(CROSS_COMPILER)-gcc $(LDFLAGS) -o $@ $(OBJECTS)

# Step 5: Create flashable .hex from .elf (ELF -> HEX)
$(TARGET_APP).hex : $(TARGET_APP).elf
	@echo "OC		$@"
	@$(CROSS_COMPILER)-objcopy -O ihex $< $@
	@$(CROSS_COMPILER)-objdump -D -l $< > $<.dump

.PHONY: clean create_build_dirs flash

clean:
	@rm -R -f build
	@rm -R -f analysis

create_build_dirs:
	@$(foreach build_folder,$(BUILD_FOLDERS), mkdir -p $(build_folder))
	@rm -Rf mkdir

export LD_LIBRARY_PATH = $(MSP_FLASHER_PATH):$LD_LIBRARY_PATH

flash: $(TARGET_APP).hex
	@./flash.sh -n $(MSP_DEVICE) -w ../$(TARGET_APP).hex -v ../$(TARGET_APP).hex -z [VCC,RESET]

analyse: default $(TARGET_APP).S

$(TARGET_APP).S:
	@echo "IR2MIR		$(TARGET_APP).ll -> $(TARGET_APP).S"
	@$(IR_TOOLCHAIN)/ir2mir -dump-file=$(Target_APP).elf.dump $(TARGET_APP).ll.dbg -o $@
