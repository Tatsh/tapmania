//
//  MenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMGameUIResponder.h"
#import "TMRenderable.h"
#import "TMEffectSupport.h"

@class TMFramedTexture, Texture2D;

@interface MenuItem : NSObject <TMRenderable, TMGameUIResponder, TMEffectSupport> {
	TMFramedTexture*	m_pTexture;
	Texture2D*			m_pTitle;
	NSString*			m_sTitle;
	CGRect		m_rShape;	// The points where the button is drawn
	BOOL		m_bEnabled;
	BOOL		m_bVisible;
	
	id			m_idActionDelegate;			// delegate to invoke the selector on
	SEL			m_oActionHandler;			// selector which should be invoked on button touch
	
	id			m_idChangedDelegate;		// delegate to invoke the selector on
	SEL			m_oChangedActionHandler;	// selector which should be invoked on finger drag over the menu item
}


- (id) initWithTitle:(NSString*)title andShape:(CGRect) shape;

- (void) disable;
- (void) enable;

- (void) show;
- (void) hide;

- (CGPoint) getPosition;
- (void) updatePosition:(CGPoint)point;

- (BOOL) containsPoint:(CGPoint)point;

- (void) setActionHandler:(SEL)selector receiver:(id)receiver;
- (void) setChangedActionHandler:(SEL)selector receiver:(id)receiver;

@end
