//
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
#import "TMSound.h"
#import "TMSoundEngine.h"

#import "TMFramedTexture.h"

@implementation TogglerItemObject

@synthesize m_pValue, m_sTitle, m_pText;

- (id) initWithTitle:(NSString*)lTitle value:(NSObject*)lValue size:(CGSize)size andFontSize:(float)fontSize {
	self = [self initWithSize:size andFontSize:fontSize];
	if(!self) 
		return nil;
		
	m_sTitle = [lTitle retain];
	m_pValue = [lValue retain];
	
	m_pText = [[Texture2D alloc] initWithString:m_sTitle dimensions:m_oSize alignment:m_Align fontName:m_sFontName fontSize:m_fFontSize];
	
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
	m_sFontName = [@"Marker Felt" retain];
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
	
	m_pText = [[Texture2D alloc] initWithString:m_sTitle dimensions:m_oSize alignment:m_Align fontName:m_sFontName fontSize:m_fFontSize];
	
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

- (void) setCmdList:(TMCommand*)inCmdList {
	m_pCmdList = inCmdList;
}

- (void) onSelect { 
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

	[self initGraphicsAndSounds:@"Common Toggler"];
	
	return self;
}

- (id) initWithMetrics:(NSString*)inMetricsKey {
	self = [self initWithShape:RECT_METRIC(inMetricsKey)];
	if(!self)
		return nil;	
	
	// Get graphics/sounds
	[self initGraphicsAndSounds:inMetricsKey];
	
	// Add fonts stuff
	[super initTextualProperties:inMetricsKey];
	
	// Also handle Elements, DefaultElement
	NSArray* elements = ARRAY_METRIC(([NSString stringWithFormat:@"%@ Elements", inMetricsKey]));
	if( elements != nil ) {
	
		for(NSString* cmdStr in elements) {
			TogglerItemObject* obj = [[TogglerItemObject alloc] initWithSize:m_rShape.size andFontSize:21.0f];
			TMCommand* cmdList = [[CommandParser sharedInstance] createCommandListFromString:cmdStr forRequestingObject:obj];
			[obj setCmdList:[cmdList retain]];
		
			[m_aElements addObject:obj];
		}
	}
	
	// Add commands support
	[super initCommands:inMetricsKey];
	
	return self;
}

- (void) initGraphicsAndSounds:(NSString*)inMetricsKey {
	[super initGraphicsAndSounds:inMetricsKey];
	NSString* inFb = @"Common Toggler";
	
	// Load effect sound
	sr_TogglerEffect = [[ThemeManager sharedInstance] sound:[NSString stringWithFormat:@"%@Change", inMetricsKey]];		
	if(!sr_TogglerEffect) {
		sr_TogglerEffect = [[ThemeManager sharedInstance] sound:[NSString stringWithFormat:@"%@Change", inFb]];				
	}
	
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
	[[TMSoundEngine sharedInstance] playEffect:sr_TogglerEffect];
}

- (TogglerItemObject*) getCurrent {
	if([m_aElements count] > 0) {
		TogglerItemObject* obj = [m_aElements objectAtIndex:m_nCurrentSelection];
		return obj;
	} 
	
	return nil;
}

- (void) setValue:(NSObject*)value {
	m_nCurrentSelection = 0;
	int tmp = 0;
	
	for(TogglerItemObject* obj in m_aElements) {
		if( [obj.m_pValue isEqualTo:value] ) {
			m_nCurrentSelection = tmp;
			TMLog(@"Found matching value in toggler at %d", m_nCurrentSelection);
			break;
		}

		++tmp;
	}
}


/* TMRenderable stuff */
- (void) render:(float)fDelta {
	CGRect leftCapRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, 46.0f, m_rShape.size.height);
	CGRect rightCapRect = CGRectMake(m_rShape.origin.x+m_rShape.size.width-46.0f, m_rShape.origin.y, 46.0f, m_rShape.size.height);
	CGRect bodyRect = CGRectMake(m_rShape.origin.x+46.0f, m_rShape.origin.y, m_rShape.size.width-92.0f, m_rShape.size.height); 

	glEnable(GL_BLEND);
	[(TMFramedTexture*)m_pTexture drawFrame:0 inRect:leftCapRect];
	[(TMFramedTexture*)m_pTexture drawFrame:1 inRect:bodyRect];
	[(TMFramedTexture*)m_pTexture drawFrame:2 inRect:rightCapRect];
	 
	if([self getCurrent]) {
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		[[self getCurrent].m_pText drawInRect:CGRectMake(m_rShape.origin.x, m_rShape.origin.y-12, m_rShape.size.width, m_rShape.size.height)];
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	glDisable(GL_BLEND);
}

/* TMGameUIResponder method */
- (BOOL) tmTouchesEnded:(const TMTouchesVec&)touches withEvent:(UIEvent*)event {
	TMTouch touch = touches.at(0);
	CGPoint point = CGPointMake(touch.x(), touch.y());
	
	if(CGRectContainsPoint(m_rShape, point)) {
		if(m_bEnabled && m_bVisible) {
			TMLog(@"TogglerItem, finger raised!");
			[self toggle];
			
			if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
				[m_idActionDelegate performSelector:m_oActionHandler];
			}	
			
			return YES;			
		}		
	}
	
	return NO;
}


@end
