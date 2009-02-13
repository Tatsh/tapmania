//
//  SongPickerMenuSelectedItem.m
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuSelectedItem.h"
#import "TMFramedTexture.h"
#import "ThemeManager.h"

@implementation SongPickerMenuSelectedItem

TMFramedTexture* t_WheelItemSelected;
Texture2D* t_LoadingAvatar;

- (id) initWithSong:(TMSong*) song andShape:(CGRect)shape {
	self = [super initWithSong:song andShape:shape];
	if(!self) 
		return nil;
	
	// Cache texture
	t_WheelItemSelected = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"SongPicker Wheel ItemSelected"];
	t_LoadingAvatar = [[ThemeManager sharedInstance] texture:@"SongPicker Wheel LoadingAvatar"];
		
	return self;
}


/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	// TODO: metrics!
	
	CGRect capRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, 12.0f, m_rShape.size.height);
	CGRect bodyRect = CGRectMake(m_rShape.origin.x+12.0f, m_rShape.origin.y, m_rShape.size.width-12.0f, m_rShape.size.height); 
	
	glEnable(GL_BLEND);
	[t_WheelItemSelected drawFrame:0 inRect:capRect];
	[t_WheelItemSelected drawFrame:1 inRect:bodyRect];
	glDisable(GL_BLEND);
	
	[t_LoadingAvatar drawInRect:CGRectMake(bodyRect.origin.x+20.f, bodyRect.origin.y+19, 256.0f, 80.0f)];
}

@end
