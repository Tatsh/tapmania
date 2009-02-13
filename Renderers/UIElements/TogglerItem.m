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

#import "TMFramedTexture.h"

@implementation TogglerItemObject

TMFramedTexture* t_TogglerItem;

@synthesize m_pValue, m_sTitle, m_pText;

- (id) initWithTitle:(NSString*)lTitle andValue:(NSObject*)lValue {
	self = [super init];
	if(!self) 
		return nil;
	
	// Cache graphics
	// FIXME: move to common UI theme or something like that
	t_TogglerItem = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"SongPicker SpeedToggler"];
	
	m_sTitle = lTitle;
	m_pValue = lValue;
	
	// FIXME: Move this to metrics
	m_pText = [[Texture2D alloc] initWithString:m_sTitle dimensions:CGSizeMake(60, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:21.0f];
	
	return self;
}

- (void) dealloc {
	[m_pText release];
	[super dealloc];
}

@end

@implementation TogglerItem

- (id) initWithElements:(NSArray*) arr andShape:(CGRect) shape {
	self = [super initWithTexture:t_TogglerItem andShape:shape];
	if(!self)
		return nil;
	
	m_aElements = [[NSMutableArray alloc] initWithArray:arr];
	m_nCurrentSelection = 0;
		
	return self;
}

- (void) dealloc {
	[m_aElements removeAllObjects];
	[m_aElements release];
	[super dealloc];
}

- (void) toggle {
	if([m_aElements count]-1 == m_nCurrentSelection) {
		m_nCurrentSelection = 0;
	} else {
		m_nCurrentSelection++;
	}
}

- (TogglerItemObject*) getCurrent {
	TogglerItemObject* obj = [m_aElements objectAtIndex:m_nCurrentSelection];
	return obj;
}

/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	CGRect leftCapRect = CGRectMake(m_rShape.origin.x, m_rShape.origin.y, 12.0f, m_rShape.size.height);
	CGRect rightCapRect = CGRectMake(m_rShape.origin.x+m_rShape.size.width-12.0f, m_rShape.origin.y, 12.0f, m_rShape.size.height);
	CGRect bodyRect = CGRectMake(m_rShape.origin.x+12.0f, m_rShape.origin.y, m_rShape.size.width-24.0f, m_rShape.size.height); 

	glEnable(GL_BLEND);
	[(TMFramedTexture*)m_pTexture drawFrame:0 inRect:leftCapRect];
	[(TMFramedTexture*)m_pTexture drawFrame:1 inRect:bodyRect];
	[(TMFramedTexture*)m_pTexture drawFrame:2 inRect:rightCapRect];
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[[self getCurrent].m_pText drawInRect:CGRectMake(bodyRect.origin.x, bodyRect.origin.y-8, bodyRect.size.width, bodyRect.size.height)];
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_BLEND);
}

/* TMGameUIResponder method */
- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *t1 = [[touches allObjects] objectAtIndex:0];
	
	if([touches count] == 1){
		
		CGPoint pos = [t1 locationInView:[TapMania sharedInstance].glView];
		CGPoint pointGl = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:pos];
		
		if([self containsPoint:pointGl]) {
			[self toggle];
		}
	}
}


@end
