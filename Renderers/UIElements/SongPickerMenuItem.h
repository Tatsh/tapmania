//
//  SongPickerMenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"

@class Texture2D, TMSong;

@interface SongPickerMenuItem : MenuItem {
	TMSong* m_pSong;	// The song object bound to this menu item
	Texture2D* m_pArtist;
}

@property (readonly, retain, nonatomic, getter=song) TMSong* m_pSong;

- (id) initWithSong:(TMSong*) song atPoint:(CGPoint)point;
- (void) updateYPosition:(float)pixels;
- (void) updateWithSong:(TMSong*)song atPoint:(CGPoint)point;

@end
