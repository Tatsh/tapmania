//
//  AbstractMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractRenderer.h"
#import "MenuItem.h"

@interface AbstractMenuRenderer : AbstractRenderer {
	NSMutableArray* _menuElements;	// The array will be initially set to some capacity
	MenuItem*		backButton;		// Will be rendered in left-bottom corner if backButtonUsed set to true
	MenuItem*		goButton;		// Will be rendered in right-bottom corner if goButtonUsed set to true
	
	BOOL			_backButtonUsed; 
	BOOL			_goButtonUsed; 
	int			_curPos;		// Starting Y coordinate of the menu items
}

- (id) initWithCapacity:(int)capacity;
- (void) enableBackButton; // disabled by default
- (void) enableGoButton; // disabled by default

- (void) addMenuItemWithTitle:(NSString*) title andHandler:(SEL)sel onTarget:(id)target;
- (void) addMenuItem:(MenuItem*) item andHandler:(SEL)sel onTarget:(id)target;
- (void) publishMenu;

@end
