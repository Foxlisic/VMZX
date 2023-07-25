FF1=ffmpeg -framerate 50 -r 50 -i
FF2=-f mp4 -q:v 0 -vcodec mpeg4 -y
SCALE=-vf "scale=w=1280:h=960,pad=width=1920:height=1080:x=320:y=60:color=black" -sws_flags neighbor -sws_dither none
FILES=ay.cc constructor.cc disasm.h io.cc machine.cc main.cc disasm.cc fonts.h machine.h snapshot.cc video.cc z80.cc

all: build myrom
	./vmzx -r1 custom48k.rom
myrom:
	sjasm custom48k.asm custom48k.rom
build: $(FILES)
	g++ `sdl-config --cflags --libs` main.cc -lSDL -o vmzx
nosdl:  $(FILES)
	g++ -DNO_SDL main.cc -o vmzx
tap:
	./vmzx 48k.z80 program.tap
dizzy3:
	./vmzx snap/dizzy3_128.z80
dizzy3bmp:
	./vmzx snap/dizzy3_128.z80 -o record.bmp -w record.wav
	make bmp2mp4
bmp2mp4:
	$(FF1) record.bmp -i record.wav $(FF2) record.mp4
mp4:
	./vmzx dizzy3.z80 -o - | $(FF1) - $(SCALE) $(FF2) record.mp4
# Скипать повторные кадры
mp4skip:
	./vmzx dizzy3.z80 -s -o - | $(FF1) - $(SCALE) $(FF2) record.mp4
