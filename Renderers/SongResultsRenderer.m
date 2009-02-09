//
//  SongResultsRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 21.01.09.
//  Copyright 2008-2009 Godexsoft. All rights reserved.
//

#import "SongResultsRenderer.h"

#import "TapMania.h"
#import "InputEngine.h"
#import "EAGLView.h"

#import "Texture2D.h"
#import "ThemeManager.h"

#import "TMSteps.h"
#import "SongPickerMenuRenderer.h"

@implementation SongResultsRenderer

Texture2D* t_SongResultsBG;

- (id) initWithSong:(TMSong*)song withSteps:(TMSteps*)steps {
	self = [super init];
	if(!self)
		return nil;
		
	// Cache textures
	t_SongResultsBG = [[ThemeManager sharedInstance] texture:@"SongResults Background"];
	
	m_pSteps = [steps retain];
	m_pSong = [song retain];

	int i, track;
	
	// asure we have zeros in all score counters
	for(i=0; i<kNumNoteScores; i++) m_nCounters[i]=0;
	for(i=0; i<kNumHoldScores; i++) m_nOkNgCounters[i]=0;
	
	m_bReturnToSongSelection = NO;
	
	// Calculate
	for(track=0; track<kNumOfAvailableTracks; track++) {
		int notesCount = [m_pSteps getNotesCountForTrack:track];
		
		for(i=0; i<notesCount; i++) {
			TMNote* note = [m_pSteps getNote:i fromTrack:track];
			
			if(note.m_nType != kNoteType_Empty) {
				m_nCounters[ note.m_nScore ] ++;
				
				if(note.m_nType == kNoteType_HoldHead) {
					m_nOkNgCounters[ note.m_nHoldScore ] ++;
				}
			}
		}
	}
		
	// Alloc the textures array
	texturesArray = [[NSMutableArray alloc] initWithCapacity:8];

	// Cache the textures
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Marvelous: %d", m_nCounters[kNoteScore_W1]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Perfect: %d", m_nCounters[kNoteScore_W2]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Great: %d", m_nCounters[kNoteScore_W3]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Good: %d", m_nCounters[kNoteScore_W4]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Boo: %d", m_nCounters[kNoteScore_W5]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Miss: %d", m_nCounters[kNoteScore_Miss]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"OK: %d", m_nOkNgCounters[kHoldScore_OK]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"NG: %d", m_nOkNgCounters[kHoldScore_NG]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	
	return self;
}

- (void) dealloc {
	[m_pSteps release];
	[m_pSong release];
	
	[super dealloc];
}

/* TMTransitionSupport methods */
- (void) setupForTransition {
	// Subscribe for input events
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	// Unsubscribe from input events
	[[InputEngine sharedInstance] unsubscribe:self];
}

/* TMRenderable method */
- (void) render:(NSNumber*)fDelta {
	CGRect bounds = [TapMania sharedInstance].glView.bounds;
	
	// Draw background
	glDisable(GL_BLEND);
	[t_SongResultsBG drawInRect:bounds];
	glEnable(GL_BLEND);
	
	// Draw texts	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	int i;
	
	for(i=0; i<[texturesArray count]; i++){
		[[texturesArray objectAtIndex:i] drawInRect:CGRectMake(0, 320-(i*30), 320, 30)];
	}
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);	
}

/* TMLogicUpdater stuff */
- (void) update:(NSNumber*)fDelta {
	if(m_bReturnToSongSelection) {
		SongPickerMenuRenderer* spRenderer = [[SongPickerMenuRenderer alloc] init];
		[[TapMania sharedInstance] switchToScreen:spRenderer];
		
		m_bReturnToSongSelection = NO;
	}
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	// UITouch *t1 = [[touches allObjects] objectAtIndex:0];
	
	if([touches count] == 1){
/*		CGPoint pos = [t1 locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
*/
		
		m_bReturnToSongSelection = YES;
	}
}

@end
