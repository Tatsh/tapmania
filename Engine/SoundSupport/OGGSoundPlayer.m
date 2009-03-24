//
//  OGGSoundPlayer.m
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "OGGSoundPlayer.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>

#import <vorbis/vorbisfile.h>


#define BUFFER_SIZE   32768     // 32 KB buffers

@implementation OGGSoundPlayer

- (id) initWithFile:(NSString*)inFile {
	self = [super init];
	if(!self)
		return nil;

	TMLog(@"Try to init ogg player for file '%@'", inFile);
	
	// Read the file and parse ogg stuff
	int endian = 0;             // 0 for Little-Endian, 1 for Big-Endian
	int bitStream;
	long bytes, curLen;
	char array[BUFFER_SIZE];    // Local fixed size array
	FILE *f;

	curLen = 0;
	char *buffer = nil;
	
	ALenum format;
	ALsizei freq;
	
	f = fopen([inFile UTF8String], "rb");

	vorbis_info *pInfo;
  	OggVorbis_File oggFile;

	ov_open(f, &oggFile, NULL, 0);

	pInfo = ov_info(&oggFile, -1);
	if (pInfo->channels == 1)
		format = AL_FORMAT_MONO16;
	else
		format = AL_FORMAT_STEREO16;
	
	freq = pInfo->rate;
	
	// FIXME: this is insanely slow!!! like 30 seconds for a simple 1.5 min ogg file... :(
	do { 
		
		bytes = ov_read(&oggFile, array, BUFFER_SIZE, endian, 2, 1, &bitStream);
		curLen += bytes;

		buffer = (char*) realloc(buffer, curLen);
		
		int i, j;
		for(j=0, i=curLen-bytes; i<curLen; ++i, ++j){ 
			buffer[i] = array[j];
		}

 	} while (bytes > 0);

	TMLog(@"Done with ogg reading...");
	ov_clear(&oggFile);

	// Now to the AL player...
	NSUInteger bufferID;
	alGenBuffers(1, &bufferID);
	alBufferData(bufferID,format,buffer,curLen,freq);
	
	NSUInteger sourceID;	
	alGenSources(1, &sourceID); 
	alSourcei(sourceID, AL_BUFFER, bufferID);
	alSourcef(sourceID, AL_PITCH, 1.0f);
	alSourcef(sourceID, AL_GAIN, 1.0f);
	
	alSourcei(sourceID, AL_LOOPING, AL_FALSE);

	// play!
	TMLog(@"Try to play sound...");
	alSourcePlay(sourceID);
	TMLog(@"huh?");

	return self;
}

@end
