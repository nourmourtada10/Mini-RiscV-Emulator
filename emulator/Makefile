TARGET  = emulator
BUILD   = build
SRC     = $(wildcard *.c)
OBJ     = $(addprefix $(BUILD)/, $(SRC:.c=.o))
DEPS    = $(OBJ:.o=.d)
CFLAGS += -W -Wall
CFLAGS += -O2 -g
LDFLAGS = 

all: $(BUILD)/$(TARGET)

.PHONY: clean exec gdb test

-include $(DEPS)

$(BUILD)/%.o: %.c
	@mkdir -p $(@D)
	gcc $(CFLAGS) -c -o $@ $< -MMD -MP -MF"$(@:%.o=%.d)"

$(BUILD)/$(TARGET): $(OBJ)
	gcc $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo "Build complete: $@"

exec: $(BUILD)/$(TARGET)
	./$

gdb: $(BUILD)/$(TARGET)
	gdb --tui $

test: $(BUILD)/$(TARGET)
	@echo "Running hello_world test..."
	@./$< ../embedded_software/hello_world/build/esw.bin
	@echo ""
	@echo "Running fibonacci test..."
	@./$< ../embedded_software/fibonacci/build/esw.bin

clean:
	@rm -rvf $(BUILD)
