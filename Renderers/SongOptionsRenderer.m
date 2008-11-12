//
//  SongOptionsRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongOptionsRenderer.h"
#import "TexturesHolder.h"
#import "SongPlayRenderer.h"
#import "SongPickerMenuRenderer.h"
#import "TapManiaAppDelegate.h"

@implementation SongOptionsRenderer

// Real constructor
- (id) initWithView:(EAGLView*)lGlView andSong:(TMSong*)lSong {
	self = [self initWithView:lGlView];
	
	song = lSong;	
	TMSongDifficulty dif = kSongDifficulty_Invalid;
	
	NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:5];

	for(; dif < kNumSongDifficulties; dif++) {
		if([song isDifficultyAvailable:dif]) {
			NSString* difStr = [[NSString stringWithFormat:@"%@ (%d)", [TMSong difficultyToString:dif], [song getDifficultyLevel:dif]] retain];
			[arr addObject:[[TogglerItemObject alloc] initWithTitle:difStr andValue:[NSNumber numberWithInt:dif]]];
		}
	}	
	
	difficultyToggler = [[TogglerItem alloc] initWithElements:arr];
	[difficultyToggler setPosition:100];
	
	[arr release];
	
	[glView addSubview:difficultyToggler];
	
	[self addMenuItemWithTitle:@"Play" andHandler:@selector(playGamePress:) onTarget:self];
	
	// Add back button
	[self enableBackButton]; // Handled by 'backPress:'
	[self publishMenu];	
	
	return self;
}

// Legacy constructor
- (id) initWithView:(EAGLView*)lGlView {
	self = [super initWithView:lGlView andCapacity:10];
	if(!self)
		return nil;
		
	return self;
}

- (void)dealloc {
	[song release];
	[options release];
	[difficultyToggler removeFromSuperview];
	[difficultyToggler release];
	
	[super dealloc];
}

- (void)renderScene {
	CGRect				bounds = [glView bounds];
	
	//Draw background
	glDisable(GL_BLEND);
	[[[TexturesHolder sharedInstance] getTexture:kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
	
	//Swap the framebuffer
	[glView swapBuffers];
}	

# pragma mark Touch handling
- (void) playGamePress:(id)sender {
	NSLog(@"Start song... %@", song.filePath);	

	SongPlayRenderer* songPlayRenderer = [[SongPlayRenderer alloc] initWithView:glView];
	[songPlayRenderer playSong:song onDifficulty:[(NSNumber*)[[difficultyToggler getCurrent] value] intValue] withOptions:options];
}

- (void) backPress:(id)sender {
	NSLog(@"Go to song picker from song options menu...");
	[(TapManiaAppDelegate*)[[UIApplication sharedApplication] delegate] activateRenderer:[[SongPickerMenuRenderer alloc] initWithView:glView] looping:NO];
}

@end
