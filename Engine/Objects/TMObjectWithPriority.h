//
//  TMObjectWithPriority.h
//  TapMania
//
//  Created by Alex Kremer on 26.11.08.
//  Copyright 2008 Godexsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMObjectWithPriority : NSObject {
	NSObject* obj;
	unsigned priority;
}

@property (readonly,retain,nonatomic) NSObject* obj;
@property (readonly,assign) unsigned priority;

-(id) initWithObj:(NSObject*)lObj andPriority:(unsigned)lPriority;

@end
