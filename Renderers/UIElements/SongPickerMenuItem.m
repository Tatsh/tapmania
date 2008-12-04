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
#import "RenderEngine.h"

@implementation SongPickerMenuItem

@synthesize song;

- (id) initWithSong:(TMSong*) lSong andShape:(CGRect)lShape {
	self = [super init];
	if(!self) 
		return nil;
	
	shape = lShape;
	song = lSong;	
	
	// The title must be taken from the song file
	NSString *titleStr = [NSString stringWithFormat:@"%@ - %@", song.artist, song.title];
	
	[[RenderEngine sharedInstance].glView setCurrentContext];
	title = [[Texture2D alloc] initWithString:titleStr dimensions:shape.size alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:24.0f];
	
	return self;
}

- (void) dealloc {
	[title release];
	[song release];
	[super dealloc];
}

- (void) switchToSong:(TMSong*) lSong {
	[title release];	// Release old texture
	
	song = lSong;	
	NSString *titleStr = [NSString stringWithFormat:@"%@ - %@", song.artist, song.title];
	title = [[Texture2D alloc] initWithString:titleStr dimensions:shape.size alignment:UITextAlignmentLeft fontName:@"Arial" fontSize:24.0f];
}

/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	CGRect capRect = CGRectMake(shape.origin.x, shape.origin.y, 12.0f, shape.size.height);
	CGRect bodyRect = CGRectMake(shape.origin.x+12.0f, shape.origin.y, shape.size.width-12.0f, shape.size.height); 
	[(TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionWheelItem] drawFrame:0 inRect:capRect];
	[(TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionWheelItem] drawFrame:1 inRect:bodyRect];
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[title drawInRect:CGRectMake(bodyRect.origin.x, bodyRect.origin.y-8, bodyRect.size.width, bodyRect.size.height)];
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);		
}

@end
