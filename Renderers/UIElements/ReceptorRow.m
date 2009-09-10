//
//  ReceptorRow.m
//  TapMania
//
//  Created by Alex Kremer on 05.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "ReceptorRow.h"
#import "Receptor.h"
#import "Texture2D.h"
#import "ThemeManager.h"

@implementation ReceptorRow

- (id) init {
	self = [super init];
	if(!self) 
		return nil;
	
	// Cache metrics
	for(int i=0; i<kNumOfAvailableTracks; ++i) {
		mt_Receptors[i]	=					RECT_METRIC(([NSString stringWithFormat:@"SongPlay ReceptorRow %d", i]));
		mt_ReceptorExplosions[i] =			RECT_METRIC(([NSString stringWithFormat:@"SongPlay ReceptorRow Explosion %d", i]));
		mt_ReceptorRotations[i] =			FLOAT_METRIC(([NSString stringWithFormat:@"SongPlay ReceptorRow Rotation %d", i]));
		mt_ReceptorExplosionRotations[i] =  FLOAT_METRIC(([NSString stringWithFormat:@"SongPlay ReceptorRow Explosion Rotation %d", i]));		
		
		m_dExplosionTime[i] = 0.0f;
		m_nExplosion[i] = kExplosionTypeNone;
	}
	
	mt_ReceptorExplosionMaxShowTime = FLOAT_METRIC(@"SongPlay ReceptorRow Explosion MaxShowTime");
	
	// Cache textures
	t_GoReceptor = (Receptor*)SKIN_TEXTURE(@"DownGoReceptor");
	t_ExplosionDim = SKIN_TEXTURE(@"DownTapExplosionDim");
	t_ExplosionBright = SKIN_TEXTURE(@"DownTapExplosionBright");
			
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
- (void) render:(float)fDelta {
	// Here we will render all receptors at their places
	for(int i=0; i<kNumOfAvailableTracks; ++i) {
		glEnable(GL_BLEND);
		[t_GoReceptor drawFrame:0 rotation:mt_ReceptorRotations[i] inRect:mt_Receptors[i]];
		glDisable(GL_BLEND);
		
		// Draw explosion if required
		if(m_nExplosion[i] != kExplosionTypeNone) {
			Texture2D* tex = nil;
			
			if(m_nExplosion[i] == kExplosionTypeDim) {
				tex = t_ExplosionDim;
			} else {
				tex = t_ExplosionBright;
			}

			glEnable(GL_BLEND);
			[tex drawInRect:mt_ReceptorExplosions[i] rotation:mt_ReceptorExplosionRotations[i]];
			glDisable(GL_BLEND);
		}
	}
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {
	// Check explosions
	for(int i=0; i<kNumOfAvailableTracks; ++i){
		if(m_nExplosion[i] != kExplosionTypeNone) {
			// could timeout
			m_dExplosionTime[i] += fDelta;
			if(m_dExplosionTime[i] >= mt_ReceptorExplosionMaxShowTime) {
				m_nExplosion[i] = kExplosionTypeNone;	// Disable
			}
		}
	}
}

@end
