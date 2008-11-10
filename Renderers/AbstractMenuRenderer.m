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
	
	_backButtonUsed = NO;
	
	// Construct the menu
	_menuElements = [[NSMutableArray arrayWithCapacity:capacity] retain];
	
	return self;
}

- (void) enableBackButton {
	_backButtonUsed = YES;
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
	
	int i;
	for(i=0; i<[_menuElements count]; i++) {
		MenuItem* item = [_menuElements objectAtIndex:i];
		[item setPosition:_curPos];
		
		[glView addSubview:item];	
		
		_curPos += 30;
	}
	
	// Add back button if needed
	if(_backButtonUsed) {
		backButton = [[MenuItem alloc] initWithTitle:@"Back"];
		[backButton addTarget:self action:@selector(backPress:) forControlEvents:UIControlEventTouchUpInside];
		[backButton setFrame:CGRectMake(5, 435, 80, 20)];
		[glView addSubview:backButton];			
	}
}

- (void) dealloc {
	int i;

	for(i=0; i<[_menuElements count]; i++) {
		[[_menuElements objectAtIndex:i] removeFromSuperview];
		[[_menuElements objectAtIndex:i] release];
	}
	
	[_menuElements release];
	
	// remove back button
	if(_backButtonUsed) {
		[backButton removeFromSuperview];
		[backButton release];
	}
	
	[super dealloc];
}

@end
