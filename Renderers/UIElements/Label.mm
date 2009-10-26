//
//  Label.m
//  TapMania
//
//  Created by Alex Kremer on 5/17/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "Label.h"

#import "Texture2D.h"
#import "ThemeManager.h"

@implementation Label

- (id) initWithMetrics:(NSString*)inMetricsKey {
	self = [super initWithShape:RECT_METRIC(inMetricsKey)];
	if(!self)
		return nil;
	
	// Text props
	[self initTextualProperties:inMetricsKey];
	
	// Add commands
	[super initCommands:inMetricsKey];

	// Generate texture
	m_pTitle = [[Texture2D alloc] initWithString:m_sTitle dimensions:m_rShape.size alignment:m_Align fontName:m_sFontName fontSize:m_fFontSize];
	
	return self;
}

- (id) initWithTitle:(NSString*)title fontSize:(float)fontSize andShape:(CGRect) shape {
	self = [super initWithShape:shape];
	if(!self) 
		return nil;
	
	m_fFontSize = fontSize;
	
	m_pTitle = [[Texture2D alloc] initWithString:title dimensions:m_rShape.size alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:m_fFontSize];
	m_sTitle = title;
	
	return self;	
}

- (id) initWithTitle:(NSString*) title andShape:(CGRect) shape {
	self = [self initWithTitle:title fontSize:21.0f andShape:shape];
	return self;
}

- (void) initTextualProperties:(NSString*)inMetricsKey {
	// Handle Font, FontSize, Align defaults
	m_fFontSize = 21.0f;
	m_Align = UITextAlignmentCenter;
	
	// TODO: change to default font name when will use font system
	m_sFontName = [@"Marker Felt" retain];
}

- (void) dealloc {
	[m_sTitle release];
	[m_sFontName release];
	[m_pTitle release];
	
	[super dealloc];
}

- (void) setName:(NSString*)inName {
	if(m_sTitle) [m_sTitle release];
	if(m_pTitle) [m_pTitle release];
	
	m_sTitle = [inName retain];
	m_pTitle = [[Texture2D alloc] initWithString:m_sTitle dimensions:m_rShape.size alignment:m_Align fontName:m_sFontName fontSize:m_fFontSize];
}

- (void) setFont:(NSString*)inName {
	if(m_sFontName) [m_sFontName release];
	m_sFontName = [inName retain];	
}

- (void) setFontSize:(NSNumber*)inSize {
	m_fFontSize = [inSize floatValue];
}

- (void) setAlignment:(NSString*)inAlign {
	if(inAlign != nil) {
		if([[inAlign lowercaseString] isEqualToString:@"center"]) {
			m_Align = UITextAlignmentCenter;
		} else if([[inAlign lowercaseString] isEqualToString:@"left"]) {
			m_Align = UITextAlignmentLeft;
		} else if([[inAlign lowercaseString] isEqualToString:@"right"]) {
			m_Align = UITextAlignmentRight;
		}
	}	
}

/* TMRenderable stuff */
- (void) render:(float)fDelta {
	glEnable(GL_BLEND);	
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

@end
