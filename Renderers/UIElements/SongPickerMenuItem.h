//
//  SongPickerMenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"
#import "TMSong.h"
#import "Texture2D.h"

@interface SongPickerMenuItem : MenuItem {
	TMSong* song;	// The song object bound to this menu item
	Texture2D* title;
}

@property (readonly, retain, nonatomic) TMSong* song;

- (id) initWithSong:(TMSong*) lSong andShape:(CGRect)lShape;
- (void) switchToSong:(TMSong*) lSong;

@end
