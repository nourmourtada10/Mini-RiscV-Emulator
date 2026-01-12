TARGET  = esw
BUILD   = build
TC      = riscv64-unknown-elf
CC      = $(TC)-gcc
LD      = $(TC)-gcc
SIZE    = $(TC)-size
OBJCOPY = $(TC)-objcopy
OBJDUMP = $(TC)-objdump

CFLAGS  += -march=rv32im
CFLAGS  += -mabi=ilp32
CFLAGS  += -W -Wall
CFLAGS  += -O2

LDFLAGS += -march=rv32im
LDFLAGS += -mabi=ilp32
LDFLAGS += -nostdlib
LDFLAGS += -nostartfiles
LDFLAGS += -T linker.ld

SRCS   += $(wildcard *.S)
OBJS    = $(addprefix $(BUILD)/, $(SRCS:.S=.o))
DEPS    = $(OBJS:.o=.d)

.PHONY: all clean lss

all: $(BUILD)/$(TARGET).bin

-include $(DEPS)

$(BUILD)/%.o: %.S
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -x assembler-with-cpp -c $< -o $@ -MMD -MP -MF"$(@:%.o=%.d)"

$(BUILD)/$(TARGET).elf: $(OBJS)
	$(LD) $(CFLAGS) -o $@ $(filter %.o,$^) $(LDFLAGS)  
	@echo "────────────────────────────────────────────────────────────────────────"
	@$(SIZE) $@
	@echo "────────────────────────────────────────────────────────────────────────"

$(BUILD)/$(TARGET).bin: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@
	@echo "Binary created: $@"

$(BUILD)/$(TARGET).lss: $(BUILD)/$(TARGET).elf
	$(OBJDUMP) -h -D $< > $@

lss: $(BUILD)/$(TARGET).lss
	less $<

clean:
	@rm -rf $(BUILD)