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

- (id) initWithShape:(CGRect) shape {
	self = [super initWithShape:shape];
	if(!self) 
		return nil;

	// Load effect sound
	sr_MenuButtonEffect = [[ThemeManager sharedInstance] sound:@"Common ButtonHit"];		
	
	return self;
}
	

- (id) initWithTitle:(NSString*) title andShape:(CGRect) shape {
	self = [self initWithShape:shape];
	if(!self) 
		return nil;
	
	m_fFontSize = 21.0f;
	m_sFontName = [@"Marker Felt" retain];
	m_Align = UITextAlignmentCenter;
	
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"Common MenuItem"];
	[self setName:title];
			
	return self;
}

- (id) initWithMetrics:(NSString*)inMetricsKey {
	self = [self initWithShape:RECT_METRIC(inMetricsKey)];
	if(!self) 
		return nil;

	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"Common MenuItem"];
	
	// Handle Font, FontSize, Align, Text
	m_fFontSize = FLOAT_METRIC(([NSString stringWithFormat:@"%@ FontSize", inMetricsKey]));
	if(m_fFontSize == 0.0f) {
		m_fFontSize = 21.0f;
	}
	
	NSString* align = STR_METRIC(([NSString stringWithFormat:@"%@ Align", inMetricsKey]));
	m_Align = UITextAlignmentCenter;	// Default
	
	if(align != nil) {
		if([align isEqualToString:@"Center"]) {
			m_Align = UITextAlignmentCenter;
		} else if([align isEqualToString:@"Left"]) {
			m_Align = UITextAlignmentLeft;
		} else if([align isEqualToString:@"Right"]) {
			m_Align = UITextAlignmentRight;
		}
	}	
	
	NSString* font = STR_METRIC(([NSString stringWithFormat:@"%@ Font", inMetricsKey]));
	if(font != nil) {
		m_sFontName = [font retain];
	} else {
		// TODO: change to default font name when will use font system
		m_sFontName = [@"Marker Felt" retain];
	}
	
	// Add commands support
	// Try to get the command list. can be omitted
	NSString* commandList = STR_METRIC([inMetricsKey stringByAppendingString:@" OnCommand"]);
	if([commandList length] > 0) {
		m_pCommandList = [[[CommandParser sharedInstance] createCommandListFromString:commandList forRequestingObject:self] retain];
	}
	
	return self;	
}

- (void) dealloc {
	if(m_sFontName) [m_sFontName release];
	if(m_sTitle) [m_sTitle release];
	if(m_pTitle) [m_pTitle release];
	
	[super dealloc];
}


- (void) setName:(NSString*)inName {
	if(m_sTitle) [m_sTitle release];
	if(m_pTitle) [m_pTitle release];
	
	m_sTitle = [inName copy];
	m_pTitle = [[Texture2D alloc] initWithString:m_sTitle dimensions:m_rShape.size alignment:m_Align fontName:m_sFontName fontSize:m_fFontSize];
}

/* TMRenderable stuff */
- (void) render:(float)fDelta {
	if(m_bVisible) {
		CGRect leftCapRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, 46.0f, m_rShape.size.height);
		CGRect rightCapRect = CGRectMake(m_rShape.origin.x+m_rShape.size.width-46.0f, m_rShape.origin.y, 46.0f, m_rShape.size.height);
		CGRect bodyRect = CGRectMake(m_rShape.origin.x+46.0f, m_rShape.origin.y, m_rShape.size.width-92.0f, m_rShape.size.height); 
		
		glEnable(GL_BLEND);
		[(TMFramedTexture*)m_pTexture drawFrame:0 inRect:leftCapRect];
		[(TMFramedTexture*)m_pTexture drawFrame:1 inRect:bodyRect];
		[(TMFramedTexture*)m_pTexture drawFrame:2 inRect:rightCapRect];
		
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
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

/* Override for sound effect */
- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {	
	if([super tmTouchesEnded:touches withEvent:event]) {
		TMLog(@"Menu item raised. play sound!");
		[[TMSoundEngine sharedInstance] playEffect:sr_MenuButtonEffect];
		
		return YES;
	}
	
	return NO;
}


@end
