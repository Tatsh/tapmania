//
//  TogglerItem.h
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"

@class MenuItem, Texture2D;

/* This object is a pair with title=>value */
@interface TogglerItemObject : NSObject {
	NSString * m_sTitle;
	NSObject * m_pValue;
	
	Texture2D * m_pText;	// The title as texture
}

@property (retain, nonatomic, readonly) NSString* m_sTitle;
@property (retain, nonatomic, readonly) Texture2D* m_pText;
@property (retain, nonatomic) NSObject* m_pValue;

- (id) initWithTitle:(NSString*)lTitle andValue:(NSObject*)lValue;

@end

/* The toggler self */
@interface TogglerItem : MenuItem {
	NSMutableArray*		m_aElements;			// All the elements which are available in this toggler item (TogglerItemObjects)
	int					m_nCurrentSelection;	// Index of currently selected element
}

- (id) initWithElements:(NSArray*)arr andShape:(CGRect) shape;
- (void) toggle;
- (TogglerItemObject*) getCurrent;

@end
