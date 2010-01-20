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
	[m_pArtist release];
	
	// Don't release the song
	TMLog(@"DEALLOC SONG PICKER MENU ITEM");
	
	[super dealloc];
}

- (void) generateTextures {		
	// The title must be taken from the song file
	NSString *titleStr = [NSString stringWithFormat:@"%@", m_pSong.m_sTitle];	
//	NSString *artistStr = [NSString stringWithFormat:@"/%@", m_pSong.m_sArtist];

	m_pTitle = [m_pFont createQuadFromText:titleStr];
	
	// [[Texture2D alloc] initWithString:titleStr dimensions:titleSize alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:24.0f];
//	m_pArtist = 
	//[[Texture2D alloc] initWithString:artistStr dimensions:artistSize alignment:UITextAlignmentLeft fontName:@"Marker Felt" fontSize:12.0f];
}

/* TMRenderable stuff */
- (void) render:(float)fDelta {
	glEnable(GL_BLEND);
	[t_WheelItem drawAtPoint:m_rShape.origin];
	
	CGPoint leftCorner = CGPointMake(15.0f, m_rShape.origin.y-m_pTitle.contentSize.height/2 + 8);
	CGRect rect;
	
	if(200.0f < m_pTitle.contentSize.width) {
		rect = CGRectMake(leftCorner.x, leftCorner.y, 200.0f, m_pTitle.contentSize.height);
		
	} else {
		rect = CGRectMake(leftCorner.x, leftCorner.y, m_pTitle.contentSize.width, m_pTitle.contentSize.height);
		
	}
		
	[m_pTitle drawInRect:rect];		
	
	glDisable(GL_BLEND);
}

- (void) updateYPosition:(float)pixels {
	m_rShape.origin.y += pixels;
}

- (void) updateWithSong:(TMSong*)song atPoint:(CGPoint)point {
	m_rShape.origin = point; // We don't really use the size here
	m_pSong = song;	
	
	// Redo the texture
	[m_pTitle release];
	[m_pArtist release];

	[self generateTextures];	
}

@end
