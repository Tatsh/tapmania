//
//  AbstractSoundPlayer.h
//  TapMania
//
//  Created by Alex Kremer on 24.03.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <OpenAL/alc.h>

@interface AbstractSoundPlayer : NSObject {
	NSUInteger m_nBufferID;
	NSUInteger m_nSourceID;	
}

// Methods. throw exceptions here
- (id) initWithFile:(NSString*)inFile;

@end
