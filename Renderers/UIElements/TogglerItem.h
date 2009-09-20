//
//  TogglerItem.h
//  TapMania
//
//  Created by Alex Kremer on 12.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import "MenuItem.h"

@class MenuItem, Texture2D;

/* This object is a pair with title=>value */
@interface TogglerItemObject : NSObject {
	NSString * m_sTitle;
	NSObject * m_pValue;
	CGSize     m_oSize;
	float	   m_fFontSize;
	
	NSArray *  m_pCmdList;
	
	Texture2D * m_pText;	// The title as texture
}

@property (retain, nonatomic, readonly) NSString* m_sTitle;
@property (retain, nonatomic, readonly) Texture2D* m_pText;
@property (retain, nonatomic) NSObject* m_pValue;

- (id) initWithSize:(CGSize)size andFontSize:(float)fontSize;
- (id) initWithTitle:(NSString*)lTitle value:(NSObject*)lValue size:(CGSize)size andFontSize:(float)fontSize;
- (void) setName:(NSString*)inName;
- (void) setCmdList:(NSArray*)inCmdList;
- (void) onSelect;

@end

/* The toggler self */
@interface TogglerItem : MenuItem {
	NSMutableArray*		m_aElements;			// All the elements which are available in this toggler item (TogglerItemObjects)
	int					m_nCurrentSelection;	// Index of currently selected element
		
	/* Sound effects */
	TMSound*	sr_TogglerEffect;
}

- (id) initWithShape:(CGRect)shape andCommands:(NSArray*) inCmds;

- (void) addItem:(NSObject*)value withTitle:(NSString*)title;
- (void) removeItemAtIndex:(int) index;
- (void) removeAll;

- (int) findIndexByValue:(NSObject*)value;
- (void) selectItemAtIndex:(int) index;
- (void) toggle;
- (TogglerItemObject*) getCurrent;

@end
