//
//  TMSound.h
//  TapMania
//
//  Created by Alex Kremer on 19.08.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMSoundSupport.h"

@interface TMSound : NSObject <TMSoundSupport>{
	NSString*	m_sPath;
	BOOL		m_bIsPlaying;
}

-(id) initWithPath:(NSString*)inPath;
-(void) play;

@end
