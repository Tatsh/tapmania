//
//  AbstractMenuRenderer.h
//  TapMania
//
//  Created by Alex Kremer on 06.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractRenderer.h"

@interface AbstractMenuRenderer : AbstractRenderer {
	NSMutableArray* _menuElements;	// The array will be initially set to some capacity
	int				_curPos;		// Starting Y coordinate of the menu items
}

- (id) initWithView:(EAGLView*)lGlView andCapacity:(int)capacity;

- (void) addMenuItemWithTitle:(NSString*) title andHandler:(SEL)sel onTarget:(id)target;
- (void) publishMenu;

@end
