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
	NSString*				m_sPath;
	BOOL					m_bAlreadyPlaying;
}

@property (assign, nonatomic, readonly, getter=playing) BOOL m_bAlreadyPlaying;
@property (retain, nonatomic, readonly, getter=path) NSString* m_sPath;

-(id) initWithPath:(NSString*)inPath;

@end
