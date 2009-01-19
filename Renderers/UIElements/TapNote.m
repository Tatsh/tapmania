//
//  TapNote.m
//  TapMania
//
//  Created by Alex Kremer on 05.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TapNote.h"

@interface TapNote (Private)
- (float) calculateRotation:(TMNoteDirection)dir;
@end

@implementation TapNote

// Override TMAnimatable constructor
- (id) initWithImage:(UIImage *)uiImage columns:(int)columns andRows:(int)rows {
	self = [super initWithImage:uiImage columns:columns andRows:rows];
	if(!self)
		return nil;
	
	// We will animate every arrow at same time
	startFrame = 0;
	endFrame = 4;
	
	currentFrame = startFrame;
	looping = YES;
		
	return self;
}


/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	/* 
	 * NOTE: We have to override this method because we will handle rendering separately. 
	 * We must be sure that this rendering routine will do nothing 
	*/
}

- (float) calculateRotation:(TMNoteDirection)dir {
	if(dir == kNoteDirection_Up) 
		return 180.0f;
	else if(dir == kNoteDirection_Left) 
		return -90.0f;
	else if(dir == kNoteDirection_Right) 
		return 90.0f;
	
	return 0.0f;
}

/* Main drawing routine */
- (void) drawTapNote:(TMBeatType)type direction:(TMNoteDirection)dir inRect:(CGRect)rect {
	float rotation = [self calculateRotation:dir];
	int frameToRender = currentFrame + type*framesToLoad[0]; // Columns
	
	[self drawFrame:frameToRender rotation:rotation inRect:rect];
}

- (void) drawHoldTapNote:(TMBeatType)type direction:(TMNoteDirection)dir inRect:(CGRect)rect {
	float rotation = [self calculateRotation:dir];
	int frameToRender = (currentFrame+4) + type*framesToLoad[0]; // Columns
	
	[self drawFrame:frameToRender rotation:rotation inRect:rect];
}

@end
