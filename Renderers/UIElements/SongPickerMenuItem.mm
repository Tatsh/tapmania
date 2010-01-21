//
//  $Id$
//  SongPickerMenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuItem.h"
#import "Texture2D.h"
#import "Quad.h"
#import "FontString.h"
#import "Font.h"
#import "FontManager.h"

#import "TMSong.h"
#import "ThemeManager.h"
#import "TapMania.h"

@interface SongPickerMenuItem (Private)
- (void) generateTextures;
@end


@implementation SongPickerMenuItem

@synthesize m_pSong;

- (id) initWithSong:(TMSong*) song atPoint:(CGPoint)point {
	self = [super initWithShape:CGRectMake(point.x, point.y, 0, 0)];
	if(!self) 
		return nil;
	
	m_pSong = song;	

	// Add font stuff
	[self initTextualProperties:@"SongPickerMenu Wheel ItemSong"];
	
	// Cache texture
	t_WheelItem = TEXTURE(@"SongPickerMenu Wheel ItemSong");
	[self generateTextures];
	
	return self;
}

- (void) initTextualProperties:(NSString*)inMetricsKey {
	[super initTextualProperties:inMetricsKey];
	NSString* inFb = @"Common MenuItem";
	
	// Get font
	m_pFont = (Font*)[[FontManager sharedInstance] getFont:inMetricsKey];
	if(!m_pFont) {
		m_pFont = (Font*)[[FontManager sharedInstance] getFont:inFb];	
	}
}


- (void) dealloc {
	[m_pTitleStr release];
	[m_pArtistStr release];
	
	// Don't release the song
	TMLog(@"DEALLOC SONG PICKER MENU ITEM");
	
	[super dealloc];
}

- (void) generateTextures {		
	// The title must be taken from the song file
	NSString *titleStr = [NSString stringWithFormat:@"%@", m_pSong.m_sTitle];	
	NSString *artistStr = [NSString stringWithFormat:@"/%@", m_pSong.m_sArtist];

	m_pTitleStr = [[FontString alloc] initWithFont:@"SongPickerMenu WheelItem" andText:titleStr];
	m_pArtistStr = [[FontString alloc] initWithFont:@"SongPickerMenu WheelItem Artist" andText:artistStr]; 
}

/* TMRenderable stuff */
- (void) render:(float)fDelta {
	glEnable(GL_BLEND);
	[t_WheelItem drawAtPoint:m_rShape.origin];
	
	CGPoint leftCorner = CGPointMake(15.0f, m_rShape.origin.y+m_pTitleStr.contentSize.height/2-10);
	CGRect rectTitle, rectArtist;
	
	if(200.0f < m_pTitleStr.contentSize.width) {
		rectTitle = CGRectMake(leftCorner.x, leftCorner.y, 200.0f, m_pTitleStr.contentSize.height);
		
	} else {
		
		rectTitle = CGRectMake(leftCorner.x, leftCorner.y, m_pTitleStr.contentSize.width, m_pTitleStr.contentSize.height);
	}
	
	rectArtist = CGRectMake(leftCorner.x, leftCorner.y-18, m_pArtistStr.contentSize.width, m_pArtistStr.contentSize.height);
		
	[m_pTitleStr drawInRect:rectTitle];		
	[m_pArtistStr drawInRect:rectArtist];
	
	glDisable(GL_BLEND);
}

- (void) updateYPosition:(float)pixels {
	m_rShape.origin.y += pixels;
}

- (void) updateWithSong:(TMSong*)song atPoint:(CGPoint)point {
	m_rShape.origin = point; // We don't really use the size here
	m_pSong = song;	

	[m_pTitleStr updateText:m_pSong.m_sTitle];
	[m_pArtistStr updateText:[NSString stringWithFormat:@"/%@",m_pSong.m_sArtist]];
}

@end
