//
//  TMControl.h
//  TapMania
//
//  Created by Alex Kremer on 16.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMRenderable.h"
#import "TMLogicUpdater.h"
#import "TMEffectSupport.h"
#import "TMGameUIResponder.h"

@interface TMControl : NSObject <TMRenderable, TMLogicUpdater, TMEffectSupport, TMGameUIResponder> {
	CGRect		m_rShape;	// The points where the button is drawn
	BOOL		m_bEnabled;
	BOOL		m_bVisible;
	
	id			m_idActionDelegate;			// delegate to invoke the selector on
	SEL			m_oActionHandler;			// selector which should be invoked on control touch
	
	id			m_idChangedDelegate;		// delegate to invoke the selector on
	SEL			m_oChangedActionHandler;	// selector which should be invoked on finger drag over the control	
}

- (id) initWithShape:(CGRect)inShape;

- (BOOL) containsPoint:(CGPoint)point;

- (void) disable;
- (void) enable;

- (void) show;
- (void) hide;

- (void) setActionHandler:(SEL)selector receiver:(id)receiver;
- (void) setChangedActionHandler:(SEL)selector receiver:(id)receiver;

@end
