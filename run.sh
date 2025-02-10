#!/bin/bash
# run_debug.sh - Script to start GDB with an ELF file and automatically connect, load, and run

# Check if an ELF file was provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <path-to-elf>"
  exit 1
fi

ELF_FILE="$1"

# Launch GDB with the specified ELF and a series of commands
arm-none-eabi-gdb "$ELF_FILE" <<EOF
# Turn off pagination for smoother output
set pagination off

# Connect to the remote target (assuming OpenOCD is listening on localhost:3333)
target remote localhost:3333

# Program the target flash with the ELF file
load

# Issue a reset/init command to ensure the target is in a known state
monitor reset init

# Start the program execution
continue

# Optionally, you can drop into an interactive session after continue;
# if you want GDB to exit after running the commands, add 'quit'
EOF
