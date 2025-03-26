CROSS_COMPILER=./msp430-gcc/bin/msp430-elf
IR_TOOLCHAIN=./../llvm-project/build/bin
MSP_FLASHER_PATH=./MSPFlasher_1.3.20
MSP_INCLUDES=msp430-gcc/include
MSP_DEVICE=msp430fr5994

CCFLAGS=-Wall -Werror -Og -g -gdwarf-3 -gstrict-dwarf -Wall -mcode-region=none -mdata-region=none -mlarge -Wl,--gc-sections -Wl,--start-group -lgcc -lc -Wl,--end-group -I$(MSP_INCLUDES) -D __$(MSP_DEVICE)__ -mmcu=$(MSP_DEVICE) -I.

LDFLAGS=-T $(MSP_INCLUDES)/$(MSP_DEVICE).ld -L $(MSP_INCLUDES) -Og -g -gdwarf-3 -gstrict-dwarf -Wall -mcode-region=none -mdata-region=none -mlarge -Wl,--gc-sections -Wl,--start-group -lgcc -lc -Wl,--end-group

MODULES=src
BUILD_DIR=build

C_SOURCES=$(shell find $(MODULES) -name "*.c")
CC_SOURCES=$(shell find $(MODULES) -name "*.cpp")
ASM_SOURCES=$(shell find $(MODULES) -name "*.S")

C_OBJECTS=$(C_SOURCES:.c=.o)
CC_OBJECTS=$(CC_SOURCES:.cpp=.o)
ASM_OBJECTS=$(ASM_SOURCES:.S=.o)

OBJECTS=$(addprefix $(BUILD_DIR)/, $(C_OBJECTS) $(CC_OBJECTS) $(ASM_OBJECTS))
ALL_DEPS=

BUILD_FOLDERS=$(dir $(OBJECTS))

TARGET_APP=$(BUILD_DIR)/msp

default: create_build_dirs $(TARGET_APP).hex

$(TARGET_APP).hex: $(TARGET_APP).elf
	@echo "OC		$@"
	@$(CROSS_COMPILER)-objcopy -O ihex $< $@

$(TARGET_APP).elf: $(OBJECTS)
	@echo "LD		$@"
	@$(CROSS_COMPILER)-gcc $(LDFLAGS) -o $@ $(OBJECTS)

$(BUILD_DIR)/%.o : %.c $(ALL_DEPS)
	@echo "C		$< -> $@"
	@$(CROSS_COMPILER)-gcc $(CCFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o : %.cpp %.h $(ALL_DEPS)
	@echo "CC		$< -> $@"
	@$(CROSS_COMPILER)-g++ $(CCFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o : %.cpp $(ALL_DEPS)
	@echo "CC		$< -> $@"
	@$(CROSS_COMPILER)-g++ $(CCFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o : %.S $(ALL_DEPS)
	@echo "ASM		$< -> $@"
	@$(CROSS_COMPILER)-g++ $(CCFLAGS) -c $< -o $@

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
