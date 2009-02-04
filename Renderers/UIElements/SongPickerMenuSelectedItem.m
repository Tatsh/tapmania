//
//  SongPickerMenuSelectedItem.m
//  TapMania
//
//  Created by Alex Kremer on 04.12.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "SongPickerMenuSelectedItem.h"
#import "TMFramedTexture.h"
#import "TexturesHolder.h"

@implementation SongPickerMenuSelectedItem

/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	CGRect capRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, 12.0f, m_rShape.size.height);
	CGRect bodyRect = CGRectMake(m_rShape.origin.x+12.0f, m_rShape.origin.y, m_rShape.size.width-12.0f, m_rShape.size.height); 
	[(TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionWheelItemSelected] drawFrame:0 inRect:capRect];
	[(TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionWheelItemSelected] drawFrame:1 inRect:bodyRect];
	
	[[[TexturesHolder sharedInstance] getTexture:kTexture_SongSelectionWheelLoadingAvatar] drawInRect:CGRectMake(bodyRect.origin.x+20.f, bodyRect.origin.y+19, 256.0f, 80.0f)];
}

@end
