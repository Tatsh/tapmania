//
//  TogglerItem.m
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TogglerItem.h"
#import "TexturesHolder.h"
#import "TapMania.h"

@implementation TogglerItemObject

@synthesize value, title, text;

- (id) initWithTitle:(NSString*)lTitle andValue:(NSObject*)lValue {
	self = [super init];
	if(!self) 
		return nil;
	
	title = lTitle;
	value = lValue;
	
	text = [[Texture2D alloc] initWithString:title dimensions:CGSizeMake(60, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:21.0f];
	
	return self;
}

- (void) dealloc {
	[text release];
	[super dealloc];
}

@end

@implementation TogglerItem

- (id) initWithElements:(NSArray*) arr andShape:(CGRect) lShape {
	self = [super initWithTexture:kTexture_SongSelectionSpeedToggler andShape:lShape];
	if(!self)
		return nil;
	
	elements = [[NSMutableArray alloc] initWithArray:arr];
	currentSelection = 0;
		
	return self;
}

- (void) dealloc {
	[elements removeAllObjects];
	[elements release];
	[super dealloc];
}

- (void) toggle {
	if([elements count]-1 == currentSelection) {
		currentSelection = 0;
	} else {
		currentSelection++;
	}
}

- (TogglerItemObject*) getCurrent {
	TogglerItemObject* obj = [elements objectAtIndex:currentSelection];
	return obj;
}

/* TMRenderable stuff */
- (void) render:(NSNumber*)fDelta {
	CGRect leftCapRect = CGRectMake(shape.origin.x, shape.origin.y, 12.0f, shape.size.height);
	CGRect rightCapRect = CGRectMake(shape.origin.x+shape.size.width-12.0f, shape.origin.y, 12.0f, shape.size.height);
	CGRect bodyRect = CGRectMake(shape.origin.x+12.0f, shape.origin.y, shape.size.width-24.0f, shape.size.height); 

	[(TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:textureId] drawFrame:0 inRect:leftCapRect];
	[(TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:textureId] drawFrame:1 inRect:bodyRect];
	[(TMFramedTexture*)[[TexturesHolder sharedInstance] getTexture:textureId] drawFrame:2 inRect:rightCapRect];
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[[self getCurrent].text drawInRect:CGRectMake(bodyRect.origin.x, bodyRect.origin.y-8, bodyRect.size.width, bodyRect.size.height)];
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
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
