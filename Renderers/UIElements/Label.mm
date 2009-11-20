//
//  $Id$
//  Label.m
//  TapMania
//
//  Created by Alex Kremer on 5/17/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "Label.h"

#import "Texture2D.h"
#import "FontManager.h"
#import "Font.h"
#import "ThemeManager.h"
#import "Quad.h"

@implementation Label

- (id) initWithMetrics:(NSString*)inMetricsKey {
	CGPoint point = POINT_METRIC(inMetricsKey);
	self = [super initWithShape:CGRectMake(point.x, point.y, 0, 0)];
	if(!self)
		return nil;
	
	// Text props
	[self initTextualProperties:inMetricsKey];
	
	// Add commands
	[super initCommands:inMetricsKey];

	// Generate texture
	m_pTitle = 	[m_pFont createQuadFromText:m_sTitle];	
	m_rShape.size.width = m_pTitle.contentSize.width;
	m_rShape.size.height = m_pTitle.contentSize.height;
	
	return self;
}

- (id) initWithTitle:(NSString*)title fontSize:(float)fontSize andShape:(CGRect) shape {
	self = [super initWithShape:shape];
	if(!self) 
		return nil;
	
	m_fFontSize = fontSize;
	
	m_sTitle = title;
	m_pTitle = 	[m_pFont createQuadFromText:title];	
	m_rShape.size.width = m_pTitle.contentSize.width;
	m_rShape.size.height = m_pTitle.contentSize.height;
	
	return self;	
}

- (id) initWithTitle:(NSString*) title andShape:(CGRect) shape {
	self = [self initWithTitle:title fontSize:21.0f andShape:shape];
	return self;
}

- (void) initTextualProperties:(NSString*)inMetricsKey {
	NSString* inFb = @"Common Label";

	// Handle Font, FontSize, Align defaults
	m_fFontSize = 21.0f;	// TODO: change and use
	m_Align = UITextAlignmentCenter;
	
	// Get font
	m_pFont = (Font*)[[FontManager sharedInstance] getFont:inMetricsKey];
	if(!m_pFont) {
		m_pFont = (Font*)[[FontManager sharedInstance] getFont:inFb];	
	}
}

- (void) dealloc {
	[m_sTitle release];
	if(m_pTitle) [m_pTitle release];
	
	[super dealloc];
}

- (void) setName:(NSString*)inName {
	if(m_sTitle) [m_sTitle release];
	if(m_pTitle) [m_pTitle release];
	
	m_sTitle = [inName retain];
	m_pTitle = 	[m_pFont createQuadFromText:m_sTitle];
	m_rShape.size.width = m_pTitle.contentSize.width;
	m_rShape.size.height = m_pTitle.contentSize.height;
}

- (void) setFont:(NSString*)inName {
	m_pFont = (Font*)[[FontManager sharedInstance] getFont:inName];
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
	
	// The position is determined by the alignment
	CGPoint point;
	
	switch(m_Align) {
		case UITextAlignmentLeft:
			point = CGPointMake(m_rShape.origin.x, m_rShape.origin.y-m_rShape.size.height/2);			
			break;
		case UITextAlignmentRight:
			point = CGPointMake(m_rShape.origin.x-m_rShape.size.width, m_rShape.origin.y-m_rShape.size.height/2);
			break;
		case UITextAlignmentCenter:
		default:
			point = CGPointMake(m_rShape.origin.x-m_rShape.size.width/2, m_rShape.origin.y-m_rShape.size.height/2);
			break;
	}
	
	CGRect rect = CGRectMake(point.x, point.y, m_rShape.size.width, m_rShape.size.height);
	[m_pTitle drawInRect:rect];		

	glDisable(GL_BLEND);
}

@end
