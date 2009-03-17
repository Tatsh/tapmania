//
//  SongPickerMenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuItem.h"
#import "Texture2D.h"

#import "TMSong.h"
#import "ThemeManager.h"
#import "TapMania.h"

@interface SongPickerMenuItem (Private)
- (void) generateTextures;
@end


@implementation SongPickerMenuItem

Texture2D* t_WheelItem;

@synthesize m_pSong;

- (id) initWithSong:(TMSong*) song atPoint:(CGPoint)point {
	self = [super init];
	if(!self) 
		return nil;
	
	m_rShape.origin = point; // We don't really use the size here
	m_pSong = song;	
	
	// Cache texture
	t_WheelItem = [[ThemeManager sharedInstance] texture:@"SongPicker Wheel ItemSong"];
	[self generateTextures];
	
	return self;
}

- (void) dealloc {
	[m_pTitle release];
	[m_pArtist release];
	
	// Don't release the song
	TMLog(@"DEALLOC SONG PICKER MENU ITEM");
	
	[super dealloc];
}

- (void) generateTextures {		
	// The title must be taken from the song file
	NSString *titleStr = [NSString stringWithFormat:@"%@", m_pSong.m_sTitle];	
	NSString *artistStr = [NSString stringWithFormat:@"/%@", m_pSong.m_sArtist];

	// TODO from metrics!
	float titleWidth = 280.0f;
	float titleHeight = 34.0f;
	float artistHeight = 12.0f;

	CGSize titleSize = CGSizeMake(titleWidth, titleHeight);
	CGSize artistSize = CGSizeMake(titleWidth, artistHeight); 

	m_pTitle = [[Texture2D alloc] initWithString:titleStr dimensions:titleSize alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:24.0f];
	m_pArtist = [[Texture2D alloc] initWithString:artistStr dimensions:artistSize alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:12.0f];
}

/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	glEnable(GL_BLEND);
	[t_WheelItem drawAtPoint:m_rShape.origin];
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[m_pTitle drawInRect:CGRectMake(15.0f, m_rShape.origin.y-20, 280.0f, 34.0f)];
	[m_pArtist drawInRect:CGRectMake(18.0f, m_rShape.origin.y-18, 280.0f, 12.0f)];
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);		
	glDisable(GL_BLEND);
}

- (void) updateYPosition:(float)pixels {
	m_rShape.origin.y += pixels;
}

@end
