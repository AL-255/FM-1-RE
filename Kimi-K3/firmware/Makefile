# FM-1 custom synth demo — pi32v2 build (JieLi toolchain)
TC ?= /home/yukidama/JL/toolchain/toolchain/jieli-linux-toolchains-20250324.1
CXX = $(TC)/pi32v2/bin/cxx
LD  = $(TC)/pi32v2/bin/ld
OBJCOPY = $(TC)/common/bin/objcopy
NM  = $(TC)/pi32v2/bin/nm

SYS_INC = $(TC)/pi32v2/include
LIBDIR  = $(TC)/pi32v2/lib

CFLAGS = -Os -fno-builtin -fno-exceptions -fno-rtti -fno-threadsafe-statics \
         -ffunction-sections -fdata-sections -std=c++11 \
         -I$(SYS_INC) -Idexed -Isrc -D__pi32v2__ -DDEXED_NO_COMPRESSOR

DEXED_SRC = $(wildcard dexed/*.cpp)
SRC = src/demo.cpp src/rt.cpp src/hooks.cpp src/voices.cpp $(DEXED_SRC)
OBJ = $(patsubst %.cpp,build/pi32/%.o,$(notdir $(SRC))) build/pi32/hooks_s.o

.PHONY: all host clean
all: build/demo.bin build/demo.map.json

build/pi32/%.o: src/%.cpp | build/pi32
	$(CXX) $(CFLAGS) -c $< -o $@
build/pi32/hooks_s.o: src/hooks.S | build/pi32
	$(CXX) $(CFLAGS) -c $< -o $@
build/pi32/%.o: dexed/%.cpp | build/pi32
	$(CXX) $(CFLAGS) -c $< -o $@

build/pi32:
	mkdir -p build/pi32

build/demo.elf: $(OBJ) link.ld
	$(LD) -T link.ld -Map=build/demo.map --gc-sections -o $@ $(OBJ) \
	    -L$(LIBDIR) -lm -lcompiler_rt
	$(NM) $@ > build/demo.nm

build/demo.bin: build/demo.elf
	$(OBJCOPY) -O binary -j .text $< build/demo_text.bin
	$(OBJCOPY) -O binary -j .rodata $< build/demo_rodata.bin
	$(OBJCOPY) -O binary -j .data $< build/demo_data.bin
	cat build/demo_text.bin build/demo_rodata.bin build/demo_data.bin > $@

build/demo.map.json: build/demo.elf
	python3 ../tools/symbols.py build/demo.nm $@

host: host/sim host/render_test host/fm1_synth host/lv2/fm1_dexed.so host/midi_blaster
host/sim: host/sim_main.cpp $(wildcard src/*.cpp) $(DEXED_SRC)
	g++ -O2 -fno-builtin -std=c++11 -Idexed -Isrc -o $@ $^
host/render_test: host/main.cpp $(DEXED_SRC)
	g++ -O2 -fno-builtin -std=c++11 -Idexed -o $@ $^
host/fm1_synth: host/alsa_main.cpp src/voices.cpp $(DEXED_SRC)
	g++ -O2 -std=c++11 -Idexed -Isrc -o $@ $^ -lasound -lpthread
host/midi_blaster: host/midi_blaster.cpp
	g++ -O2 -std=c++11 -o $@ $^ -lasound
host/lv2/fm1_dexed.so: host/lv2/fm1_dexed.cpp src/voices.cpp $(DEXED_SRC)
	g++ -O2 -std=c++11 -fPIC -shared -Ihost/lv2 -Idexed -Isrc -o $@ $^
host/lv2_host_test: host/lv2_host_test.cpp
	g++ -O2 -std=c++11 -Ihost/lv2 -o $@ $^ -ldl

image: build/demo.bin
	python3 ../tools/build_image.py

clean:
	rm -rf build host/sim host/render_test host/fm1_synth host/midi_blaster \
	    host/lv2_host_test host/lv2/fm1_dexed.so
