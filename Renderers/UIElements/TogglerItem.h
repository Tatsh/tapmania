//
//  TogglerItem.h
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"

/* This object is a pair with title=>value */
@interface TogglerItemObject : NSObject {
	NSString * title;
	NSObject * value;
}

@property (retain, nonatomic) NSString* title;
@property (retain, nonatomic) NSObject* value;

- (id) initWithTitle:(NSString*)lTitle andValue:(NSObject*)lValue;

@end

/* The toggler self */
@interface TogglerItem : MenuItem {
	NSMutableArray*		elements;			// All the elements which are available in this toggler item (TogglerItemObjects)
	int					currentSelection;	// Index of currently selected element
}

- (id) initWithElements:(NSArray*)arr;
- (void) toggle;
- (TogglerItemObject*) getCurrent;

@end
