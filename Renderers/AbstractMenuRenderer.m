//
//  AbstractMenuRenderer.m
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "AbstractMenuRenderer.h"
#import "MenuItem.h"
#import "RenderEngine.h"

@implementation AbstractMenuRenderer

- (id) initWithCapacity:(int)capacity {
	self = [super init];
	if(!self)
		return nil;
	
	_backButtonUsed = NO;
	_goButtonUsed = NO;
	
	// Construct the menu
	_menuElements = [[NSMutableArray arrayWithCapacity:capacity] retain];
	
	return self;
}

- (void) enableBackButton {
	_backButtonUsed = YES;
}

- (void) enableGoButton {
	_goButtonUsed = YES;
}

- (void) addMenuItemWithTitle:(NSString*) title andHandler:(SEL)sel onTarget:(id)target {
	MenuItem* newItem = [[MenuItem alloc] initWithTitle:title];
	
	// Register callback if needed
	if(sel != nil){
		[newItem addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
	}
	
	[_menuElements addObject:newItem];
}

- (void) addMenuItem:(MenuItem*) item andHandler:(SEL)sel onTarget:(id)target {
	// Register callback if needed
	if(sel != nil){
		[item addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
	}
	[_menuElements addObject:item];
}

// Call this to publish the whole menu
- (void) publishMenu {
	
	_curPos = [_menuElements count] * 50;	// Height of each item + offset 10px
	_curPos = ([RenderEngine sharedInstance].glView.bounds.size.height - _curPos) / 2;	
	
	int i;
	for(i=0; i<[_menuElements count]; i++) {
		MenuItem* item = [_menuElements objectAtIndex:i];
		[item setPosition:_curPos];
		
		[[RenderEngine sharedInstance].glView addSubview:item];	
		
		_curPos += 50;
	}
	
	// Add back button if needed
	if(_backButtonUsed) {
		backButton = [[MenuItem alloc] initWithTitle:@"Back"];
		[backButton addTarget:self action:@selector(backPress:) forControlEvents:UIControlEventTouchUpInside];
		[backButton setFrame:CGRectMake(5, 435, 80, 40)];
		[[RenderEngine sharedInstance].glView addSubview:backButton];			
	}

	// Add go button if needed
	if(_goButtonUsed) {
		goButton = [[MenuItem alloc] initWithTitle:@"Go!"];
		[goButton addTarget:self action:@selector(goPress:) forControlEvents:UIControlEventTouchUpInside];
		[goButton setFrame:CGRectMake(235, 435, 80, 40)];
		[[RenderEngine sharedInstance].glView addSubview:goButton];			
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

	// remove go button
	if(_goButtonUsed) {
		[goButton removeFromSuperview];
		[goButton release];
	}
	
	[super dealloc];
}

@end
