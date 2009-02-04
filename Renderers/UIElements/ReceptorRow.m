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

- (id) initOnPosition:(CGPoint)position {
	self = [super init];
	if(!self) 
		return nil;
	
	m_fPositionY = position.y;	
	m_fExplosionYPosition = position.y-32.0f;
	
	// Precalculate stuff
	float currentOffset = 0.0f;
	int i;
	
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		m_fReceptorXPositions[i] = position.x + currentOffset;
		m_fExplosionXPositions[i] = position.x + currentOffset - 32.0f;
		
		currentOffset += 70; // 64 as width of the receptor + 6 as spacing
		
		m_dExplosionTime[i] = 0.0f;
		m_nExplosion[i] = kExplosionTypeNone;
	}	
	
	m_fReceptorRotations[0] = -90.0f;
	m_fReceptorRotations[1] = 0.0f;
	m_fReceptorRotations[2] = 180.0f;
	m_fReceptorRotations[3] = 90.0f;
		
	return self;
}

- (void) explodeDim:(TMAvailableTracks)receptor {
	m_dExplosionTime[receptor] = 0.0f;
	m_nExplosion[receptor] = kExplosionTypeDim;
}

- (void) explodeBright:(TMAvailableTracks)receptor {
	m_dExplosionTime[receptor] = 0.0f;
	m_nExplosion[receptor] = kExplosionTypeBright;
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	// Here we will render all 4 receptors at their places
	Receptor* receptor = (Receptor*)[[TexturesHolder sharedInstance] getTexture:kTexture_GoReceptor];
	int i;
	
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		[receptor drawFrame:0 rotation:m_fReceptorRotations[i] inRect:CGRectMake(m_fReceptorXPositions[i], m_fPositionY, 64.0f, 64.0f)];
		
		// Draw explosion if required
		if(m_nExplosion[i] != kExplosionTypeNone) {
			TMFramedTexture* tex = nil;
			
			if(m_nExplosion[i] == kExplosionTypeDim) {
				tex = (TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapExplosionDim];
			} else {
				tex = (TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapExplosionBright];
			}

			[tex drawFrame:0 rotation:m_fReceptorRotations[i] inRect:CGRectMake(m_fExplosionXPositions[i], m_fExplosionYPosition, 128.0f, 128.0f)];
		}
	}
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
	// Check explosions
	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i){
		if(m_nExplosion[i] != kExplosionTypeNone) {
			// could timeout
			m_dExplosionTime[i] += [fDelta floatValue];
			if(m_dExplosionTime[i] >= kExplosionMaxTime) {
				m_nExplosion[i] = kExplosionTypeNone;	// Disable
			}
		}
	}
}

@end
