//
//  ReceptorRow.h
//  TapMania
//
//  Created by Alex Kremer on 05.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMSteps.h"	// For kNumOfAvailableTracks
#import "TMAnimatable.h"

typedef enum {
	kExplosionTypeNone = 0,
	kExplosionTypeDim,
	kExplosionTypeBright,
	kNumOfExplosionTypes
} TMExplosionType;

@class Receptor, Texture2D;

/*
 * This class is able to render all 4 receptor arrows at their places with animation
 * Uses the Receptor class which holds the receptor arrow texture
*/
@interface ReceptorRow : TMAnimatable {
	float m_fExplosionYPosition;
	float m_fExplosionXPositions[kNumOfAvailableTracks];
	float m_fReceptorXPositions[kNumOfAvailableTracks];	// Final positions on the X axis of the receptor arrows
		
	double m_dExplosionTime[kNumOfAvailableTracks];	// Time of explosion start
	TMExplosionType m_nExplosion[kNumOfAvailableTracks];	// Which explosion is active
	
	/* Metrics and such */
	CGRect mt_Receptors[kNumOfAvailableTracks];
	CGRect mt_ReceptorExplosions[kNumOfAvailableTracks];
	float  mt_ReceptorRotations[kNumOfAvailableTracks];
	float  mt_ReceptorExplosionRotations[kNumOfAvailableTracks];
	float  mt_ReceptorExplosionMaxShowTime;
		
	Receptor* t_GoReceptor;
	Texture2D* t_ExplosionDim, *t_ExplosionBright;
}

- (void) explodeDim:(TMAvailableTracks)receptor;		// Use this to start the explosion (dim)
- (void) explodeBright:(TMAvailableTracks)receptor;		// Same (bright)

@end
