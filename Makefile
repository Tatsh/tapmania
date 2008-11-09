prefix=/dat/sys
CC=arm-apple-darwin9-gcc
LD=$(CC) 
FRAMEWORKS=-framework CoreFoundation -framework Foundation -framework UIKit -framework CoreAudio -framework OpenAL -framework CoreGraphics -framework OpenGLES -framework AudioToolbox -framework QuartzCore
LDFLAGS=-L"${prefix}/usr/lib" -F"${prefix}/System/Library/Frameworks" -bind_at_load -lobjc -lstdc++ $(FRAMEWORKS)
CFLAGS=-O2 -I. -IUtil -IObjects -IClasses -IRenderers -IRenderers/UIElements -I"${prefix}/usr/include"
OBJS=Util/Texture2D.o Classes/SoundEffectsHolder.o Classes/JoyPad.o Classes/SongsDirectoryCache.o Classes/TapManiaAppDelegate.o Classes/TexturesHolder.o Classes/EAGLView.o Renderers/AbstractRenderer.o Renderers/AbstractMenuRenderer.o Renderers/MainMenuRenderer.o Renderers/UIElements/LifeBar.o  Renderers/UIElements/MenuItem.o Renderers/SongPlayRenderer.o Renderers/SongPickerMenuRenderer.o Renderers/CreditsRenderer.o Renderers/OptionsMenuRenderer.o Objects/TMSong.o Objects/TMSteps.o Objects/TMSongOptions.o Util/SoundEngine.o

all: app tar deploy 

deploy:
	scp tm.tar mobile@192.168.0.102:

tar:
	tar cf tm.tar TapMania.app


app: tapmania bin 

bin:
	$(LD) $(LDFLAGS) -v -o TapMania $(OBJS) main.o
	rm -rf TapMania.app
	mkdir TapMania.app
	cp *.png TapMania.app/
	cp Images/* TapMania.app/
	cp *.plist TapMania.app/
	cp Credits.txt TapMania.app/
	cp TapMania TapMania.app/

tapmania: $(OBJS) main.o 

%.o: %.m soundengine
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

soundengine:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) Util/SoundEngine.cpp -o Util/SoundEngine.o

clean:
	rm -f $(OBJS) TapMania
