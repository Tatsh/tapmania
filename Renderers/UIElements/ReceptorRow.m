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
#import "ThemeManager.h"

static int mt_ReceptorRowX, mt_ReceptorRowY;
static int mt_TapNoteHeight, mt_TapNoteWidth, mt_TapNoteSpacing;
static int mt_ReceptorRotations[kNumOfAvailableTracks];
static int mt_ExplosionAlignX, mt_ExplosionAlignY, mt_ExplosionWidth, mt_ExplosionHeight;
static float mt_ExplosionMaxShowTime;


@implementation ReceptorRow

- (id) init {
	self = [super init];
	if(!self) 
		return nil;
	
	// Cache metrics
	mt_ReceptorRowX = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow X"];
	mt_ReceptorRowY = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Y"];
	mt_ExplosionMaxShowTime = [[ThemeManager sharedInstance] floatMetric:@"SongPlay ReceptorRow Explosion MaxShowTime"];
	
	mt_TapNoteWidth = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Width"];
	mt_TapNoteHeight = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Height"];
	mt_TapNoteSpacing = [[ThemeManager sharedInstance] intMetric:@"SongPlay TapNote Spacing"]; 
	
	mt_ExplosionAlignX = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Explosion AlignX"];
	mt_ExplosionAlignY = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Explosion AlignY"];
	mt_ExplosionWidth = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Explosion Width"];
	mt_ExplosionHeight = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Explosion Height"];
	
	mt_ReceptorRotations[kAvailableTrack_Left] = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Rotation Left"];
	mt_ReceptorRotations[kAvailableTrack_Down] = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Rotation Down"];
	mt_ReceptorRotations[kAvailableTrack_Up] = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Rotation Up"];
	mt_ReceptorRotations[kAvailableTrack_Right] = [[ThemeManager sharedInstance] intMetric:@"SongPlay ReceptorRow Rotation Right"];

	int i;
	for(i=0; i<kNumOfAvailableTracks; ++i) {
		m_dExplosionTime[i] = 0.0f;
		m_nExplosion[i] = kExplosionTypeNone;
		
		m_fReceptorXPositions[i] = mt_ReceptorRowX + (mt_TapNoteWidth+mt_TapNoteSpacing)*i;
		m_fExplosionXPositions[i] = m_fReceptorXPositions[i] + mt_ExplosionAlignX;
	}	
	
	m_fExplosionYPosition = mt_ReceptorRowY+mt_ExplosionAlignY;
		
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
		[receptor drawFrame:0 rotation:mt_ReceptorRotations[i] inRect:CGRectMake(m_fReceptorXPositions[i], mt_ReceptorRowY, mt_TapNoteWidth, mt_TapNoteHeight)];
		
		// Draw explosion if required
		if(m_nExplosion[i] != kExplosionTypeNone) {
			TMFramedTexture* tex = nil;
			
			if(m_nExplosion[i] == kExplosionTypeDim) {
				tex = (TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapExplosionDim];
			} else {
				tex = (TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_TapExplosionBright];
			}

			[tex drawFrame:0 rotation:mt_ReceptorRotations[i] inRect:CGRectMake(m_fExplosionXPositions[i], m_fExplosionYPosition, mt_ExplosionWidth, mt_ExplosionHeight)];
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
			if(m_dExplosionTime[i] >= mt_ExplosionMaxShowTime) {
				m_nExplosion[i] = kExplosionTypeNone;	// Disable
			}
		}
	}
}

@end
