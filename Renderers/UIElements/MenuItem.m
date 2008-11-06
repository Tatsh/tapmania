//
//  MenuItem.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MenuItem.h"


@implementation MenuItem
 
- (id) initWithTitle:(NSString*) title {
	if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)]) { // The Y coordinate will change upon publish
		[self setTitle:title forState:UIControlStateNormal];
		[self setBackgroundColor:[UIColor clearColor]];	// Transparent background
		[self setFont:[UIFont fontWithName:@"Courier" size:21]];
		[self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
		[self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setTitleShadowOffset:CGSizeMake(2, 2)];
	}
	
	return self;
}

- (void)setPosition:(int)yPos {
	[self setFrame:CGRectMake(0.0f, yPos, 320.0f, 20.0f)]; 
}

- (void)dealloc {
	[super dealloc];
}


@end
