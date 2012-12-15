//
//  $Id$
//  TogglerItem.m
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TogglerItem.h"
#import "TapMania.h"
#import "EAGLView.h"
#import "ThemeManager.h"
#import "CommandParser.h"
#import "FontManager.h"
#import "Font.h"

#import "Quad.h"
#import "TMFramedTexture.h"

@implementation TogglerItemObject

@synthesize m_pValue, m_sTitle, m_pText;

- (id) initWithTitle:(NSString*)lTitle value:(NSObject*)lValue size:(CGSize)size andFontSize:(float)fontSize {
	self = [self initWithSize:size andFontSize:fontSize];
	if(!self) 
		return nil;
		
	m_sTitle = [lTitle retain];
	m_pValue = [lValue retain];	
	m_pText = [m_pFont createQuadFromText:m_sTitle];
	
	return self;
}

- (id) initWithSize:(CGSize)size andFontSize:(float)fontSize {
	self = [super init];
	if(!self) 
		return nil;
	
	m_pCmdList = nil;
	m_sTitle = nil;
	m_pValue = nil;
	
	m_oSize = size;
	m_fFontSize = fontSize;
	m_Align = UITextAlignmentCenter;
	m_pFont = (Font*)[[FontManager sharedInstance] getFont:@"Common Toggler"];
    if(!m_pFont) {
		m_pFont = (Font*)[[FontManager sharedInstance] defaultFont];
	}
    
	m_pText = nil;
	
	return self;
}

// For the NameCommand
- (void) setName:(NSString*)inName {
	if(m_sTitle) {
		[m_sTitle release];
	}
	
	m_sTitle = [inName retain];
	
	if(m_pText) {
		[m_pText release];
	}
	
	m_pText = [m_pFont createQuadFromText:m_sTitle];
	
	// If the value isn't set yet - set it to the same as name
	if(!m_pValue) {
		m_pValue = [m_sTitle copy];
	}
}

- (void) setValue:(NSObject*)value {
	if(m_pValue) [m_pValue release];
	m_pValue = value;
}

- (void) setFont:(NSString*)inName {
	m_pFont = (Font*)[[FontManager sharedInstance] getFont:inName];
    if(!m_pFont) {
		m_pFont = (Font*)[[FontManager sharedInstance] defaultFont];
	}
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

- (void) setCmdList:(TMCommand*)inCmdList {
	m_pCmdList = inCmdList;
}

- (void) onSelect { 
	TMLog(@"Run onSelect command list for selected item with name: '%@'", m_sTitle);
	[[CommandParser sharedInstance] runCommandList:m_pCmdList forRequestingObject:self];
}

- (void) dealloc {
	[m_pText release];
	[m_sTitle release];
	if(m_pValue) [m_pValue release];
	[m_pCmdList release];
	[super dealloc];
}

@end


@implementation TogglerItem

- (id) initWithShape:(CGRect) shape {
	
	self = [super initWithShape:shape];
	if(!self)
		return nil;

	m_aElements = [[NSMutableArray alloc] initWithCapacity:10];
	m_nCurrentSelection = 0;

	[self initTextualProperties:@"Common Toggler"];
	[self initGraphicsAndSounds:@"Common Toggler"];
		
	return self;
}

- (id) initWithMetrics:(NSString*)inMetricsKey {
	self = [self initWithShape:RECT_METRIC(inMetricsKey)];
	if(!self)
		return nil;	
	
	// Try to fetch extra width property
	m_FixedWidth =  FLOAT_METRIC( ([inMetricsKey stringByAppendingString:@" FixedWidth"]) );	// This is optional. will be 0 if not specified
	
	// Get graphics/sounds
	[self initGraphicsAndSounds:inMetricsKey];
	
	// Add fonts stuff
	[self initTextualProperties:inMetricsKey];
	
	// Also handle Elements, DefaultElement
	[self setElementsWithMetric:[NSString stringWithFormat:@"%@ Elements", inMetricsKey]];
	
	// Add commands support
	[super initCommands:inMetricsKey];
	
	return self;
}

- (void) setElementsWithMetric:(NSString*)inMetricKey {
	[m_aElements removeAllObjects];
	
	NSArray* elements = ARRAY_METRIC(inMetricKey);
	if( elements != nil ) {
		
		for(NSString* cmdStr in elements) {
			TogglerItemObject* obj = [[TogglerItemObject alloc] initWithSize:m_rShape.size andFontSize:21.0f];
			TMCommand* cmdList = [[CommandParser sharedInstance] createCommandListFromString:cmdStr forRequestingObject:obj];
			[obj setCmdList:[cmdList retain]];
			
			[m_aElements addObject:obj];
		}
	}	
}

- (void) initTextualProperties:(NSString*)inMetricsKey {
	[super initTextualProperties:inMetricsKey];
	NSString* inFb = @"Common Toggler";
	
	// Get font
	m_pFont = (Font*)[[FontManager sharedInstance] getFont:inMetricsKey];
	if(!m_pFont) {
		m_pFont = (Font*)[[FontManager sharedInstance] getFont:inFb];	
	}
    if(!m_pFont) {
		m_pFont = (Font*)[[FontManager sharedInstance] defaultFont];
	}
}

- (void) initGraphicsAndSounds:(NSString*)inMetricsKey {
	[super initGraphicsAndSounds:inMetricsKey];
	NSString* inFb = @"Common Toggler";
	
	// Load texture
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:inMetricsKey];
	if(!m_pTexture) {
		m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:inFb];		
	}
}

