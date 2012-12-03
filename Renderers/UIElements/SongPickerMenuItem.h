//
//  $Id$
//  SongPickerMenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MenuItem.h"
#import "TMSong.h"

@class Quad, FontString, Texture2D, TMSong, TMSongSavedScore;

@interface SongPickerMenuItem : MenuItem {
	TMSong* m_pSong;	// The song object bound to this menu item
	
	FontString* m_pTitleStr;
	FontString* m_pArtistStr;
	
	Texture2D* t_WheelItem;
	TMFramedTexture*		t_Grades;
	
	// The saved score and grade (sqlite)
	TMSongSavedScore* m_pSavedScore;
    
    float	mt_nameLeftOffset;
    float   mt_nameMaxWidth;
	float	mt_artistYOffset;
	float		mt_gradeXOffset;
	
}

@property (readonly, retain, nonatomic) TMSongSavedScore* m_pSavedScore;
@property (readonly, retain, nonatomic) TMSong* song;

- (id) initWithSong:(TMSong*) song atPoint:(CGPoint)point;
- (void) updateYPosition:(float)pixels;
- (void) updateWithSong:(TMSong*)song atPoint:(CGPoint)point;
- (void) updateWithDifficulty:(TMSongDifficulty)diff;

@end
