//
//  $Id$
//  TMModalView.mm
//  TapMania
//
//  Created by Alex Kremer on 17.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMModalView.h"
#import "InputEngine.h"
#import "TapMania.h"

@implementation TMModalView

- (id) initWithShape:(CGRect)inShape {
	self = [super initWithShape:inShape];
	if(!self) 
		return nil;
	
	[[InputEngine sharedInstance] subscribe:self];
	
	return self;
}

- (void) close {
	[[InputEngine sharedInstance] unsubscribe:self];
	[[TapMania sharedInstance] performSelectorOnMainThread:@selector(removeOverlay:) withObject:self waitUntilDone:NO];	
}

@end
