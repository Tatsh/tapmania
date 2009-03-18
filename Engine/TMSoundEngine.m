//
//  TMSoundEngine.m
//  TapMania
//
//  Created by Alex Kremer on 18.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMSoundEngine.h"

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>

// This is a singleton class, seebelow
static TMSoundEngine *sharedSoundEngineDelegate = nil;

/* We will need some C routines to use OpenAL. this routines are coded by Apple */
typedef ALvoid AL_APIENTRY (*alBufferDataStaticProcPtr) (const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq);
ALvoid  alBufferDataStaticProc(const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq) {
	static	alBufferDataStaticProcPtr	proc = NULL;
	
    if (proc == NULL) {
        proc = (alBufferDataStaticProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alBufferDataStatic");
    }
	
    if (proc)
        proc(bid, format, data, size, freq);
	
    return;
}

void* getOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei* outSampleRate) {
	OSStatus err = noErr;
	SInt64 theFileLengthInBytes = 0;
	AudioStreamBasicDescription theFileFormat;
	UInt32 thePropertySize = sizeof(theFileFormat);
	AudioFileID aFID;
	
	void* theData = NULL;
	AudioStreamBasicDescription theOutputFormat;
	
	// Open a file
	err = AudioFileOpenURL(inFileURL, kAudioFileReadPermission, 0, &aFID);
	if(err) { printf("getOpenALAudioData: AudioFileOpenURL FAILED, Error = %ld\n", err); goto Exit; }
	
	// Get the audio data format
	err = AudioFileGetProperty(aFID, kAudioFilePropertyDataFormat, &thePropertySize, &theFileFormat);
	if(err) { printf("getOpenALAudioData: AudioFileGetProperty(kAudioFilePropertyDataFormat) FAILED, Error = %ld\n", err); goto Exit; }
	if (theFileFormat.mChannelsPerFrame > 2)  { printf("getOpenALAudioData - Unsupported Format, channel count is greater than stereo\n"); goto Exit;}
	
	// Set the client format to 16 bit signed integer (native-endian) data
	// Maintain the channel count and sample rate of the original source format
	theOutputFormat.mSampleRate = theFileFormat.mSampleRate;
	theOutputFormat.mChannelsPerFrame = theFileFormat.mChannelsPerFrame;
	
	theOutputFormat.mFormatID = kAudioFormatLinearPCM;
	theOutputFormat.mBytesPerPacket = 2 * theOutputFormat.mChannelsPerFrame;
	theOutputFormat.mFramesPerPacket = 1;
	theOutputFormat.mBytesPerFrame = 2 * theOutputFormat.mChannelsPerFrame;
	theOutputFormat.mBitsPerChannel = 16;
	theOutputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	
	// Get the total frame count
	thePropertySize = sizeof(theFileLengthInBytes);
	err = AudioFileGetProperty(aFID, kAudioFilePropertyAudioDataByteCount, &thePropertySize, &theFileLengthInBytes);
	if(err) { printf("getOpenALAudioData: AudioFileGetProperty(kAudioFilePropertyAudioDataByteCount) FAILED, Error = %ld\n", err); goto Exit; }
	
	// Read all the data into memory
	UInt32		dataSize = theFileLengthInBytes;
	theData = malloc(dataSize);
	if (theData)
	{
		AudioBufferList		theDataBuffer;
		theDataBuffer.mNumberBuffers = 1;
		theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
		theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
		theDataBuffer.mBuffers[0].mData = theData;
		
		// Read the data into an AudioBufferList
		err = AudioFileReadBytes(aFID, true, 0, (UInt32*)&theFileLengthInBytes, &theDataBuffer);

		if(err == noErr)
		{
			// success
			*outDataSize = (ALsizei)dataSize;
			*outDataFormat = (theOutputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
			*outSampleRate = (ALsizei)theOutputFormat.mSampleRate;
		}
		else
		{
			// failure
			free (theData);
			theData = NULL; // make sure to return NULL
			printf("getOpenALAudioData: AudioFileRead FAILED, Error = %ld\n", err); goto Exit;
		}
	}

Exit:
	// Close the AudioFileRef, it is no longer needed
	if (aFID) AudioFileClose(aFID);
	
	return theData;
}

/* Now to the implementation */
@implementation TMSoundEngine

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

// Methods
- (BOOL) loadMusicFile:(NSString*) inPath {
	return YES;
}

- (void) unloadMusic {
}

// Music playback
- (BOOL) playMusic {
	return YES;	
}

- (BOOL) pauseMusic {
	return YES;
}

- (BOOL) stopMusic {
	return YES;	
}

- (BOOL) setMusicPosition:(float) inPosition {
	return YES;
}

- (void) fadeOutMusic:(float) inTimeDelta {
}


#pragma mark Singleton stuff

+ (TMSoundEngine *)sharedInstance {
    @synchronized(self) {
        if (sharedSoundEngineDelegate == nil) {
            [[self alloc] init];
        }
    }
    return sharedSoundEngineDelegate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedSoundEngineDelegate	== nil) {
            sharedSoundEngineDelegate = [super allocWithZone:zone];
            return sharedSoundEngineDelegate;
        }
    }
	
    return nil;
}


- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	// NOTHING
}

- (id)autorelease {
    return self;
}

@end
