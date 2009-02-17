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

@class Texture2D;

@interface MenuItem : AbstractRenderer <TMGameUIResponder, TMEffectSupport> {
	Texture2D*	m_pTexture;
	CGRect		m_rShape;	// The points where the button is drawn
	
	id			m_idDelegate;		// delegate to invoke the selector on
	SEL			m_oActionHandler;	// selector which should be invoked on button touch
}


- (id) initWithTexture:(Texture2D*) texture andShape:(CGRect) shape;

- (CGPoint) getPosition;
- (void) updatePosition:(CGPoint)point;

- (BOOL) containsPoint:(CGPoint)point;

- (void) setActionHandler:(SEL)selector receiver:(id)receiver;

@end
