//
//  TMControl.h
//  TapMania
//
//  Created by Alex Kremer on 16.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMEffectSupport.h"
#import "TMView.h"

/* A control is a view that can be pressed and that supports all kind of control effects */
@interface TMControl : TMView <TMEffectSupport> {
	id			m_idActionDelegate;			// delegate to invoke the selector on
	SEL			m_oActionHandler;			// selector which should be invoked on control touch
	
	id			m_idChangedDelegate;		// delegate to invoke the selector on
	SEL			m_oChangedActionHandler;	// selector which should be invoked on finger drag over the control	
}

- (void) setActionHandler:(SEL)selector receiver:(id)receiver;
- (void) setChangedActionHandler:(SEL)selector receiver:(id)receiver;

@end
