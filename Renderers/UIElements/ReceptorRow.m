//
//  ReceptorRow.m
//  TapMania
//
//  Created by Alex Kremer on 05.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "ReceptorRow.h"
#import "Receptor.h"
#import "TexturesHolder.h"

@implementation ReceptorRow

- (id) initOnPosition:(CGPoint)lPosition {
	self = [super init];
	if(!self) 
		return nil;
	
	position = lPosition;	
	
	// Precalculate stuff
	float currentOffset = 0.0f;
	int i;
	
	for(i=0; i<4; i++) {
		receptorXPositions[i] = position.x + currentOffset;
		currentOffset += 70; // 64 as width of the receptor + 6 as spacing
	}	
	
	receptorRotations[0] = -90.0f;
	receptorRotations[1] = 0.0f;
	receptorRotations[2] = 180.0f;
	receptorRotations[3] = 90.0f;
	
	return self;
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	// Here we will render all 4 receptors at their places
	Receptor* receptor = (Receptor*)[[TexturesHolder sharedInstance] getTexture:kTexture_GoReceptor];
	int i;
	
	for(i=0; i<4; i++) {
		CGRect receptorRect = CGRectMake(receptorXPositions[i], position.y, 64.0f, 64.0f);
		[receptor drawFrame:0 rotation:receptorRotations[i] inRect:receptorRect];
	}
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
}

@end
