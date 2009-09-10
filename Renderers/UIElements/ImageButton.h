//
//  ImageButton.h
//  TapMania
//
//  Created by Alex Kremer on 5/27/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMRenderable.h"
#import "TMGameUIResponder.h"
#import "TMEffectSupport.h"

@class TMFramedTexture, Texture2D;

@interface ImageButton : NSObject <TMRenderable, TMGameUIResponder, TMEffectSupport> {
	Texture2D*			m_pTexture;
	CGRect		m_rShape;	// The points where the button is drawn
	
	id			m_idActionDelegate;			// delegate to invoke the selector on
	SEL			m_oActionHandler;			// selector which should be invoked on button touch
	
	id			m_idChangedDelegate;		// delegate to invoke the selector on
	SEL			m_oChangedActionHandler;	// selector which should be invoked on finger drag over the button
}


- (id) initWithTexture:(Texture2D*)tex andShape:(CGRect) shape;

- (CGPoint) getPosition;
- (void) updatePosition:(CGPoint)point;

- (BOOL) containsPoint:(CGPoint)point;

- (void) setActionHandler:(SEL)selector receiver:(id)receiver;
- (void) setChangedActionHandler:(SEL)selector receiver:(id)receiver;

@end
