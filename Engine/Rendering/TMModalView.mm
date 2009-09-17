//
//  TMModalView.mm
//  TapMania
//
//  Created by Alex Kremer on 17.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMModalView.h"
#import "InputEngine.h"

@implementation TMModalView

/* TMTransitionSupport methods */
- (void) setupForTransition {
	[[InputEngine sharedInstance] subscribe:self];
}

- (void) deinitOnTransition {
	[[InputEngine sharedInstance] unsubscribe:self];
}

@end
