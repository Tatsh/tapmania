//
//  TapNote.m
//  TapMania
//
//  Created by Alex Kremer on 05.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TapNote.h"
#import "TMSteps.h"
#import "ThemeManager.h"

@interface TapNote (Private)
- (float) calculateRotation:(TMNoteDirection)dir;
@end

static int mt_TapNoteRotations[kNumOfAvailableTracks];

@implementation TapNote

// Override TMAnimatable constructor
- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows {
	self = [super initWithImage:uiImage columns:columns andRows:rows];
	if(!self)
		return nil;
	
	// Cache metrics	
	mt_TapNoteRotations[kAvailableTrack_Left] = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Rotation Left"];
	mt_TapNoteRotations[kAvailableTrack_Down] = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Rotation Down"];
	mt_TapNoteRotations[kAvailableTrack_Up] = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Rotation Up"];
	mt_TapNoteRotations[kAvailableTrack_Right] = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Rotation Right"];	
	
	// We will animate every arrow at same time
	m_nStartFrame = 0;
	m_nEndFrame = 4;
	
	m_nCurrentFrame = m_nStartFrame;
	m_bIsLooping = YES;
		
	return self;
}


/* TMRenderable method */
- (void) render:(float)fDelta {
	/* 
	 * NOTE: We have to override this method because we will handle rendering separately. 
	 * We must be sure that this rendering routine will do nothing 
	*/
}

- (float) calculateRotation:(TMNoteDirection)dir {
	return mt_TapNoteRotations[dir];
}

/* Main drawing routine */
- (void) drawTapNote:(TMBeatType)type direction:(TMNoteDirection)dir inRect:(CGRect)rect {
	float rotation = [self calculateRotation:dir];
	int frameToRender = m_nCurrentFrame + type*m_nFramesToLoad[0]; // Columns
	
	glEnable(GL_BLEND);
	[self drawFrame:frameToRender rotation:rotation inRect:rect];
	glDisable(GL_BLEND);
}

- (void) drawHoldTapNoteHolding:(TMBeatType)type direction:(TMNoteDirection)dir inRect:(CGRect)rect {
	float rotation = [self calculateRotation:dir];
	int frameToRender = (m_nCurrentFrame+4) + type*m_nFramesToLoad[0]; // Columns
	
	glEnable(GL_BLEND);
	[self drawFrame:frameToRender rotation:rotation inRect:rect];
	glDisable(GL_BLEND);
}

- (void) drawHoldTapNoteReleased:(TMBeatType)type direction:(TMNoteDirection)dir inRect:(CGRect)rect {
	// Will use the regular tap note for this
	[self drawTapNote:type direction:dir inRect:rect];
}


@end
