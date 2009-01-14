//
//  ReceptorRow.h
//  TapMania
//
//  Created by Alex Kremer on 05.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMSteps.h"
#import "TMAnimatable.h"

#define kExplosionMaxTime 0.1	// Seconds

typedef enum {
	kExplosionTypeNone = 0,
	kExplosionTypeDim,
	kExplosionTypeBright,
	kNumOfExplosionTypes
} TMExplosionType;

/*
 * This class is able to render all 4 receptor arrows at their places with animation
 * Uses the Receptor class which holds the receptor arrow texture
*/
@interface ReceptorRow : TMAnimatable {
	float _positionY;	// Where the bottom of the receptor row is relative to the screen
	float _explosionYPosition;

	float _explosionXPositions[kNumOfAvailableTracks];
	float _receptorXPositions[kNumOfAvailableTracks];	// Final positions on the X axis of the receptor arrows
	
	float _receptorRotations[kNumOfAvailableTracks];
	
	double _explosionTime[kNumOfAvailableTracks];	// Time of explosion start
	TMExplosionType _explosion[kNumOfAvailableTracks];	// Which explosion is active
}

- (id) initOnPosition:(CGPoint)lPosition;

- (void) explodeDim:(TMAvailableTracks)receptor;		// Use this to start the explosion (dim)
- (void) explodeBright:(TMAvailableTracks)receptor;		// Same (bright)

@end
