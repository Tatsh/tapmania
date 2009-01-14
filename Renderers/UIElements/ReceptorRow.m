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
	
	_positionY = lPosition.y;	
	_explosionYPosition = lPosition.y-32.0f;
	
	// Precalculate stuff
	float currentOffset = 0.0f;
	int i;
	
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		_receptorXPositions[i] = lPosition.x + currentOffset;
		_explosionXPositions[i] = lPosition.x + currentOffset - 32.0f;
		
		currentOffset += 70; // 64 as width of the receptor + 6 as spacing
		
		_explosionTime[i] = 0.0f;
		_explosion[i] = kExplosionTypeNone;
	}	
	
	_receptorRotations[0] = -90.0f;
	_receptorRotations[1] = 0.0f;
	_receptorRotations[2] = 180.0f;
	_receptorRotations[3] = 90.0f;
		
	return self;
}

- (void) explodeDim:(TMAvailableTracks)receptor {
	_explosionTime[receptor] = 0.0f;
	_explosion[receptor] = kExplosionTypeDim;
}

- (void) explodeBright:(TMAvailableTracks)receptor {
	_explosionTime[receptor] = 0.0f;
	_explosion[receptor] = kExplosionTypeBright;
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	// Here we will render all 4 receptors at their places
	Receptor* receptor = (Receptor*)[[TexturesHolder sharedInstance] getTexture:kTexture_GoReceptor];
	int i;
	
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		[receptor drawFrame:0 rotation:_receptorRotations[i] inRect:CGRectMake(_receptorXPositions[i], _positionY, 64.0f, 64.0f)];
		
		// Draw explosion if required
		if(_explosion[i] != kExplosionTypeNone) {
			TMFramedTexture* tex = nil;
			
			if(_explosion[i] == kExplosionTypeDim) {
				tex = (TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapExplosionDim];
			} else {
				tex = (TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapExplosionBright];
			}

			[tex drawFrame:0 rotation:_receptorRotations[i] inRect:CGRectMake(_explosionXPositions[i], _explosionYPosition, 128.0f, 128.0f)];
		}
	}
}

/* TMLogicUpdater method */
- (void) update:(NSNumber*)fDelta {
	// Check explosions
	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i){
		if(_explosion[i] != kExplosionTypeNone) {
			// could timeout
			_explosionTime[i] += [fDelta floatValue];
			if(_explosionTime[i] >= kExplosionMaxTime) {
				_explosion[i] = kExplosionTypeNone;	// Disable
			}
		}
	}
}

@end
