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
#import "Sprite.h"
#import "GameState.h"

extern TMGameState* g_pGameState;

@implementation ReceptorRow

- (id) init {
	self = [super init];
	if(!self) 
		return nil;
	
	// Subscribe to messages
	SUBSCRIBE(kNoteScoreMessage);

	mt_ReceptorExplosionMaxShowTime = FLOAT_SKIN_METRIC(@"ReceptorRow Explosion MaxShowTime");
	
	// Cache textures
	t_GoReceptor = (Receptor*)SKIN_TEXTURE(@"DownGoReceptor");
	t_ExplosionDim = SKIN_TEXTURE(@"DownTapExplosionDim");
	t_ExplosionBright = SKIN_TEXTURE(@"DownTapExplosionBright");
	t_MineExplosion = SKIN_TEXTURE(@"HitMineExplosion");
	
	// Cache metrics
	for(int i=0; i<kNumOfAvailableTracks; ++i) {
		mt_Receptors[i]	=					RECT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow %d", i]));
		mt_ReceptorExplosions[i] =			RECT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow Explosion %d", i]));
		mt_ReceptorRotations[i] =			FLOAT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow Rotation %d", i]));
		mt_ReceptorExplosionRotations[i] =  FLOAT_SKIN_METRIC(([NSString stringWithFormat:@"ReceptorRow Explosion Rotation %d", i]));		
		
		m_dExplosionTime[i] = 0.0f;
		m_nExplosion[i] = kExplosionTypeNone;
		
		{
			// Load up the Dim explosion sprite
			Sprite* spr = [[Sprite alloc] init];
			[spr setTexture: t_ExplosionDim];
			[spr setAlpha:0];
			[spr setX:mt_Receptors[i].origin.x + mt_Receptors[i].size.width/2];
			[spr setY:mt_Receptors[i].origin.y + mt_Receptors[i].size.height/2];
			[spr setRotationZ:mt_ReceptorRotations[i]];
			m_spriteExplosionDim[i] = spr;
		}
		
		{
			// Load up the Bright explosion
			Sprite* spr = [[Sprite alloc] init];
			[spr setTexture: t_ExplosionBright];
			[spr setAlpha:0];
			[spr setX:mt_Receptors[i].origin.x + mt_Receptors[i].size.width/2];
			[spr setY:mt_Receptors[i].origin.y + mt_Receptors[i].size.height/2];
			[spr setRotationZ:mt_ReceptorRotations[i]];
			m_spriteExplosionBright[i] = spr;		
		}
		{
			// Load up the Mine explosion
			Sprite* spr = [[Sprite alloc] init];
			[spr setTexture: t_MineExplosion];
			[spr setAlpha:0];
			[spr setX:mt_Receptors[i].origin.x + mt_Receptors[i].size.width/2];
			[spr setY:mt_Receptors[i].origin.y + mt_Receptors[i].size.height/2];
			[spr setRotationZ:mt_ReceptorRotations[i]];
			m_spriteMineExplosion[i] = spr;		
		}
	}
	
	m_spr = [[Sprite alloc] init];
	[m_spr setTexture: t_ExplosionBright];
	[m_spr setAlpha:0.5];
	[m_spr pushKeyFrame:15.0];
	[m_spr setX:200];
	[m_spr setY:200];
	[m_spr setScale:2];
	[m_spr setRotationZ:180];

	
	// Sounds
	sr_ExplosionMine = SOUND(@"SongPlay HitMine"); 
	
	return self;
}

- (void) dealloc {
	UNSUBSCRIBE_ALL();
	for(int i=0; i<kNumOfAvailableTracks; ++i) {
		[m_spriteExplosionDim[i] release];
		[m_spriteExplosionBright[i] release];
	}
	[m_spr release];
	[super dealloc];
}

- (void) tapNoteExplodeTrack:(TMAvailableTracks)track bright:(bool)bright judgement:(TMJudgement)judgement {
	//m_dExplosionTime[receptor] = 0.0f;
	//m_nExplosion[receptor] = kExplosionTypeDim;
	int i = track;
	Sprite *spr = bright ? m_spriteExplosionBright[i] : m_spriteExplosionDim[i];
	[spr finishKeyFrames];
	[spr setScale:1.05];
	[spr setAlpha:1];
	// TODO: Remove hard-coded colors
	float r, g, b;
	switch( judgement )	{
		default:
			assert(0);
		case kJudgementW1:
			r = 1; g = 1; b = 1;
			break;
		case kJudgementW2:
			r = 1; g = 1; b = 0;
			break;
		case kJudgementW3:
			r = 0.2; g = 1; b = 0.2;
			break;
		case kJudgementW4:
			r = 0; g = 0.9; b = 1;
			break;
		case kJudgementW5:
			r = 1; g = 0.2; b = 0.8;
			break;
	}
	[spr setR:r G:g B:b];
	[spr pushKeyFrame:0.3];
	[spr setAlpha:0];
}

- (void) explodeMine:(TMAvailableTracks)receptor {
	//m_dExplosionTime[receptor] = 0.0f;
	//m_nExplosion[receptor] = kExplosionTypeMine;
	// TODO: make keyframing rotate
	int i = receptor;
	[m_spriteExplosionBright[i] finishKeyFrames];
	[m_spriteExplosionBright[i] setScale:1.05];
	[m_spriteExplosionBright[i] setAlpha:1];
	[m_spriteExplosionBright[i] pushKeyFrame:0.3];
	[m_spriteExplosionBright[i] setAlpha:0];	
}

/* TMRenderable method */
- (void) render:(float)fDelta {
	// Here we will render all receptors at their places
	for(int i=0; i<kNumOfAvailableTracks; ++i) {
		glEnable(GL_BLEND);
		[t_GoReceptor drawFrame:0 rotation:mt_ReceptorRotations[i] inRect:mt_Receptors[i]];
		glDisable(GL_BLEND);
		
		// Draw the explosions
		[m_spriteExplosionDim[i] render:fDelta];
		[m_spriteExplosionBright[i] render:fDelta];
		[m_spriteMineExplosion[i] render:fDelta];
	}

	[m_spr render:fDelta];
}

/* TMLogicUpdater method */
- (void) update:(float)fDelta {
	// Check explosions
	/*
	for(int i=0; i<kNumOfAvailableTracks; ++i){
		if(m_nExplosion[i] != kExplosionTypeNone) {
			// could timeout
			m_dExplosionTime[i] += fDelta;
			if(m_dExplosionTime[i] >= mt_ReceptorExplosionMaxShowTime) {
				m_nExplosion[i] = kExplosionTypeNone;	// Disable
			}
		}
	}*/
}

/* TMMessageSupport stuff */
-(void) handleMessage:(TMMessage*)message {
	switch (message.messageId) {
		case kNoteScoreMessage:

			TMNote* note = (TMNote*)message.payload;			
			
			if(note.m_nType == kNoteType_Mine) {
				[self explodeMine:note.m_nTrack];
				[[TMSoundEngine sharedInstance] playEffect:sr_ExplosionMine];
			} else {
				// TODO: apply color to the exlosion depending on the score?
				switch(note.m_nScore) {
					case kJudgementW1:
					case kJudgementW2:
					case kJudgementW3:
					case kJudgementW4:
					case kJudgementW5:
						// flash bright if combo over certain threshold
						// TODO: move threshold to some configurable place
						TMLog(@"Current combo: %d", g_pGameState->m_nCombo);
						bool bright = g_pGameState->m_nCombo >= 100;
						[self tapNoteExplodeTrack:note.m_nTrack bright:bright judgement:note.m_nScore];
						break;
				}
			}

			break;			
	}
}

@end
