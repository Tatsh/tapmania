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
	if (self = [super initWithFrame:CGRectMake(60.0f, 0.0f, 200.0f, 40.0f)]) { // The Y coordinate will change upon publish
		[self setTitle:title forState:UIControlStateNormal];
		[self setBackgroundColor:[UIColor clearColor]];	// Transparent background
		[self setBackgroundImage:[UIImage imageNamed:@"mainMenuItem.png"] forState:UIControlStateNormal];
		[self setFont:[UIFont fontWithName:@"Courier" size:21]];
		[self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
		[self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setTitleShadowOffset:CGSizeMake(2, 2)];
	}
	
	return self;
}

- (void)setPosition:(int)yPos {
	[self setFrame:CGRectMake(60.0f, yPos, 200.0f, 40.0f)]; 
}

- (void)dealloc {
	[super dealloc];
}


@end
