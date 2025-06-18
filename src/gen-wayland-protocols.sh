#!/bin/sh

wayland-scanner client-header protocols/ext-data-control-v1.xml auto/wayland/ext-data-control-v1.h
wayland-scanner private-code protocols/ext-data-control-v1.xml auto/wayland/ext-data-control-v1.c

wayland-scanner client-header protocols/wlr-data-control-unstable-v1.xml auto/wayland/wlr-data-control-unstable-v1.h
wayland-scanner private-code protocols/wlr-data-control-unstable-v1.xml auto/wayland/wlr-data-control-unstable-v1.c

wayland-scanner client-header protocols/xdg-shell.xml auto/wayland/xdg-shell.h
wayland-scanner private-code protocols/xdg-shell.xml auto/wayland/xdg-shell.c

wayland-scanner client-header protocols/primary-selection-unstable-v1.xml auto/wayland/primary-selection-unstable-v1.h
wayland-scanner private-code protocols/primary-selection-unstable-v1.xml auto/wayland/primary-selection-unstable-v1.c

# vim: set sw=2 sts=2 et:
