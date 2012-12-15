//
//  $Id$
//  MenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MenuItem.h"
#import "TMFramedTexture.h"
#import "ThemeManager.h"
#import "Texture2D.h"
#import "Quad.h"
#import "Font.h"
#import "TMSound.h"
#import "TMSoundEngine.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "CommandParser.h"

@implementation MenuItem

- (id) initWithTitle:(NSString*) title andShape:(CGRect) shape {
	self = [self initWithShape:shape];
	if(!self) 
		return nil;
	
	m_bShouldLock = YES;
	
	[self initGraphicsAndSounds:@"Common MenuItem"];
	[self initTextualProperties:@"Common MenuItem"];
	[self setName:title];
			
	return self;
}

- (id) initWithMetrics:(NSString*)inMetricsKey {
	self = [super initWithShape:RECT_METRIC(inMetricsKey)];
	if(!self) 
		return nil;
	
	// Try to fetch extra width property
	m_FixedWidth =  FLOAT_METRIC( ([inMetricsKey stringByAppendingString:@" FixedWidth"]) );	// This is optional. will be 0 if not specified
	m_bShouldLock = ! BOOL_METRIC( ([inMetricsKey stringByAppendingString:@" ShouldNotLock"]) );
	
	// Get graphics and sounds used by this control
	[self initGraphicsAndSounds:inMetricsKey];
	
	// Add font stuff
	[self initTextualProperties:inMetricsKey];
	
	// Add commands support
	[super initCommands:inMetricsKey];
	
	return self;	
}

- (void) initGraphicsAndSounds:(NSString*)inMetricsKey {
	[super initGraphicsAndSounds:inMetricsKey];
	NSString* inFb = @"Common MenuItem";
	
	// Load texture
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:inMetricsKey];
	if(!m_pTexture) {
		m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:inFb];		
	}
}

- (void) initTextualProperties:(NSString*)inMetricsKey {
	[super initTextualProperties:inMetricsKey];
	NSString* inFb = @"Common MenuItem";
		
	// Get font
	m_pFont = (Font*)[[FontManager sharedInstance] getFont:inMetricsKey];
	if(!m_pFont) {
		m_pFont = (Font*)[[FontManager sharedInstance] getFont:inFb];	
	}
    if(!m_pFont) {
		m_pFont = (Font*)[[FontManager sharedInstance] defaultFont];
	}
}

// Override label's setName method
- (void) setName:(NSString*)inName {
	if(m_sTitle) [m_sTitle release];
	if(m_pTitle) [m_pTitle release];
	
	m_sTitle = [inName retain];
	m_pTitle = [m_pFont createQuadFromText:m_sTitle];
}


/* TMRenderable stuff */
- (void) render:(float)fDelta {
	if(m_bVisible) {
		// Calculate the width of the cap rects for the current height of the button
		float frameWidth = [m_pTexture contentSize].width  / [m_pTexture cols];
		float ratio = m_rShape.size.height / [m_pTexture contentSize].height;
		frameWidth *= ratio;
		
		CGRect leftCapRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, frameWidth, m_rShape.size.height);
		CGRect rightCapRect = CGRectMake(m_rShape.origin.x+m_rShape.size.width-frameWidth, m_rShape.origin.y, frameWidth, m_rShape.size.height);
		CGRect bodyRect = CGRectMake(m_rShape.origin.x+frameWidth, m_rShape.origin.y, m_rShape.size.width-frameWidth*2, m_rShape.size.height); 
		
		glEnable(GL_BLEND);
		[(TMFramedTexture*)m_pTexture drawFrame:0 inRect:leftCapRect];
		[(TMFramedTexture*)m_pTexture drawFrame:1 inRect:bodyRect];
		[(TMFramedTexture*)m_pTexture drawFrame:2 inRect:rightCapRect];

		CGPoint leftCorner = CGPointMake(m_rShape.origin.x+m_rShape.size.width/2, m_rShape.origin.y+m_rShape.size.height/2);
		if(m_FixedWidth > 0.0f) {
			leftCorner.x -= m_FixedWidth*ratio/2;
		} else {
			leftCorner.x -= m_pTitle.contentSize.width*ratio/2;
		}
		
		leftCorner.y -= m_pTitle.contentSize.height*ratio/2;
		
		CGRect rect;
		if(m_FixedWidth > 0.0f) {
			rect = CGRectMake(leftCorner.x, leftCorner.y, m_FixedWidth*ratio, m_pTitle.contentSize.height*ratio);
		} else {
			rect = CGRectMake(leftCorner.x, leftCorner.y, m_pTitle.contentSize.width*ratio, m_pTitle.contentSize.height*ratio);
		}
	
		[m_pTitle drawInRect:rect];		
		
		glDisable(GL_BLEND);
	}
}

- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {		
	BOOL res = [super tmTouchesEnded:touches withEvent:event];
	if(res && m_bShouldLock)
		[self disable];
	
	return res;
}

@end
