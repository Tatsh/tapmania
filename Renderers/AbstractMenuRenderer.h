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
	
	BOOL			_backButtonUsed; 
	int				_curPos;		// Starting Y coordinate of the menu items
}

- (id) initWithView:(EAGLView*)lGlView andCapacity:(int)capacity;
- (void) enableBackButton; // disabled by default

- (void) publishMenu;

@end
