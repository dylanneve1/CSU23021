#!/bin/bash

# Set the PICO SDK path
export PICO_SDK_PATH="~/pico-sdk"

# Clean and create the build directory
rm -rf build && mkdir build
cd build

# Run CMake to configure the project
cmake ../

# Determine the build target directory
echo "Choose a build target:"
echo "1. Build 'assignments'"
echo "2. Build 'labs'"
echo "3. Build main project"
read -p "Enter your choice (1/2/3): " choice

case $choice in
  1)
    # Build 'assignments'
    cd assignments
    ;;
  2)
    # Build 'labs'
    cd labs
    ;;
  3)
    # Build the main project
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Run make to build the target
make

# Success message
echo "Build completed successfully."
