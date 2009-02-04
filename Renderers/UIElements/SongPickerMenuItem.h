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
	TMSong* m_pSong;	// The song object bound to this menu item
	Texture2D* m_pTitle;
}

@property (readonly, retain, nonatomic) TMSong* m_pSong;

- (id) initWithSong:(TMSong*) song andShape:(CGRect)shape;
- (void) switchToSong:(TMSong*) song;

@end
