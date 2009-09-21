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

- (id) initWithTitle:(NSString*) title andShape:(CGRect) shape {
	self = [super initWithShape:shape];
	if(!self) 
		return nil;
	
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"Common MenuItem"];
	[self setName:title];
	
	// Load effect sound
	sr_MenuButtonEffect = [[ThemeManager sharedInstance] sound:@"Common ButtonHit"];
	
	return self;
}

- (id) initWithMetrics:(NSString*)inMetrics {
	self = [super initWithMetrics:inMetrics];
	if(!self) 
		return nil;
	
	m_pTexture = (TMFramedTexture*)[[ThemeManager sharedInstance] texture:@"Common MenuItem"];
	
	// Load effect sound
	sr_MenuButtonEffect = [[ThemeManager sharedInstance] sound:@"Common ButtonHit"];
	
	return self;	
}

- (void) setName:(NSString*)inName {
	if(m_sTitle) [m_sTitle release];
	if(m_pTitle) [m_pTitle release];
	
	m_sTitle = [inName copy];
	m_pTitle = [[Texture2D alloc] initWithString:m_sTitle dimensions:m_rShape.size alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:21.0f];
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
- (BOOL) tmTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {	
	if([super tmTouchesEnded:touches withEvent:event]) {
		TMLog(@"Menu item raised. play sound!");
		[[TMSoundEngine sharedInstance] playEffect:sr_MenuButtonEffect];
		
		return YES;
	}
	
	return NO;
}


@end
