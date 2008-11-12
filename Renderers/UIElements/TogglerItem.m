//
//  TogglerItem.m
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "TogglerItem.h"

@implementation TogglerItemObject

@synthesize value, title;

- (id) initWithTitle:(NSString*)lTitle andValue:(NSObject*)lValue {
	self = [super init];
	if(!self) 
		return nil;
	
	title = lTitle;
	value = lValue;
	
	return self;
}

@end

@implementation TogglerItem

- (id) initWithElements:(NSArray*) arr {
	self = [super initWithTitle:@"toggler"];
	if(!self)
		return nil;
	
	elements = [[NSMutableArray alloc] initWithArray:arr];
	currentSelection = 0;
	
	// Set current title
	[self setTitle:[[self getCurrent] title] forState:UIControlStateNormal];
	
	[self addTarget:self action:@selector(togglerPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	return self;
}

- (void) dealloc {
	[elements release];
	[super dealloc];
}

- (void) toggle {
	if([elements count]-1 == currentSelection) {
		currentSelection = 0;
	} else {
		currentSelection++;
	}
}

- (TogglerItemObject*) getCurrent {
	TogglerItemObject* obj = [elements objectAtIndex:currentSelection];
	return obj;
}

#pragma mark Touch handling
- (void) togglerPressed:(id)sender {
	[self toggle];
	[self setTitle:[[self getCurrent] title] forState:UIControlStateNormal];
}

@end
