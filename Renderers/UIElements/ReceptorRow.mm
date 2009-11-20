//
//  $Id$
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
#import "TMNote.h"
#import "TMMessage.h"
#import "TMSound.h"
#import "TMSoundEngine.h"
#import "MessageManager.h"

@implementation ReceptorRow

- (id) init {
	self = [super init];
	if(!self) 
		return nil;
	
	// Subscribe to messages
	SUBSCRIBE(kNoteScoreMessage);
	
	// Cache metrics
	for(int i=0; i<kNumOfAvailableTracks; ++i) {
		mt_Receptors[i]	=					RECT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow %d", i]));
		mt_ReceptorExplosions[i] =			RECT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow Explosion %d", i]));
		mt_ReceptorRotations[i] =			FLOAT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow Rotation %d", i]));
		mt_ReceptorExplosionRotations[i] =  FLOAT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow Explosion Rotation %d", i]));		
		
		m_dExplosionTime[i] = 0.0f;
		m_nExplosion[i] = kExplosionTypeNone;
	}
	
	mt_ReceptorExplosionMaxShowTime = FLOAT_SKIN_METRIC(@"ReceptorRow Explosion MaxShowTime");
	
	// Cache textures
	t_GoReceptor = (Receptor*)SKIN_TEXTURE(@"DownGoReceptor");
	t_ExplosionDim = SKIN_TEXTURE(@"DownTapExplosionDim");
	t_ExplosionBright = SKIN_TEXTURE(@"DownTapExplosionBright");
	t_MineExplosion = SKIN_TEXTURE(@"HitMineExplosion");
	
	// Sounds
	sr_ExplosionMine = SOUND(@"SongPlay HitMine"); 
	
	return self;
}

- (void) dealloc {
	UNSUBSCRIBE_ALL();
	[super dealloc];
}

- (void) explodeDim:(TMAvailableTracks)receptor {
	m_dExplosionTime[receptor] = 0.0f;
	m_nExplosion[receptor] = kExplosionTypeDim;
}

- (void) explodeBright:(TMAvailableTracks)receptor {
	m_dExplosionTime[receptor] = 0.0f;
	m_nExplosion[receptor] = kExplosionTypeBright;
}

- (void) explodeMine:(TMAvailableTracks)receptor {
	m_dExplosionTime[receptor] = 0.0f;
	m_nExplosion[receptor] = kExplosionTypeMine;
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
			
			if(m_nExplosion[i] == kExplosionTypeMine) {
				tex = t_MineExplosion;
				
				glEnable(GL_BLEND);
				[tex drawInRect:mt_ReceptorExplosions[i]];
				glDisable(GL_BLEND);
			} else {
					
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

/* TMMessageSupport stuff */
-(void) handleMessage:(TMMessage*)message {
	switch (message.messageId) {
		case kNoteScoreMessage:

			TMNote* note = (TMNote*)message.payload;			
			
			if(note.m_nType == kNoteType_Mine) {
				[self explodeMine:note.m_nTrack];
				[[TMSoundEngine sharedInstance] playEffect:sr_ExplosionMine];
				
			} else if(note.m_nScore == kJudgementW1) {
				[self explodeBright:note.m_nTrack];
				
			} else if(note.m_nScore != kJudgementMiss) {
				[self explodeDim:note.m_nTrack];	
			}

			break;			
	}
}

@end
