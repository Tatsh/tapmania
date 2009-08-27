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

@implementation MenuItem

TMSound*	sr_MenuButtonEffect;

- (id) initWithTitle:(NSString*) title andShape:(CGRect) shape {
	self = [super init];
	if(!self) 
		return nil;
	
	m_rShape = shape;
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"Common MenuItem"];
	m_pTitle = [[Texture2D alloc] initWithString:title dimensions:m_rShape.size alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:21.0f];
	m_sTitle = title;
	
	m_idActionDelegate = nil;
	m_oActionHandler = nil;
	m_oChangedActionHandler = nil;
	
	m_bEnabled = YES;
	
	// Load effect sound
	sr_MenuButtonEffect = [[ThemeManager sharedInstance] sound:@"Common ButtonHit"];
	
	return self;
}

- (void) disable {
	m_bEnabled = NO;
}

- (void) enable {
	m_bEnabled = YES;
}

- (BOOL) containsPoint:(CGPoint)point {
	return CGRectContainsPoint(m_rShape, point);
}

- (void) setActionHandler:(SEL)selector receiver:(id)receiver {
	m_idActionDelegate = receiver;
	m_oActionHandler = selector;
}

- (void) setChangedActionHandler:(SEL)selector receiver:(id)receiver {
	m_idChangedDelegate = receiver;
	m_oChangedActionHandler = selector;
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

/* TMGameUIResponder stuff */
- (void) tmTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
							[touch locationInView:[TapMania sharedInstance].glView]];

		if(CGRectContainsPoint(m_rShape, point)) {
			if(m_bEnabled) {
				TMLog(@"Menu item hit!");
			}
		}
	}
}

- (void) tmTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idChangedDelegate != nil && [m_idChangedDelegate respondsToSelector:m_oChangedActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			if(m_bEnabled) {
				[m_idChangedDelegate performSelector:m_oChangedActionHandler];
			}
		}
	}
}

- (void) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {	
	if(m_idActionDelegate != nil && [m_idActionDelegate respondsToSelector:m_oActionHandler]) {
		UITouch * touch = [touches anyObject];
		CGPoint point = [[TapMania sharedInstance].glView convertPointFromViewToOpenGL:
						 [touch locationInView:[TapMania sharedInstance].glView]];
		
		if(CGRectContainsPoint(m_rShape, point)) {
			if(m_bEnabled) {
				TMLog(@"Menu item finger raised!");
				[m_idActionDelegate performSelector:m_oActionHandler];
				[[TMSoundEngine sharedInstance] playEffect:sr_MenuButtonEffect];
			}
		}
	}
}

/* TMEffectSupport stuff */
- (CGPoint) getPosition {
	return m_rShape.origin;
}

- (void) updatePosition:(CGPoint)point {
	m_rShape.origin.x = point.x;
	m_rShape.origin.y = point.y;
}

- (CGRect) getShape {
	return m_rShape;
}

- (void) updateShape:(CGRect)shape {
	m_rShape.origin = shape.origin;
	m_rShape.size = shape.size;
}

@end
