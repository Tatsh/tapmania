//
//  TMObjectWithPriority.h
//  TapMania
//
//  Created by Alex Kremer on 26.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMObjectWithPriority : NSObject {
	NSObject*	m_pObj;
	unsigned	m_uPriority;
}

@property (readonly,retain,nonatomic) NSObject* m_pObj;
@property (readonly,assign) unsigned m_uPriority;

-(id) initWithObj:(NSObject*)obj andPriority:(unsigned)priority;

@end
