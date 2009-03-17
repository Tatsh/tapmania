//
//  AbstractRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "AbstractRenderer.h"


@implementation AbstractRenderer

- (void) render:(float)fDelta {
	NSException *ex = [NSException exceptionWithName:@"AbstractClass" 
											  reason:@"You may not call render on the abstract renderer class." userInfo:nil];
	@throw ex;
}

@end
