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

@synthesize m_pValue, m_sTitle, m_pText;

- (id) initWithTitle:(NSString*)lTitle value:(NSObject*)lValue size:(CGSize)size andFontSize:(float)fontSize {
	self = [super init];
	if(!self) 
		return nil;
		
	m_sTitle = [lTitle retain];
	m_pValue = [lValue retain];
	
	m_pText = [[Texture2D alloc] initWithString:m_sTitle dimensions:size alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:fontSize];
	
	return self;
}

- (void) dealloc {
	[m_pText release];
	[m_sTitle release];
	[m_pValue release];
	[super dealloc];
}

@end


@implementation TogglerItem

- (id) initWithShape:(CGRect) shape {
	
	self = [super initWithTitle:@"Not used" andShape:shape];
	if(!self)
		return nil;

	m_aElements = [[NSMutableArray alloc] initWithCapacity:10];
	m_nCurrentSelection = 0;
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"Common Toggler"];	
	
	return self;
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

- (void) toggle {
	if([m_aElements count]-1 == m_nCurrentSelection) {
		m_nCurrentSelection = 0;
	} else {
		m_nCurrentSelection++;
	}
}

- (TogglerItemObject*) getCurrent {
	if([m_aElements count] > 0) {
		TogglerItemObject* obj = [m_aElements objectAtIndex:m_nCurrentSelection];
		return obj;
	} 
	
	return nil;
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