- (void) dealloc {
	[self removeAll];
	[m_aElements release];
	[super dealloc];
}

- (void) addItem:(NSObject*)value withTitle:(NSString*)title {
	// TODO: Move things like font size to metrics
	TogglerItemObject* obj = [[TogglerItemObject alloc] initWithTitle:title value:value size:m_rShape.size andFontSize:21.0f];
	[m_aElements addObject:obj];	// Automatically retains
}

- (void) removeItemAtIndex:(int) index {
	[m_aElements removeObjectAtIndex:index];	// Automatically releases
	m_nCurrentSelection = 0;
}

- (void) removeAll {
	// Explicitly deallocate
	int i;
	
	for(i=0; i<[m_aElements count]; ++i) {
		[[m_aElements objectAtIndex:i] release];
	}
	
	[m_aElements removeAllObjects];
	m_nCurrentSelection = 0;
}

- (int) findIndexByValue:(NSObject*)value {
	int i;
	
	for(i=0; i<[m_aElements count]; ++i) {
		TogglerItemObject* elem = (TogglerItemObject*)[m_aElements objectAtIndex:i];
		if( [[elem m_pValue] isEqual:value] ) {
			return i;
		}
	}
	
	return -1;
}

- (void) selectItemAtIndex:(int) index {
	if(index >= 0 && index < [m_aElements count]) {
		m_nCurrentSelection = index;
		[[m_aElements objectAtIndex:index] onSelect];
	}
}

- (void) toggle {
	if([m_aElements count]-1 == m_nCurrentSelection) {
		m_nCurrentSelection = 0;
	} else {
		m_nCurrentSelection++;
	}
	
	[[m_aElements objectAtIndex:m_nCurrentSelection] onSelect];
}

- (TogglerItemObject*) getCurrent {
	if([m_aElements count] > 0) {
		TogglerItemObject* obj = [m_aElements objectAtIndex:m_nCurrentSelection];
		return obj;
	} 
	
	return nil;
}

- (int) getCurrentIndex {
	if([m_aElements count] > 0) {
		return m_nCurrentSelection;
	} 
	
	return -1;
}


- (void) invokeCurrentCommand {
	[[self getCurrent] onSelect];
}

- (void) setValue:(NSObject*)value {
	m_nCurrentSelection = 0;
	int tmp = 0;
	
	for(TogglerItemObject* obj in m_aElements) {
		BOOL found = NO;
		if([obj.m_pValue isKindOfClass:[NSString class]]) {
			if( [obj.m_pValue isEqualToString:value] ) 
				found = YES;
		} else if([obj.m_pValue isKindOfClass:[NSNumber class]]) {
			if( [obj.m_pValue isEqualToNumber:value] )
				found = YES;
		} else {
			TMLog(@"Class not supported by TogglerItem: %@", [obj.m_pValue name]);			
		}
		   
		if(found) {
			m_nCurrentSelection = tmp;
			TMLog(@"Found matching value in toggler at %d", m_nCurrentSelection);
			break;
		}

		++tmp;
	}
}


/* TMRenderable stuff */
- (void) render:(float)fDelta {	
	// Let the MenuItem class handle the drawing of the button shape
	[super render:fDelta];
	
	if(m_bVisible) {
		Quad* texture = [self getCurrent].m_pText;
		float ratio = m_rShape.size.height / [m_pTexture contentSize].height;
		
		glEnable(GL_BLEND);
		CGPoint leftCorner = CGPointMake(m_rShape.origin.x+m_rShape.size.width/2, m_rShape.origin.y+m_rShape.size.height/2);
		if(m_FixedWidth > 0.0f && m_FixedWidth < texture.contentSize.width) {
			leftCorner.x -= m_FixedWidth*ratio/2;
		} else {
			leftCorner.x -= texture.contentSize.width*ratio/2;
		}
		
		leftCorner.y -= texture.contentSize.height*ratio/2;
		
		CGRect rect;
		if(m_FixedWidth > 0.0f && m_FixedWidth < texture.contentSize.width) {
			rect = CGRectMake(leftCorner.x, leftCorner.y, m_FixedWidth*ratio, texture.contentSize.height*ratio);
		} else {
			rect = CGRectMake(leftCorner.x, leftCorner.y, texture.contentSize.width*ratio, texture.contentSize.height*ratio);
		}
		
		[texture drawInRect:rect];				
		glDisable(GL_BLEND);		
	}	
}

/* TMGameUIResponder method */
- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	if( [super isTouchInside:touches.at(0)] ) {
		TMLog(@"TogglerItem, finger raised!");
		
		[self toggle];		
		[super tmTouchesEnded:touches withEvent:event];
			
		return YES;			
	}
	
	return NO;
}


@end
