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
         -I$(SYS_INC) -Isrc -D__pi32v2__

# the on-device demo blob: basic synth + LCD overlay + hooks (NO dexed)
SRC = src/demo.cpp src/rt.cpp src/hooks.cpp src/synth.cpp src/lcd.cpp
OBJ = $(patsubst %.cpp,build/pi32/%.o,$(notdir $(SRC))) build/pi32/hooks_s.o

# host-only sources (basic synth, same as device)
HOST_SYNTH_SRC = src/synth.cpp src/voices.cpp
DEXED_SRC = $(wildcard dexed/*.cpp)

.PHONY: all host clean
all: build/demo.bin build/demo.map.json

build/pi32/%.o: src/%.cpp | build/pi32
	$(CXX) $(CFLAGS) -c $< -o $@
build/pi32/hooks_s.o: src/hooks.S | build/pi32
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

# ---------- host ----------
host: host/sim host/fm1_synth host/fm1_jack host/lv2/fm1_dexed.so host/vst/fm1_dexed.so host/midi_blaster host/synth_test host/render_test

# sim of the on-device demo (basic synth + hooks stubs)
host/sim: host/sim_main.cpp src/demo.cpp src/rt.cpp src/hooks.cpp src/synth.cpp src/lcd.cpp
	g++ -O2 -fno-builtin -std=c++11 -Isrc -o $@ $^

# standalone ALSA app (basic synth, same code as device)
host/fm1_synth: host/alsa_main.cpp src/synth.cpp
	g++ -O2 -std=c++11 -Isrc -o $@ $^ -lasound -lpthread

# standalone JACK app (basic synth, low-latency audio + MIDI)
host/fm1_jack: host/jack_main.cpp src/synth.cpp
	g++ -O2 -std=c++11 -Isrc -o $@ $^ $(shell pkg-config --cflags --libs jack)

host/midi_blaster: host/midi_blaster.cpp
	g++ -O2 -std=c++11 -o $@ $^ -lasound

# LV2 plugin (basic synth)
host/lv2/fm1_dexed.so: host/lv2/fm1_dexed.cpp src/synth.cpp
	g++ -O2 -std=c++11 -fPIC -shared -Ihost/lv2 -Isrc -o $@ $^

# VST2 plugin (basic synth)
host/vst/fm1_dexed.so: host/vst/fm1_vst.cpp src/synth.cpp
	g++ -O2 -std=c++11 -fPIC -shared -Ihost/vst -Isrc -o $@ $^

# synth unit test
host/synth_test: host/synth_test.cpp src/synth.cpp
	g++ -O2 -std=c++11 -Isrc -o $@ $^ -lm

# Dexed engine validation (reference only, not part of the demo)
host/render_test: host/main.cpp $(DEXED_SRC)
	g++ -O2 -fno-builtin -std=c++11 -Idexed -o $@ $^
host/lv2_host_test: host/lv2_host_test.cpp
	g++ -O2 -std=c++11 -Ihost/lv2 -o $@ $^ -ldl

image: build/demo.bin
	python3 ../tools/build_image.py

clean:
	rm -rf build host/sim host/render_test host/fm1_synth host/fm1_jack host/midi_blaster \
	    host/synth_test host/lv2_host_test host/lv2/fm1_dexed.so host/vst/fm1_dexed.so
