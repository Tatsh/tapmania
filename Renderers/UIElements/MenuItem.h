//
//  MenuItem.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractRenderer.h"
#import "TMGameUIResponder.h"
#import "TMEffectSupport.h"

@class TMFramedTexture, Texture2D;

@interface MenuItem : AbstractRenderer <TMGameUIResponder, TMEffectSupport> {
	TMFramedTexture*	m_pTexture;
	Texture2D*			m_pTitle;
	CGRect		m_rShape;	// The points where the button is drawn
	
	id			m_idDelegate;		// delegate to invoke the selector on
	SEL			m_oActionHandler;	// selector which should be invoked on button touch
}


- (id) initWithTitle:(NSString*)title andShape:(CGRect) shape;

- (CGPoint) getPosition;
- (void) updatePosition:(CGPoint)point;

- (BOOL) containsPoint:(CGPoint)point;

- (void) setActionHandler:(SEL)selector receiver:(id)receiver;

@end
