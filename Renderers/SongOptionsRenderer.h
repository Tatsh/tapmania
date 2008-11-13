//
//  SongOptionsRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractMenuRenderer.h"

#import "TMSong.h"
#import "TMSongOptions.h"
#import "TogglerItem.h"

@interface SongOptionsRenderer : AbstractMenuRenderer {
	TMSong*				song;				// The song we are about to play
	
	TMSongOptions*		options;			// The options object to set stuff on
	TMSongDifficulty	selectedDifficulty;	// Selected difficulty
	
	TogglerItem*		difficultyToggler;	// Select the difficulty
	TogglerItem*		speedModsToggler;	// Select your speed modifier
}

- (id) initWithView:(EAGLView*)lGlView andSong:(TMSong*)lSong;

@end
