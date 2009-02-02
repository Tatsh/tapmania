//
//  TogglerItem.h
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"
#import "MenuItem.h"
#import "TMGameUIResponder.h"

/* This object is a pair with title=>value */
@interface TogglerItemObject : NSObject {
	NSString * title;
	NSObject * value;
	
	Texture2D * text;	// The title as texture
}

@property (retain, nonatomic, readonly) NSString* title;
@property (retain, nonatomic, readonly) Texture2D* text;
@property (retain, nonatomic) NSObject* value;

- (id) initWithTitle:(NSString*)lTitle andValue:(NSObject*)lValue;

@end

/* The toggler self */
@interface TogglerItem : MenuItem <TMGameUIResponder> {
	NSMutableArray*		elements;			// All the elements which are available in this toggler item (TogglerItemObjects)
	int					currentSelection;	// Index of currently selected element
}

- (id) initWithElements:(NSArray*)arr andShape:(CGRect) lShape;
- (void) toggle;
- (TogglerItemObject*) getCurrent;

@end
