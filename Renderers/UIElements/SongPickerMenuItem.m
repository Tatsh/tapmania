//
//  SongPickerMenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 10.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuItem.h"
#import "TMFramedTexture.h"
#import "TexturesHolder.h"
#import "TapMania.h"

@implementation SongPickerMenuItem

@synthesize m_pSong;

- (id) initWithSong:(TMSong*) song andShape:(CGRect)shape {
	self = [super init];
	if(!self) 
		return nil;
	
	m_rShape = shape;
	m_pSong = song;	
	
	// The title must be taken from the song file
	NSString *titleStr = [NSString stringWithFormat:@"%@ - %@", m_pSong.m_sArtist, m_pSong.m_sTitle];
	
	m_pTitle = [[Texture2D alloc] initWithString:titleStr dimensions:m_rShape.size alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:24.0f];
	
	return self;
}

- (void) dealloc {
	[m_pTitle release];
	[m_pSong release];
	[super dealloc];
}

- (void) switchToSong:(TMSong*) song {
	[m_pTitle release];	// Release old texture
	
	m_pSong = song;	
	NSString *titleStr = [NSString stringWithFormat:@"%@ - %@", m_pSong.m_sArtist, m_pSong.m_sTitle];
	m_pTitle = [[Texture2D alloc] initWithString:titleStr dimensions:m_rShape.size alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:24.0f];
}

/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	CGRect capRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, 12.0f, m_rShape.size.height);
	CGRect bodyRect = CGRectMake(m_rShape.origin.x+12.0f, m_rShape.origin.y, m_rShape.size.width-12.0f, m_rShape.size.height); 
	[(TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionWheelItem] drawFrame:0 inRect:capRect];
	[(TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionWheelItem] drawFrame:1 inRect:bodyRect];
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[m_pTitle drawInRect:CGRectMake(bodyRect.origin.x, bodyRect.origin.y-8, bodyRect.size.width, bodyRect.size.height)];
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);		
}

@end
