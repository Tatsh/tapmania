//
//  TMScreen.h
//  TapMania
//
//  Created by Alex Kremer on 10.09.09.
//  Copyright 2009 Godexsoft. All rights reserved.
//

#import "TMTransitionSupport.h"
#import "TMRenderable.h"
#import "TMLogicUpdater.h"

#ifdef __cplusplus

#include <deque>
// #include <memory>
using namespace std;

typedef deque<NSObject* > TMScreenChildren;
// typedef auto_ptr<TMScreenChildren > TMScreenChildrenPtr;

#endif

@interface TMScreen : NSObject <TMRenderable, TMLogicUpdater, TMTransitionSupport> {
	#ifdef __cplusplus
	@protected TMScreenChildren* m_pChildren;
	#endif
}

-(void) pushBackChild:(NSObject*)inChild;
-(void) pushChild:(NSObject*)inChild;
-(NSObject*) popBackChild;
-(NSObject*) popChild;

-(void) pushBackControl:(NSObject*)inChild;

@end
