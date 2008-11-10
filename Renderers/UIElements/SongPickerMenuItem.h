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

@interface SongPickerMenuItem : MenuItem {
	TMSong* song;	// The song object bound to this menu item
}

@property (readonly, retain, nonatomic) TMSong* song;

- (id) initWithSong:(TMSong*) lSong;

@end
