//
//  AbstractRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 05.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "AbstractRenderer.h"


@implementation AbstractRenderer

@synthesize glView;

- (id) initWithView:(EAGLView*)lGlView {
	self = [super init];
	if(!self)
		return nil;
	
	glView = lGlView;
	
	return self;
}

- (void) renderScene {
	NSException *ex = [NSException exceptionWithName:@"AbstractClass" 
									reason:@"You may not call renderScene on the abstract renderer class." userInfo:nil];
	@throw ex;
}

@end
