//
//  OGGSoundPlayer.h
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "AbstractSoundPlayer.h"
#import <vorbis/vorbisfile.h>

@interface OGGSoundPlayer : AbstractSoundPlayer {
	OggVorbis_File	m_oStream;
	vorbis_info*	m_pVorbisInfo;
}

@end
