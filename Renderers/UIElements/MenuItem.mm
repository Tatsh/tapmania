//
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
	
	m_fFontSize = 21.0f;
	m_sFontName = [@"Marker Felt" retain];
	m_Align = UITextAlignmentCenter;
	
	[self initGraphicsAndSounds:@"Common MenuItem"];
	[self setName:title];
			
	return self;
}

- (id) initWithMetrics:(NSString*)inMetricsKey {
	self = [super initWithShape:RECT_METRIC(inMetricsKey)];
	if(!self) 
		return nil;
	
	// Get graphics and sounds used by this control
	[self initGraphicsAndSounds:inMetricsKey];
	
	// Add font stuff
	[super initTextualProperties:inMetricsKey];
	
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
		
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		// TODO: fix font issues (12 is no good here)
		[m_pTitle drawInRect:CGRectMake(m_rShape.origin.x, m_rShape.origin.y-12, m_rShape.size.width, m_rShape.size.height)];
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		
		/*
		 TODO: Use our fonts later
		float vCenter = m_rShape.origin.y + m_rShape.size.height/2;
		float hCenter = m_rShape.origin.x + m_rShape.size.width/2;
		float strWidth = [[FontManager sharedInstance] getStringWidth:m_sTitle usingFont:@"MainMenuButtons"];
		float xPos = hCenter-strWidth/2;
		float yPos = vCenter;
			
		[[FontManager sharedInstance] print:m_sTitle
					  usingFont:@"MainMenuButtons" atPoint:CGPointMake(xPos, yPos)];
		*/
		
		glDisable(GL_BLEND);
	}
}

@end
