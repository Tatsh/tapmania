//
//  AbstractMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "AbstractMenuRenderer.h"
#import "MenuItem.h"

@implementation AbstractMenuRenderer

- (id) initWithView:(EAGLView*)lGlView andCapacity:(int)capacity {
	self = [super initWithView:lGlView];
	if(!self)
		return nil;
	
	// Construct the menu
	_menuElements = [[NSMutableArray arrayWithCapacity:capacity] retain];
	
	return self;
}

- (void) addMenuItemWithTitle:(NSString*) title andHandler:(SEL)sel onTarget:(id)target {
	MenuItem* newItem = [[MenuItem alloc] initWithTitle:title];
	
	// Register callback
	[newItem addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
	
	[_menuElements addObject:newItem];
}

// Call this to publish the whole menu
- (void) publishMenu {
	
	_curPos = [_menuElements count] * 30;	// Height of each item + offset 10px
	_curPos = (glView.bounds.size.height - _curPos) / 2;
	
	for(int i=0; i<[_menuElements count]; i++) {
		MenuItem* item = [_menuElements objectAtIndex:i];
		[item setPosition:_curPos];
		
		[glView addSubview:item];	
		
		_curPos += 30;
	}
}

- (void) dealloc {
	
	for(int i=0; i<[_menuElements count]; i++) {
		[[_menuElements objectAtIndex:i] removeFromSuperview];
		[[_menuElements objectAtIndex:i] release];
	}
	
	[_menuElements release];
	
	[super dealloc];
}

@end
