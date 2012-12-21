//
//  $Id$
//  OGGSoundPlayer.h
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "AbstractSoundPlayer.h"
#import <vorbis/vorbisfile.h>

@interface OGGSoundPlayer : AbstractSoundPlayer
{
    OggVorbis_File m_oStream;
    vorbis_info *m_pVorbisInfo;

    FILE *m_pFile;    // The file handle

    ALuint m_nBuffers[kSoundEngineNumBuffers];    // We have back and front buffers
    ALuint m_nSourceID;
    ALenum m_nFormat;
    ALsizei m_nFreq;

    // Threading
    NSThread *m_pThread;
}

@end
