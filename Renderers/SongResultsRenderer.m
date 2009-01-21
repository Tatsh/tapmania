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
#import "TexturesHolder.h"

#import "SongPickerMenuRenderer.h"

@implementation SongResultsRenderer

- (id) initWithSong:(TMSong*)lSong withSteps:(TMSteps*)lSteps {
	self = [super init];
	if(!self)
		return nil;
		
	steps = [lSteps retain];
	song = [lSong retain];

	int i, track;
	
	// asure we have zeros in all score counters
	for(i=0; i<kNumNoteScores; i++) counters[i]=0;
	for(i=0; i<kNumHoldScores; i++) okNgCounters[i]=0;
	
	returnToSongSelection = NO;
	
	// Calculate
	for(track=0; track<kNumOfAvailableTracks; track++) {
		int notesCount = [steps getNotesCountForTrack:track];
		
		for(i=0; i<notesCount; i++) {
			TMNote* note = [steps getNote:i fromTrack:track];
			
			if(note.type != kNoteType_Empty) {
				counters[ note.score ] ++;
				
				if(note.type == kNoteType_HoldHead) {
					okNgCounters[ note.holdScore ] ++;
				}
			}
		}
	}
		
	// Alloc the textures array
	texturesArray = [[NSMutableArray alloc] initWithCapacity:8];

	// Cache the textures
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Marvelous: %d", counters[kNoteScore_W1]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Perfect: %d", counters[kNoteScore_W2]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Great: %d", counters[kNoteScore_W3]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Good: %d", counters[kNoteScore_W4]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Boo: %d", counters[kNoteScore_W5]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"Miss: %d", counters[kNoteScore_Miss]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"OK: %d", okNgCounters[kHoldScore_OK]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	[texturesArray addObject:[[Texture2D alloc] initWithString:[NSString stringWithFormat:@"NG: %d", okNgCounters[kHoldScore_NG]] dimensions:CGSizeMake(320,30) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:24]];
	
	return self;
}

- (void) dealloc {
	[steps release];
	[song release];
	
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
	[[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionBackground] drawInRect:bounds];
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
	if(returnToSongSelection) {
		SongPickerMenuRenderer* spRenderer = [[SongPickerMenuRenderer alloc] init];
		[[TapMania sharedInstance] switchToScreen:spRenderer];
		
		returnToSongSelection = NO;
	}
}

/* TMGameUIResponder methods */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *t1 = [[touches allObjects] objectAtIndex:0];
	
	if([touches count] == 1){
/*		CGPoint pos = [t1 locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
*/
		
		returnToSongSelection = YES;
	}
}

@end
