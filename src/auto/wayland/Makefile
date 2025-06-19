# List of generated files
GEN_FILES = ext-data-control-v1.c ext-data-control-v1.h \
    primary-selection-unstable-v1.c primary-selection-unstable-v1.h \
    wlr-data-control-unstable-v1.c wlr-data-control-unstable-v1.h \
    xdg-shell.c xdg-shell.h


# Default target
all: $(GEN_FILES)

$(GEN_FILES):
	../../gen-wayland-protocols.sh

# Clean rule
clean:
	rm -f *.c *.h
