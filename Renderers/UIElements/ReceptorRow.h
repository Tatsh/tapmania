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
	float m_fPositionY;	// Where the bottom of the receptor row is relative to the screen
	float m_fExplosionYPosition;

	float m_fExplosionXPositions[kNumOfAvailableTracks];
	float m_fReceptorXPositions[kNumOfAvailableTracks];	// Final positions on the X axis of the receptor arrows
	
	float m_fReceptorRotations[kNumOfAvailableTracks];
	
	double m_dExplosionTime[kNumOfAvailableTracks];	// Time of explosion start
	TMExplosionType m_nExplosion[kNumOfAvailableTracks];	// Which explosion is active
}

- (id) initOnPosition:(CGPoint)position;

- (void) explodeDim:(TMAvailableTracks)receptor;		// Use this to start the explosion (dim)
- (void) explodeBright:(TMAvailableTracks)receptor;		// Same (bright)

@end
