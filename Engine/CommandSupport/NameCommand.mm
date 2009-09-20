//
//  NameCommand.mm
//  TapMania
//
//  Created by Alex Kremer on 9/20/09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "NameCommand.h"

@implementation NameCommand

- (BOOL) invokeAtConstructionOnObject:(NSObject*)inObj {
	if([inObj respondsToSelector:@selector(setName:)]) {
		[inObj performSelector:@selector(setName:) withObject:[m_aArguments objectAtIndex:0]];
		return YES;
	}
	
	return NO;
}

@end
