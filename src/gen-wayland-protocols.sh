#!/bin/sh

dirname=$(dirname $(realpath $0))

if ! command -v wayland-scanner >/dev/null 2>&1; then
  echo "wayland-scanner not available, exiting..."
  exit 1
fi

for proto in ext-data-control-v1 wlr-data-control-unstable-v1 xdg-shell primary-selection-unstable-v1; do
  echo "generating $proto"
  wayland-scanner client-header "$dirname"/protocols/"$proto".xml "$dirname"/auto/wayland/"$proto".h
  wayland-scanner private-code  "$dirname"/protocols/"$proto".xml "$dirname"/auto/wayland/"$proto".c
done

# vim: set sw=2 sts=2 et:
