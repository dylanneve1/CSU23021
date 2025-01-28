export PICO_SDK_PATH="$(pwd)/pico-sdk"
rm -rf build && mkdir build
cd build
cmake ../
make

